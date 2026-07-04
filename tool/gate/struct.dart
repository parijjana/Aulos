import 'dart:io';
import 'package:path/path.dart' as p;

bool runStructuralChecks(
  Map<String, dynamic> report,
  List<String> helperBaseline,
  bool shrink,
  List<String> updatedHelperBaseline,
  List<dynamic> forbiddenImportsConfig,
  bool verbose,
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
    for (final rule in forbiddenImportsConfig) {
      final prefix = rule['path_prefix'] as String;
      final patterns = List<String>.from(rule['patterns'] as List? ?? []);

      if (relativePath.startsWith(prefix)) {
        // Exclude /services/ and /data/ subdirectories for features/screens UI components
        if ((prefix.startsWith('lib/features') || prefix.startsWith('lib/presentation/screens')) &&
            (relativePath.contains('/services/') || relativePath.contains('/data/'))) {
          continue;
        }

        for (final line in lines) {
          if (line.trim().startsWith('import ')) {
            for (final pattern in patterns) {
              if (line.contains(pattern)) {
                forbiddenImports.add('$relativePath: ${line.trim()}');
              }
            }
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
    if (verbose) {
      print('  G3 Fail: ${widgetHelpers.length} widget build helpers found:');
      for (final f in widgetHelpers) {
        print('    $f');
      }
    }
    passed = false;
  }
  if (barrelFiles.isNotEmpty) {
    if (verbose) {
      print('  G3 Fail: ${barrelFiles.length} export barrel files found:');
      for (final f in barrelFiles) {
        print('    $f');
      }
    }
    passed = false;
  }
  if (forbiddenImports.isNotEmpty) {
    if (verbose) {
      print('  G3 Fail: ${forbiddenImports.length} forbidden imports found:');
      for (final f in forbiddenImports) {
        print('    $f');
      }
    }
    passed = false;
  }

  if (passed) {
    if (verbose) {
      print('  G3 Pass: Structural rules followed perfectly.');
    }
  }
  return passed;
}
