import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:mocktail/mocktail.dart';

class MockApiCall extends Mock {
  Future<String> call();
}

void main() {
  late RateLimitDispatcher dispatcher;

  setUp(() {
    dispatcher = RateLimitDispatcher();
  });

  group('RateLimitDispatcher', () {
    test(
      'should execute multiple calls to same API sequentially with cooldown',
      () async {
        final mockCall = MockApiCall();
        when(() => mockCall.call()).thenAnswer((_) async => 'Success');

        final startTime = DateTime.now();

        // Dispatch 2 calls with 100ms cooldown
        final f1 = dispatcher.dispatch(
          apiId: 'test_api',
          call: mockCall.call,
          cooldown: const Duration(milliseconds: 100),
        );
        final f2 = dispatcher.dispatch(
          apiId: 'test_api',
          call: mockCall.call,
          cooldown: const Duration(milliseconds: 100),
        );

        await Future.wait([f1, f2]);
        final endTime = DateTime.now();

        // The second call must have waited at least 100ms
        expect(
          endTime.difference(startTime).inMilliseconds,
          greaterThanOrEqualTo(100),
        );
        verify(() => mockCall.call()).called(2);
      },
    );

    test('should execute calls to different APIs independently', () async {
      final mockCall1 = MockApiCall();
      final mockCall2 = MockApiCall();
      when(() => mockCall1.call()).thenAnswer((_) async => 'Success 1');
      when(() => mockCall2.call()).thenAnswer((_) async => 'Success 2');

      final startTime = DateTime.now();

      // Dispatch 2 calls to different APIs
      final f1 = dispatcher.dispatch(
        apiId: 'api_1',
        call: mockCall1.call,
        cooldown: const Duration(milliseconds: 500),
      );
      final f2 = dispatcher.dispatch(
        apiId: 'api_2',
        call: mockCall2.call,
        cooldown: const Duration(milliseconds: 500),
      );

      await Future.wait([f1, f2]);
      final endTime = DateTime.now();

      // They should both finish much faster than 500ms since they are independent
      expect(endTime.difference(startTime).inMilliseconds, lessThan(500));
      verify(() => mockCall1.call()).called(1);
      verify(() => mockCall2.call()).called(1);
    });
  });
}
