import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  final shrinkBaseline = arguments.contains('--shrink-baseline');
  final isCi = arguments.contains('--ci');

  print('Aulos Gate: Checking rules and verification...\n');

  final configFile = File('tool/gate_config.yaml');
  if (!configFile.existsSync()) {
    print('ERROR: tool/gate_config.yaml not found.');
    exit(1);
  }

  final configYaml = loadYaml(configFile.readAsStringSync()) as YamlMap;
  final baselineMap = Map<String, int>.from(configYaml['baseline'] as Map? ?? {});
  final helperBaseline = List<String>.from(configYaml['widget_helper_baseline'] as List? ?? []);

  final report = <String, dynamic>{
    'schema': 1,
    'sha': _getGitCommitSha(),
    'pass': true,
    'wall_secs': 0,
    'tests': {'total': 0, 'failed': 0, 'failures': []},
    'analyzer': {'errors': 0, 'warnings': 0, 'infos': 0},
    'size': {'violations': [], 'baseline_count': baselineMap.length, 'largest': 0, 'p90': 0},
    'struct': {'widget_helpers': [], 'barrel_files': [], 'forbidden_imports': []},
    'coverage_pct': 0.0,
  };

  final startTime = DateTime.now();

  // Run G1: Analyzer
  print('Running G1: Dart Analyzer...');
  final analyzerPassed = await _runAnalyzer(report);

  // Run G2: File Size Ratchet
  print('Running G2: File Size Ratchet...');
  var baselineUpdated = false;
  final sizePassed = _runSizeRatchet(report, baselineMap, shrinkBaseline, () => baselineUpdated = true);

  // Run G3: Structural Rules
  print('Running G3: Structural Rules...');
  final updatedHelperBaseline = <String>[];
  var helperBaselineUpdated = false;
  final structPassed = _runStructuralChecks(
    report,
    helperBaseline,
    shrinkBaseline,
    updatedHelperBaseline,
    () => helperBaselineUpdated = true,
  );

  // Run G4: Tests
  print('Running G4: Flutter Tests...');
  final testsPassed = await _runTests(report);

  // Run G5: Coverage (if lcov.info exists)
  print('Running G5: Coverage Check...');
  _runCoverage(report);

  final wallSecs = DateTime.now().difference(startTime).inSeconds;
  report['wall_secs'] = wallSecs;

  // Rewrite config file if anything shrunk/bootstrapped under --shrink-baseline
  if (shrinkBaseline && (baselineUpdated || helperBaselineUpdated || updatedHelperBaseline.length != helperBaseline.length)) {
    final buffer = StringBuffer();
    buffer.writeln('# Aulos Gate Configuration');
    buffer.writeln('flutter_version: "stable"');
    buffer.writeln('');
    buffer.writeln('# Files allowed to exceed 300 lines (frozen at today\'s counts).');
    buffer.writeln('# File counts can only shrink, never grow.');
    buffer.writeln('baseline:');
    final sortedKeys = baselineMap.keys.toList()..sort();
    for (final key in sortedKeys) {
      buffer.writeln('  $key: ${baselineMap[key]}');
    }
    buffer.writeln('');
    buffer.writeln('# Files allowed to have widget build helpers.');
    buffer.writeln('widget_helper_baseline:');
    final sortedHelpers = updatedHelperBaseline..sort();
    for (final file in sortedHelpers) {
      buffer.writeln('  - $file');
    }
    configFile.writeAsStringSync(buffer.toString());
    print('  Baseline configuration shrunk and saved in tool/gate_config.yaml.');
  }

  final totalPassed = analyzerPassed && sizePassed && structPassed && testsPassed;
  report['pass'] = totalPassed;

  // Output Report
  await File('gate_report.json').writeAsString(JsonEncoder.withIndent('  ').convert(report));

  // Write gate_summary.md for CI step summary
  await _writeSummaryMarkdown(report, totalPassed);

  _printDigest(report, totalPassed);

  if (!totalPassed) {
    exit(1);
  }
  exit(0);
}

String _getGitCommitSha() {
  try {
    final res = Process.runSync('git', ['rev-parse', '--short', 'HEAD']);
    if (res.exitCode == 0) {
      return res.stdout.toString().trim();
    }
  } catch (_) {}
  return 'unknown';
}

Future<bool> _runAnalyzer(Map<String, dynamic> report) async {
  try {
    final res = await Process.run('dart', ['analyze', '--format=machine']);
    final lines = res.stdout.toString().split('\n');
    int errors = 0;
    int warnings = 0;
    int infos = 0;

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|');
      if (parts.length < 4) continue;
      final severity = parts[0];
      if (severity == 'ERROR') errors++;
      else if (severity == 'WARNING') warnings++;
      else if (severity == 'INFO') infos++;
    }

    report['analyzer'] = {'errors': errors, 'warnings': warnings, 'infos': infos};
    if (errors > 0) {
      print('  G1 Fail: $errors analyzer errors found. ($warnings warnings, $infos infos)');
      return false;
    }
    print('  G1 Pass: 0 errors, $warnings warnings, $infos infos.');
    return true;
  } catch (e) {
    print('  G1 Error running analyzer: $e');
    return false;
  }
}

bool _runSizeRatchet(
  Map<String, dynamic> report,
  Map<String, int> baselineMap,
  bool shrink,
  void Function() onUpdated,
) {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return true;

  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .toList();

  final violations = <Map<String, dynamic>>[];
  final allSizes = <int>[];
  final existingRelativePaths = <String>{};

  for (final file in files) {
    final relativePath = p.relative(file.path, from: Directory.current.path).replaceAll('\\', '/');
    existingRelativePaths.add(relativePath);
    final lines = file.readAsLinesSync();
    final lineCount = lines.length;
    allSizes.add(lineCount);

    final baselineLimit = baselineMap[relativePath];

    if (baselineLimit != null) {
      if (lineCount > baselineLimit) {
        violations.add({'path': relativePath, 'lines': lineCount, 'limit': baselineLimit});
      } else if (lineCount < baselineLimit && shrink) {
        if (lineCount <= 300) {
          baselineMap.remove(relativePath);
        } else {
          baselineMap[relativePath] = lineCount;
        }
        onUpdated();
      }
    } else {
      if (lineCount > 300) {
        violations.add({'path': relativePath, 'lines': lineCount, 'limit': 300});
      }
    }
  }

  if (shrink) {
    final toRemove = <String>[];
    for (final key in baselineMap.keys) {
      if (!existingRelativePaths.contains(key)) {
        toRemove.add(key);
      }
    }
    if (toRemove.isNotEmpty) {
      for (final key in toRemove) {
        baselineMap.remove(key);
      }
      onUpdated();
    }
  }

  allSizes.sort();
  final largest = allSizes.isEmpty ? 0 : allSizes.last;
  final p90Index = (allSizes.length * 0.9).floor();
  final p90 = allSizes.isEmpty ? 0 : allSizes[p90Index >= allSizes.length ? allSizes.length - 1 : p90Index];

  report['size']['violations'] = violations;
  report['size']['largest'] = largest;
  report['size']['p90'] = p90;

  if (violations.isNotEmpty) {
    print('  G2 Fail: ${violations.length} files violated size constraints.');
    for (final v in violations) {
      print('    ${v['path']}: ${v['lines']} lines (limit: ${v['limit']})');
    }
    return false;
  }

  print('  G2 Pass: Largest file is $largest lines. p90 is $p90 lines.');
  return true;
}

bool _runStructuralChecks(
  Map<String, dynamic> report,
  List<String> helperBaseline,
  bool shrink,
  List<String> updatedHelperBaseline,
  void Function() onUpdated,
) {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return true;

  final widgetHelpers = <String>[];
  final barrelFiles = <String>[];
  final forbiddenImports = <String>[];

  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .toList();

  final buildHelperRegex = RegExp(r'Widget\s+_build\w+\s*\(');

  for (final file in files) {
    final relativePath = p.relative(file.path, from: Directory.current.path).replaceAll('\\', '/');
    final content = file.readAsStringSync();
    final lines = content.split('\n');

    // 1. Widget build helper check
    if (buildHelperRegex.hasMatch(content)) {
      if (helperBaseline.contains(relativePath)) {
        updatedHelperBaseline.add(relativePath);
      } else {
        widgetHelpers.add(relativePath);
      }
    }

    // 2. Barrel file check (only exports and comments/imports)
    bool hasCode = false;
    bool hasExport = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('//') || trimmed.startsWith('/*') || trimmed.startsWith('*') || trimmed.startsWith('import ')) {
        continue;
      }
      if (trimmed.startsWith('export ')) {
        hasExport = true;
        continue;
      }
      hasCode = true;
    }
    if (hasExport && !hasCode) {
      barrelFiles.add(relativePath);
    }

    // 3. Forbidden imports check
    final isViewModel = relativePath.startsWith('lib/presentation/viewmodels');
    final isUi = (relativePath.startsWith('lib/features') || relativePath.startsWith('lib/presentation/screens')) &&
        !relativePath.contains('/services/') &&
        !relativePath.contains('/data/');

    for (final line in lines) {
      if (line.trim().startsWith('import ')) {
        if (isViewModel) {
          if (line.contains('package:archive/') || line.contains('package:path_provider/')) {
            forbiddenImports.add('$relativePath: ${line.trim()}');
          }
        }
        if (isUi) {
          if (line.contains('package:drift/') || line.contains('package:archive/') || line.contains('package:path_provider/')) {
            forbiddenImports.add('$relativePath: ${line.trim()}');
          }
        }
      }
    }
  }

  report['struct'] = {
    'widget_helpers': widgetHelpers,
    'barrel_files': barrelFiles,
    'forbidden_imports': forbiddenImports,
  };

  bool passed = true;
  if (widgetHelpers.isNotEmpty) {
    print('  G3 Fail: Found ${widgetHelpers.length} files with private widget-returning helper methods:');
    for (final f in widgetHelpers.take(5)) print('    $f');
    passed = false;
  }
  if (barrelFiles.isNotEmpty) {
    print('  G3 Fail: Found ${barrelFiles.length} barrel files (exports only):');
    for (final f in barrelFiles.take(5)) print('    $f');
    passed = false;
  }
  if (forbiddenImports.isNotEmpty) {
    print('  G3 Fail: Found ${forbiddenImports.length} forbidden imports:');
    for (final f in forbiddenImports.take(5)) print('    $f');
    passed = false;
  }

  if (passed) {
    print('  G3 Pass: Structural rules followed perfectly.');
  }
  return passed;
}

Future<bool> _runTests(Map<String, dynamic> report) async {
  try {
    final process = await Process.start('flutter', ['test', '--reporter=json'], runInShell: true);
    final failures = <Map<String, String>>[];
    final testNames = <int, String>{};
    int total = 0;
    int failed = 0;

    final lineStream = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      if (line.trim().isEmpty) continue;
      try {
        final event = jsonDecode(line) as Map<String, dynamic>;
        final type = event['type'];
        if (type == 'testStart') {
          final test = event['test'] as Map<String, dynamic>;
          final id = test['id'] as int;
          final name = test['name'] as String;
          testNames[id] = name;
          if (name.isNotEmpty && !name.startsWith('loading ')) {
            total++;
          }
        } else if (type == 'error') {
          final testId = event['testID'] as int;
          final error = event['error'] as String;
          final name = testNames[testId] ?? 'Unknown Test';
          final firstLine = error.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => 'Unknown Error');
          failures.add({'name': name, 'error': firstLine});
        } else if (type == 'testDone') {
          final result = event['result'] as String;
          if (result == 'failure' || result == 'error') {
            failed++;
          }
        }
      } catch (_) {}
    }

    final exitCode = await process.exitCode;

    report['tests'] = {
      'total': total,
      'failed': failed,
      'failures': failures,
    };

    if (exitCode != 0 || failed > 0) {
      print('  G4 Fail: $failed tests failed out of $total.');
      return false;
    }

    print('  G4 Pass: All $total tests passed successfully.');
    return true;
  } catch (e) {
    print('  G4 Error running tests: $e');
    return false;
  }
}

void _runCoverage(Map<String, dynamic> report) {
  final coverageFile = File('coverage/lcov.info');
  if (!coverageFile.existsSync()) {
    report['coverage_pct'] = 0.0;
    print('  G5 Skip: coverage/lcov.info not found. Coverage remains 0%.');
    return;
  }

  try {
    final lines = coverageFile.readAsLinesSync();
    int instrumentedLines = 0;
    int coveredLines = 0;

    for (final line in lines) {
      if (line.startsWith('LF:')) {
        instrumentedLines += int.parse(line.substring(3).trim());
      } else if (line.startsWith('LH:')) {
        coveredLines += int.parse(line.substring(3).trim());
      }
    }

    final pct = instrumentedLines == 0 ? 0.0 : (coveredLines / instrumentedLines) * 100.0;
    report['coverage_pct'] = double.parse(pct.toStringAsFixed(1));
    print('  G5 Pass: Coverage is ${report['coverage_pct']}% ($coveredLines/$instrumentedLines lines).');
  } catch (e) {
    print('  G5 Error reading coverage: $e');
  }
}

Future<void> _writeSummaryMarkdown(Map<String, dynamic> report, bool pass) async {
  final buffer = StringBuffer();
  buffer.writeln('# Aulos Gate Summary');
  buffer.writeln('');
  buffer.writeln('**Status:** ${pass ? "🟢 PASS" : "🔴 FAIL"}');
  buffer.writeln('**SHA:** `${report['sha']}`');
  buffer.writeln('**Wall Time:** ${report['wall_secs']} seconds');
  buffer.writeln('');
  buffer.writeln('### Metrics');
  buffer.writeln('- **Tests:** ${report['tests']['total'] - report['tests']['failed']}/${report['tests']['total']} passed');
  buffer.writeln('- **Analyzer:** ${report['analyzer']['errors']} Errors, ${report['analyzer']['warnings']} Warnings, ${report['analyzer']['infos']} Infos');
  buffer.writeln('- **Size violations:** ${report['size']['violations'].length}');
  buffer.writeln('- **Coverage:** ${report['coverage_pct']}%');
  buffer.writeln('');

  if (!pass) {
    buffer.writeln('### Violations');
    final sizeViolations = report['size']['violations'] as List;
    if (sizeViolations.isNotEmpty) {
      buffer.writeln('#### File Size violations');
      for (final v in sizeViolations) {
        buffer.writeln('- `${v['path']}`: ${v['lines']} lines (max limit: ${v['limit']})');
      }
    }
    final struct = report['struct'] as Map<String, dynamic>;
    final helpers = struct['widget_helpers'] as List;
    if (helpers.isNotEmpty) {
      buffer.writeln('#### Private Widget Build Helpers');
      for (final f in helpers) {
        buffer.writeln('- `$f`');
      }
    }
    final barrels = struct['barrel_files'] as List;
    if (barrels.isNotEmpty) {
      buffer.writeln('#### Export Barrel Files');
      for (final f in barrels) {
        buffer.writeln('- `$f`');
      }
    }
    final forbidden = struct['forbidden_imports'] as List;
    if (forbidden.isNotEmpty) {
      buffer.writeln('#### Forbidden Layer Imports');
      for (final f in forbidden) {
        buffer.writeln('- `$f`');
      }
    }
    final failures = report['tests']['failures'] as List;
    if (failures.isNotEmpty) {
      buffer.writeln('#### Failed Tests');
      for (final f in failures) {
        buffer.writeln('- **${f['name']}**');
        buffer.writeln('  `Error: ${f['error']}`');
      }
    }
  }

  await File('gate_summary.md').writeAsString(buffer.toString());
}

void _printDigest(Map<String, dynamic> report, bool pass) {
  if (pass) {
    print('\nGATE PASS  sha=${report['sha']}  tests=${report['tests']['total'] - report['tests']['failed']}/${report['tests']['total']}  analyzer=${report['analyzer']['errors']}E/${report['analyzer']['warnings']}W  size=${report['size']['violations'].length}  cov=${report['coverage_pct']}%');
  } else {
    print('\nGATE FAIL  sha=${report['sha']}');
    final sizeViolations = report['size']['violations'] as List;
    for (final v in sizeViolations.take(5)) {
      print('[G2 size] ${v['path']} ${v['lines']} > limit ${v['limit']}');
    }
    if (sizeViolations.length > 5) print('  (+${sizeViolations.length - 5} more size violations)');

    final struct = report['struct'] as Map<String, dynamic>;
    final helpers = struct['widget_helpers'] as List;
    for (final f in helpers.take(5)) {
      print('[G3 helper] $f holds widget build helper');
    }
    if (helpers.length > 5) print('  (+${helpers.length - 5} more helper violations)');

    final barrels = struct['barrel_files'] as List;
    for (final f in barrels.take(5)) {
      print('[G3 barrel] $f is a barrel file');
    }
    if (barrels.length > 5) print('  (+${barrels.length - 5} more barrel violations)');

    final forbidden = struct['forbidden_imports'] as List;
    for (final f in forbidden.take(5)) {
      print('[G3 import] $f');
    }
    if (forbidden.length > 5) print('  (+${forbidden.length - 5} more import violations)');

    final failures = report['tests']['failures'] as List;
    for (final f in failures.take(5)) {
      print('[G4 test] ${f['name']}');
      print('           ${f['error']}');
    }
    if (failures.length > 5) print('  (+${failures.length - 5} more test failures)');
  }
}
