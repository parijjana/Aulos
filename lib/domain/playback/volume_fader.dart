import 'dart:async';

class VolumeFader {
  Timer? _timer;
  Completer<void>? _completer;

  Future<void> fade({
    required double from,
    required double to,
    required Duration duration,
    required void Function(double) onUpdate,
    int steps = 20,
  }) async {
    cancel();
    _completer = Completer<void>();

    final stepDuration = Duration(
      milliseconds: duration.inMilliseconds ~/ steps,
    );
    final volumeDelta = (to - from) / steps;
    int currentStep = 0;

    _timer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      final currentVolume = (from + (volumeDelta * currentStep)).clamp(
        0.0,
        1.0,
      );
      onUpdate(currentVolume);

      if (currentStep >= steps) {
        cancel();
      }
    });

    // Initial update
    onUpdate(from);

    return _completer?.future;
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    if (_completer?.isCompleted == false) {
      _completer?.complete();
    }
  }
}
