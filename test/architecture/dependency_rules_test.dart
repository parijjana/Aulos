import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Architectural Layer Segregation Guardrails', () {
    test('Presentation layer viewmodels should not import extraction or directory locator packages', () {
      final vmDir = Directory('lib/presentation/viewmodels');
      if (!vmDir.existsSync()) return;

      // Whitelisted legacy exceptions (to be decomposed/refactored)
      final whitelist = <String>[];

      final forbiddenImports = [
        'package:archive/',
        'package:path_provider/',
      ];

      final vmFiles = vmDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in vmFiles) {
        if (whitelist.contains(p.basename(file.path))) {
          continue;
        }

        final content = file.readAsStringSync();
        final lines = content.split('\n');
        
        for (final line in lines) {
          if (line.trim().startsWith('import ')) {
            for (final forbidden in forbiddenImports) {
              final hasForbidden = line.contains(forbidden);
              expect(
                hasForbidden,
                isFalse,
                reason: 'File ${p.basename(file.path)} imports forbidden library: "$forbidden" in line: "$line"',
              );
            }
          }
        }
      }
    });

    test('UI widgets and screens should not directly import database execution libraries or file extraction packages', () {
      final featuresDir = Directory('lib/features');
      final screensDir = Directory('lib/presentation/screens');

      // We forbid the query execution engine (drift) and file utilities.
      // We temporarily allow importing app_database.dart for accessing generated Model types (Album, Track, Bookmark)
      // until they are refactored to domain entities.
      final forbiddenImports = [
        'package:drift/',
        'package:archive/',
        'package:path_provider/',
      ];

      // Whitelisted legacy coupling exceptions to be refactored
      final whitelist = <String>[];

      final uiDirectories = [featuresDir, screensDir];
      final List<File> uiFiles = [];

      for (final dir in uiDirectories) {
        if (dir.existsSync()) {
          uiFiles.addAll(
            dir
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart'))
                .where((f) => !f.path.contains('/services/') && !f.path.contains('/data/')),
          );
        }
      }

      for (final file in uiFiles) {
        if (whitelist.contains(p.basename(file.path))) {
          continue;
        }

        final content = file.readAsStringSync();
        final lines = content.split('\n');
        
        for (final line in lines) {
          if (line.trim().startsWith('import ')) {
            for (final forbidden in forbiddenImports) {
              final hasForbidden = line.contains(forbidden);
              expect(
                hasForbidden,
                isFalse,
                reason: 'UI Component ${p.basename(file.path)} violates segregation by importing database/data helper: "$forbidden" in line: "$line"',
              );
            }
          }
        }
      }
    });
  });
}
