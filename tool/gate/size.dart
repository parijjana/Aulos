import 'dart:io';
import 'package:path/path.dart' as p;

bool runSizeRatchet(
  Map<String, dynamic> report,
  Map<String, int> baselineMap,
  bool shrink,
  void Function() onUpdated,
) {
  final libDir = Directory('lib');
  final files = <File>[];
  if (libDir.existsSync()) {
    files.addAll(libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart')));
  }
  
  // Add gate orchestrator and submodules to support self-checking
  final gateFile = File('tool/gate.dart');
  if (gateFile.existsSync()) {
    files.add(gateFile);
  }
  final gateSubDir = Directory('tool/gate');
  if (gateSubDir.existsSync()) {
    files.addAll(gateSubDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart')));
  }

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
