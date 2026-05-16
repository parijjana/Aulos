import 'dart:async';

class RateLimitDispatcher {
  final Map<String, Future<void>> _queues = {};

  Future<T> dispatch<T>({
    required String apiId,
    required Future<T> Function() call,
    Duration cooldown = const Duration(seconds: 1),
  }) {
    final completer = Completer<T>();

    // Get the previous future for this API or a completed one if it's the first call
    final previousFuture = _queues[apiId] ?? Future.value();

    // Chain the new call
    final newFuture = previousFuture.then((_) async {
      try {
        final result = await call();
        completer.complete(result);
      } catch (e, s) {
        completer.completeError(e, s);
      } finally {
        // Wait for the cooldown before the next request in the queue can start
        await Future<void>.delayed(cooldown);
      }
    });

    _queues[apiId] = newFuture;

    return completer.future;
  }
}
