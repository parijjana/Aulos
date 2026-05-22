import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/domain/network/discovery_service.dart';

class MockDiscoveryService extends Mock implements DiscoveryService {}

void main() {
  late MockDiscoveryService mockDiscovery;

  setUp(() {
    mockDiscovery = MockDiscoveryService();
  });

  group('DiscoveryService Interface', () {
    test('should start broadcasting service info', () async {
      when(
        () => mockDiscovery.startBroadcasting(any()),
      ).thenAnswer((_) async => {});

      await mockDiscovery.startBroadcasting('My Player');

      verify(() => mockDiscovery.startBroadcasting('My Player')).called(1);
    });

    test('should scan for other services', () async {
      final mockDevices = [
        DiscoveredDevice(name: 'Phone 1', ip: '192.168.1.10', port: 8080),
      ];

      when(
        () => mockDiscovery.scanForDevices(),
      ).thenAnswer((_) async => mockDevices);

      final result = await mockDiscovery.scanForDevices();

      expect(result, mockDevices);
      verify(() => mockDiscovery.scanForDevices()).called(1);
    });
  });
}
