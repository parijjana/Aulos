import 'dart:io';
import 'package:yaml/yaml.dart';

/// G0: Tamper-evidence checks for the gate itself.
///
/// This runs BEFORE all other gate checks (G1-G5) so that an attempt to
/// weaken the gate's own reach (excluding tool/ from analysis) or to
/// silently ratchet size/helper baselines upward is caught first and fails
/// the whole run.
Future<bool> runIntegrityChecks(
  Map<String, dynamic> report,
  Map<String, int> baselineMap,
  List<String> helperBaseline,
  bool verbose,
) async {
  final violations = <String>[];
  String committedConfig = 'checked';

  // (a) Analyzer-exclude check: analysis_options.yaml must not exclude tool/.
  _checkAnalyzerExclude(violations);

  // (b) Baseline ratchet check vs the committed (HEAD) gate_config.yaml.
  committedConfig = await _checkBaselineRatchet(violations, baselineMap, helperBaseline, verbose);

  final passed = violations.isEmpty;

  report['integrity'] = {
    'pass': passed,
    'violations': violations,
    'committed_config': committedConfig,
  };

  if (!passed) {
    if (verbose) {
      print('  G0 Fail: ${violations.length} tamper-evidence violation(s) found.');
      for (final v in violations) {
        print('    $v');
      }
    }
    return false;
  }

  if (verbose) {
    print('  G0 Pass: no tamper-evidence violations found.');
  }
  return true;
}

void _checkAnalyzerExclude(List<String> violations) {
  final optionsFile = File('analysis_options.yaml');
  if (!optionsFile.existsSync()) {
    return;
  }

  try {
    final doc = loadYaml(optionsFile.readAsStringSync());
    if (doc is! YamlMap) return;
    final analyzerSection = doc['analyzer'];
    if (analyzerSection is! YamlMap) return;
    final excludeList = analyzerSection['exclude'];
    if (excludeList is! YamlList) return;

    for (final entry in excludeList) {
      if (entry.toString().contains('tool')) {
        violations.add('[G0 tamper] analysis_options.yaml excludes tool/ from analysis');
        return;
      }
    }
  } catch (_) {
    // If analysis_options.yaml is malformed, that is a concern for the
    // analyzer step itself (G1), not this integrity check.
  }
}

Future<String> _checkBaselineRatchet(
  List<String> violations,
  Map<String, int> baselineMap,
  List<String> helperBaseline,
  bool verbose,
) async {
  ProcessResult result;
  try {
    result = await Process.run('git', ['show', 'HEAD:tool/gate_config.yaml']);
  } catch (_) {
    if (verbose) {
      print('  G0 Warning: unable to invoke git to check committed tool/gate_config.yaml; skipping baseline ratchet check.');
    }
    return 'skipped';
  }

  if (result.exitCode != 0) {
    if (verbose) {
      print('  G0 Warning: no HEAD version of tool/gate_config.yaml found; skipping baseline ratchet check.');
    }
    return 'skipped';
  }

  YamlMap committedYaml;
  try {
    committedYaml = loadYaml(result.stdout.toString()) as YamlMap;
  } catch (_) {
    if (verbose) {
      print('  G0 Warning: could not parse committed tool/gate_config.yaml; skipping baseline ratchet check.');
    }
    return 'skipped';
  }

  final committedBaseline = Map<String, int>.from(committedYaml['baseline'] as Map? ?? {});
  final committedHelperBaseline = List<String>.from(committedYaml['widget_helper_baseline'] as List? ?? []);

  for (final entry in baselineMap.entries) {
    final path = entry.key;
    final workingValue = entry.value;
    final committedValue = committedBaseline[path];
    if (committedValue == null) {
      violations.add('[G0 tamper] baseline entry added: $path');
    } else if (workingValue > committedValue) {
      violations.add('[G0 tamper] baseline raised: $path $committedValue -> $workingValue');
    }
  }

  final committedHelperSet = committedHelperBaseline.toSet();
  for (final entry in helperBaseline) {
    if (!committedHelperSet.contains(entry)) {
      violations.add('[G0 tamper] baseline entry added: $entry');
    }
  }

  return 'checked';
}
