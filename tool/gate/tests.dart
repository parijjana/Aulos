import 'dart:io';
import 'dart:convert';

Future<bool> runTests(Map<String, dynamic> report) async {
  final coverageFile = File('coverage/lcov.info');
  if (coverageFile.existsSync()) {
    try {
      coverageFile.deleteSync();
    } catch (_) {}
  }

  try {
    final process = await Process.start('flutter', ['test', '--coverage', '--reporter=json'], runInShell: true);
    final stderrDone = process.stderr.drain<void>();
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

    await stderrDone;
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
