import 'package:flutter_test/flutter_test.dart';
import 'package:media_fetcher/media_fetcher.dart';

void main() {
  group('RateLimiter', () {
    test('should execute tasks sequentially with cooldown', () async {
      final limiter = RateLimiter(cooldown: const Duration(milliseconds: 100));
      final stopwatch = Stopwatch()..start();
      
      final List<int> results = [];
      
      final f1 = limiter.run(() async {
        results.add(1);
        return 1;
      });
      
      final f2 = limiter.run(() async {
        results.add(2);
        return 2;
      });
      
      await Future.wait([f1, f2]);
      
      final elapsed = stopwatch.elapsedMilliseconds;
      
      // First task starts immediately.
      // Second task starts after first task completes + 100ms cooldown.
      expect(results, [1, 2]);
      expect(elapsed, greaterThanOrEqualTo(100));
    });

    test('should handle errors without breaking the queue', () async {
      final limiter = RateLimiter(cooldown: const Duration(milliseconds: 10));
      
      final f1 = limiter.run(() async => throw Exception('Fail'));
      final f2 = limiter.run(() async => 'Success');
      
      expect(f1, throwsException);
      expect(await f2, 'Success');
    });
  });
}
