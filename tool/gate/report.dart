import 'dart:io';

Future<void> writeSummaryMarkdown(Map<String, dynamic> report, bool pass) async {
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
  buffer.writeln('- **Coverage:** ${report['coverage_pct'] != null ? "${report['coverage_pct']}%" : "n/a"}');
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

void printDigest(Map<String, dynamic> report, bool pass) {
  final struct = report['struct'] as Map<String, dynamic>;
  final helpersCount = (struct['widget_helpers'] as List? ?? []).length;
  final barrelsCount = (struct['barrel_files'] as List? ?? []).length;
  final forbiddenCount = (struct['forbidden_imports'] as List? ?? []).length;
  final structCount = helpersCount + barrelsCount + forbiddenCount;

  if (pass) {
    print('\nGATE PASS  sha=${report['sha']}  tests=${report['tests']['total'] - report['tests']['failed']}/${report['tests']['total']}  analyzer=${report['analyzer']['errors']}E/${report['analyzer']['warnings']}W  size=${report['size']['violations'].length}  struct=$structCount  cov=${report['coverage_pct'] != null ? "${report['coverage_pct']}%" : "n/a"}');
  } else {
    print('\nGATE FAIL  sha=${report['sha']}');

    final integrity = report['integrity'] as Map<String, dynamic>?;
    if (integrity != null) {
      final integrityViolations = integrity['violations'] as List? ?? [];
      for (final v in integrityViolations) {
        print(v.toString());
      }
    }

    final analyzerFailures = report['analyzer']['failures'] as List? ?? [];
    for (final f in analyzerFailures.take(5)) {
      print('[G1 analyzer] ${f['file']}:${f['line']}:${f['column']} ${f['message']}');
    }
    if (analyzerFailures.length > 5) print('  (+${analyzerFailures.length - 5} more analyzer warnings/errors)');

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
      final parts = f.toString().split(': ');
      final path = parts.first;
      print('[G3 import] $path contains forbidden import');
    }
    if (forbidden.length > 5) print('  (+${forbidden.length - 5} more import violations)');

    final failures = report['tests']['failures'] as List;
    for (final f in failures.take(5)) {
      final isLoad = f['isLoadFailure'] as bool? ?? false;
      if (isLoad) {
        print('[G4 load] ${f['name']}');
      } else {
        print('[G4 test] ${f['name']} failed with ${f['error']}');
      }
    }
    if (failures.length > 5) print('  (+${failures.length - 5} more test failures)');
  }
}

String formatYamlValue(dynamic value) {
  if (value is String) {
    if (value.contains(' ') || value.contains(':') || value.contains('#') || value.contains('-') || value.contains('[') || value.contains(']')) {
      return '"$value"';
    }
    return value;
  }
  return value.toString();
}
