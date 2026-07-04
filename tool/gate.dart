import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';

import 'gate/analyzer.dart';
import 'gate/size.dart';
import 'gate/struct.dart';
import 'gate/tests.dart';
import 'gate/coverage.dart';
import 'gate/report.dart';

// Canonical invocation: dart tool/gate.dart
void main(List<String> arguments) async {
  final shrinkBaseline = arguments.contains('--shrink-baseline');
  final verbose = arguments.contains('--verbose');
  final isCi = arguments.contains('--ci');

  if (verbose) {
    print('Aulos Gate: Checking rules and verification...\n');
  }

  final configFile = File('tool/gate_config.yaml');
  if (!configFile.existsSync()) {
    print('ERROR: tool/gate_config.yaml not found.');
    exit(1);
  }

  final configYaml = loadYaml(configFile.readAsStringSync()) as YamlMap;
  final configMap = <String, dynamic>{};
  for (final entry in configYaml.entries) {
    configMap[entry.key.toString()] = entry.value;
  }
  final baselineMap = Map<String, int>.from(configYaml['baseline'] as Map? ?? {});
  final helperBaseline = List<String>.from(configYaml['widget_helper_baseline'] as List? ?? []);
  final forbiddenImportsConfig = List<dynamic>.from(configYaml['forbidden_imports'] as List? ?? []);

  final report = <String, dynamic>{
    'schema': 1,
    'sha': _getGitCommitSha(),
    'pass': true,
    'wall_secs': 0,
    'tests': {'total': 0, 'failed': 0, 'failures': []},
    'analyzer': {'errors': 0, 'warnings': 0, 'infos': 0},
    'size': {'violations': [], 'baseline_count': baselineMap.length, 'largest': 0, 'p90': 0},
    'struct': {'widget_helpers': [], 'barrel_files': [], 'forbidden_imports': []},
    'coverage_pct': null,
  };

  final startTime = DateTime.now();

  // Run G1: Analyzer
  if (verbose) {
    print('Running G1: Dart Analyzer...');
  }
  final analyzerPassed = await runAnalyzer(report, verbose);

  // Run G2: File Size Ratchet
  if (verbose) {
    print('Running G2: File Size Ratchet...');
  }
  var baselineUpdated = false;
  final sizePassed = runSizeRatchet(report, baselineMap, shrinkBaseline, verbose, () => baselineUpdated = true);

  // Run G3: Structural Rules
  if (verbose) {
    print('Running G3: Structural Rules...');
  }
  var helperBaselineUpdated = false;
  final updatedHelperBaseline = <String>[];
  final structPassed = runStructuralChecks(
    report,
    helperBaseline,
    shrinkBaseline,
    updatedHelperBaseline,
    forbiddenImportsConfig,
    verbose,
    () => helperBaselineUpdated = true,
  );

  // Run G4: Tests
  if (verbose) {
    print('Running G4: Flutter Tests...');
  }
  final testsPassed = await runTests(report, verbose);

  // Run G5: Coverage (if lcov.info exists)
  if (verbose) {
    print('Running G5: Coverage Check...');
  }
  runCoverage(report, verbose);

  final wallSecs = DateTime.now().difference(startTime).inSeconds;
  report['wall_secs'] = wallSecs;

  // Rewrite config file if anything shrunk under --shrink-baseline
  if (shrinkBaseline && (baselineUpdated || helperBaselineUpdated || updatedHelperBaseline.length != helperBaseline.length)) {
    configMap['baseline'] = baselineMap;
    configMap['widget_helper_baseline'] = updatedHelperBaseline;

    final buffer = StringBuffer();
    buffer.writeln('# Aulos Gate Configuration');
    buffer.writeln('# File counts can only shrink, never grow.');
    buffer.writeln('');

    final sortedKeys = configMap.keys.toList()..sort();
    for (final key in sortedKeys) {
      final value = configMap[key];
      if (key == 'baseline') {
        buffer.writeln('baseline:');
        final sortedBaselineKeys = baselineMap.keys.toList()..sort();
        for (final bKey in sortedBaselineKeys) {
          buffer.writeln('  $bKey: ${baselineMap[bKey]}');
        }
      } else if (key == 'widget_helper_baseline') {
        buffer.writeln('widget_helper_baseline:');
        final sortedHelpers = updatedHelperBaseline..sort();
        for (final file in sortedHelpers) {
          buffer.writeln('  - $file');
        }
      } else if (value is Map) {
        buffer.writeln('$key:');
        final sortedSubKeys = value.keys.map((k) => k.toString()).toList()..sort();
        for (final subKey in sortedSubKeys) {
          final subVal = value[subKey];
          if (subVal is List) {
            buffer.writeln('  $subKey:');
            for (final item in subVal) {
              buffer.writeln('    - ${item.toString()}');
            }
          } else {
            buffer.writeln('  $subKey: ${formatYamlValue(subVal)}');
          }
        }
      } else if (value is List) {
        buffer.writeln('$key:');
        final listValues = value.map((v) => v.toString()).toList()..sort();
        for (final val in listValues) {
          buffer.writeln('  - $val');
        }
      } else {
        buffer.writeln('$key: ${formatYamlValue(value)}');
      }
      buffer.writeln('');
    }
    configFile.writeAsStringSync(buffer.toString().trim() + '\n');
    if (verbose) {
      print('  Baseline configuration shrunk and saved in tool/gate_config.yaml.');
    }
  }

  final totalPassed = analyzerPassed && sizePassed && structPassed && testsPassed;
  report['pass'] = totalPassed;
  report['size']['baseline_count'] = baselineMap.length;

  // Output Report
  await File('gate_report.json').writeAsString(JsonEncoder.withIndent('  ').convert(report));

  // Write gate_summary.md for CI step summary (only if --ci passed)
  if (isCi) {
    await writeSummaryMarkdown(report, totalPassed);
  }

  printDigest(report, totalPassed);

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
