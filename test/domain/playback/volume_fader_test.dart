import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/domain/playback/volume_fader.dart';

void main() {
  group('VolumeFader', () {
    test('fade should transition volume linearly', () async {
      final List<double> volumeSteps = [];
      final fader = VolumeFader();

      await fader.fade(
        from: 0.0,
        to: 1.0,
        duration: const Duration(milliseconds: 100),
        onUpdate: (v) => volumeSteps.add(v),
      );

      expect(volumeSteps.first, 0.0);
      expect(volumeSteps.last, 1.0);
      expect(volumeSteps.length, greaterThan(2));

      // Verify linearity (roughly)
      for (int i = 1; i < volumeSteps.length; i++) {
        expect(volumeSteps[i], greaterThan(volumeSteps[i - 1]));
      }
    });

    test('cancel should stop the fade immediately', () async {
      final List<double> volumeSteps = [];
      final fader = VolumeFader();

      final fadeFuture = fader.fade(
        from: 0.0,
        to: 1.0,
        duration: const Duration(milliseconds: 500),
        onUpdate: (v) => volumeSteps.add(v),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      fader.cancel();
      await fadeFuture;

      final countAfterCancel = volumeSteps.length;
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(volumeSteps.length, countAfterCancel);
      expect(volumeSteps.last, lessThan(1.0));
    });
  });
}
