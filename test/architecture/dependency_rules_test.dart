import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main() {
  group('Architectural Layer Segregation Guardrails', () {
    final configFile = File('tool/gate_config.yaml');
    if (!configFile.existsSync()) {
      fail('tool/gate_config.yaml not found.');
    }

    final configYaml = loadYaml(configFile.readAsStringSync()) as YamlMap;
    final forbiddenImportsConfig = List<dynamic>.from(configYaml['forbidden_imports'] as List? ?? []);

    for (final rule in forbiddenImportsConfig) {
      final prefix = rule['path_prefix'] as String;
      final patterns = List<String>.from(rule['patterns'] as List? ?? []);

      test('Layer segregation check for prefix: "$prefix"', () {
        final dir = Directory(prefix);
        if (!dir.existsSync()) {
          return;
        }

        final files = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in files) {
          final relativePath = p.relative(file.path, from: Directory.current.path).replaceAll('\\', '/');

          // Exclude /services/ and /data/ subdirectories for features/screens UI components
          if ((prefix.startsWith('lib/features') || prefix.startsWith('lib/presentation/screens')) &&
              (relativePath.contains('/services/') || relativePath.contains('/data/'))) {
            continue;
          }

          final content = file.readAsStringSync();
          final lines = content.split('\n');

          for (final line in lines) {
            if (line.trim().startsWith('import ')) {
              for (final pattern in patterns) {
                if (line.contains(pattern)) {
                  fail('File $relativePath violates layer segregation by importing: "$pattern" in line: "${line.trim()}"');
                }
              }
            }
          }
        }
      });
    }
  });
}
