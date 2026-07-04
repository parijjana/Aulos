import 'dart:io';

void runCoverage(Map<String, dynamic> report) {
  final coverageFile = File('coverage/lcov.info');
  if (!coverageFile.existsSync()) {
    report['coverage_pct'] = null;
    print('  G5: coverage unavailable');
    return;
  }

  try {
    final lines = coverageFile.readAsLinesSync();
    int instrumentedLines = 0;
    int coveredLines = 0;

    String? currentSf;
    int currentLf = 0;
    int currentLh = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('SF:')) {
        currentSf = trimmed.substring(3).trim().replaceAll('\\', '/');
        currentLf = 0;
        currentLh = 0;
      } else if (trimmed.startsWith('LF:')) {
        currentLf = int.parse(trimmed.substring(3).trim());
      } else if (trimmed.startsWith('LH:')) {
        currentLh = int.parse(trimmed.substring(3).trim());
      } else if (trimmed == 'end_of_record') {
        if (currentSf != null && !currentSf.endsWith('.g.dart')) {
          instrumentedLines += currentLf;
          coveredLines += currentLh;
        }
        currentSf = null;
        currentLf = 0;
        currentLh = 0;
      }
    }

    final pct = instrumentedLines == 0 ? 0.0 : (coveredLines / instrumentedLines) * 100.0;
    report['coverage_pct'] = double.parse(pct.toStringAsFixed(1));
    print('  G5 Pass: Coverage is ${report['coverage_pct']}% ($coveredLines/$instrumentedLines lines).');
  } catch (e) {
    print('  G5 Error reading coverage: $e');
    report['coverage_pct'] = null;
  }
}
