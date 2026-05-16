import 'dart:async';

/// A simple rate limiter that enforces a minimum [cooldown] between task executions.
class RateLimiter {
  final Duration cooldown;
  Future<void> _lastTask = Future.value();

  RateLimiter({this.cooldown = const Duration(seconds: 1)});

  /// Enqueues a task and returns its result, ensuring at least [cooldown] 
  /// has passed since the *start* of the previous task's completion.
  Future<T> run<T>(Future<T> Function() task) {
    final completer = Completer<T>();

    final currentTask = _lastTask.then((_) async {
      try {
        final result = await task();
        completer.complete(result);
      } catch (e, s) {
        completer.completeError(e, s);
      } finally {
        // Wait for the cooldown before allowing the next task to proceed
        await Future<void>.delayed(cooldown);
      }
    });

    _lastTask = currentTask;
    return completer.future;
  }
}
