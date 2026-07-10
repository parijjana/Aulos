import 'dart:async';
import 'package:aulos/domain/network/log_service.dart';

class Benchmark {
  static Future<T> measureAsync<T>(
    String name,
    LogService logService,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      logService.log('[BENCHMARK] $name: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
