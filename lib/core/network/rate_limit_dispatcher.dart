import 'dart:async';

/// A universal rate limiter that manages multiple independent queues for different APIs.
class RateLimitDispatcher {
  final Map<String, Future<void>> _queues = {};
  
  /// Default cooldowns for known APIs to ensure "Good Citizen" behavior.
  static const Map<String, Duration> defaultCooldowns = {
    'itunes': Duration(milliseconds: 500),
    'musicbrainz': Duration(seconds: 1),
    'radio-browser': Duration(milliseconds: 200),
  };

  Future<T> dispatch<T>({
    required String apiId,
    required Future<T> Function() call,
    Duration? cooldown,
  }) {
    final completer = Completer<T>();
    final effectiveCooldown = cooldown ?? defaultCooldowns[apiId] ?? const Duration(seconds: 1);

    // Get the previous future for this API or a completed one
    final previousFuture = _queues[apiId] ?? Future.value();

    // Chain the new call
    final newFuture = previousFuture.then((_) async {
      try {
        final result = await call();
        completer.complete(result);
      } catch (e, s) {
        completer.completeError(e, s);
      } finally {
        await Future<void>.delayed(effectiveCooldown);
      }
    });

    _queues[apiId] = newFuture;

    return completer.future;
  }
}
