import 'dart:io';
import 'package:path/path.dart' as p;

Future<bool> runAnalyzer(Map<String, dynamic> report) async {
  try {
    final res = await Process.run('dart', ['analyze', '--format=machine']);
    final lines = res.stdout.toString().split('\n');
    int errors = 0;
    int warnings = 0;
    int infos = 0;
    final failures = <Map<String, String>>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|');
      if (parts.length < 8) continue;
      final severity = parts[0];
      if (severity == 'ERROR' || severity == 'WARNING') {
        if (severity == 'ERROR') errors++;
        else if (severity == 'WARNING') warnings++;
        final relativePath = p.relative(parts[3], from: Directory.current.path).replaceAll('\\', '/');
        failures.add({
          'severity': severity,
          'file': relativePath,
          'line': parts[4],
          'column': parts[5],
          'message': parts[7],
        });
      } else if (severity == 'INFO') {
        infos++;
      }
    }

    report['analyzer'] = {
      'errors': errors,
      'warnings': warnings,
      'infos': infos,
      'failures': failures,
    };

    if (errors > 0 || warnings > 0) {
      print('  G1 Fail: $errors errors, $warnings warnings found. ($infos infos)');
      return false;
    }
    print('  G1 Pass: 0 errors, 0 warnings, $infos infos.');
    return true;
  } catch (e) {
    print('  G1 Error running analyzer: $e');
    return false;
  }
}
