import 'dart:io';
import 'dart:convert';

Future<bool> runTests(Map<String, dynamic> report, bool verbose) async {
  final coverageFile = File('coverage/lcov.info');
  if (coverageFile.existsSync()) {
    try {
      coverageFile.deleteSync();
    } catch (_) {}
  }

  try {
    final process = await Process.start('flutter', ['test', '--coverage', '--reporter=json'], runInShell: true);
    final stderrDone = process.stderr.drain<void>();
    final failures = <Map<String, dynamic>>[];
    final testNames = <int, String>{};
    final loadIds = <int>{};
    int total = 0;
    int failed = 0;
    int suiteLoadErrors = 0;

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
          if (name.startsWith('loading ')) {
            loadIds.add(id);
          } else if (name.isNotEmpty) {
            total++;
          }
        } else if (type == 'error') {
          final testId = event['testID'] as int?;
          final error = event['error'] as String;
          final isLoadFailure = testId != null && loadIds.contains(testId);
          final name = testId != null ? (testNames[testId] ?? 'Unknown Test') : 'Suite Load Error';
          final firstLine = error.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => 'Unknown Error');
          
          String finalName = name;
          if (isLoadFailure && name.startsWith('loading ')) {
            finalName = name.replaceFirst('loading ', '');
          }
          failures.add({
            'name': finalName,
            'error': firstLine,
            'isLoadFailure': isLoadFailure,
          });
        } else if (type == 'testDone') {
          final result = event['result'] as String;
          final testId = event['testID'] as int?;
          if (result == 'failure' || result == 'error') {
            if (testId != null && loadIds.contains(testId)) {
              suiteLoadErrors++;
            } else {
              failed++;
            }
          }
        }
      } catch (_) {}
    }

    await stderrDone;
    final exitCode = await process.exitCode;

    report['tests'] = {
      'total': total,
      'failed': failed,
      'suite_load_errors': suiteLoadErrors,
      'failures': failures,
    };

    if (exitCode != 0 || failed > 0 || suiteLoadErrors > 0 || total == 0) {
      if (verbose) {
        if (total == 0) {
          print('  G4 Fail: No tests were run.');
        } else {
          print('  G4 Fail: $failed failures/errors, $suiteLoadErrors suite load errors out of $total.');
        }
      }
      return false;
    }

    if (verbose) {
      print('  G4 Pass: All $total tests passed successfully.');
    }
    return true;
  } catch (e) {
    if (verbose) {
      print('  G4 Error running tests: $e');
    }
    return false;
  }
}
