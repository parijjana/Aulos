import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/domain/network/discovery_service.dart';
import 'package:aulos/domain/network/handshake_service.dart';
import 'package:aulos/domain/network/log_service.dart';

class MockConnectionManager extends Mock implements ConnectionManager {}

class MockDiscoveryService extends Mock implements DiscoveryService {}

class MockHandshakeService extends Mock implements HandshakeService {}

class MockMediaLogService extends Mock implements MediaLogService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ConnectivityViewModel viewModel;
  late MockConnectionManager mockManager;
  late MockDiscoveryService mockDiscovery;
  late MockHandshakeService mockHandshake;
  late MockMediaLogService mockLog;

  setUpAll(() {
    registerFallbackValue(DiscoveredDevice(name: 'f', ip: 'i', port: 0));
  });

  setUp(() {
    mockManager = MockConnectionManager();
    mockDiscovery = MockDiscoveryService();
    mockHandshake = MockHandshakeService();
    mockLog = MockMediaLogService();

    viewModel = ConnectivityViewModel(
      connectionManager: mockManager,
      discoveryService: mockDiscovery,
      handshakeService: mockHandshake,
      logService: mockLog,
    );
  });

  group('ConnectivityViewModel - Hosting', () {
    test('startHosting should initialize host on ConnectionManager', () async {
      when(
        () => mockManager.initHost(name: any(named: 'name')),
      ).thenAnswer((_) async => {});
      when(() => mockHandshake.secret).thenReturn('test_secret');

      await viewModel.startHosting(deviceName: 'My Phone');

      verify(() => mockManager.initHost(name: 'My Phone')).called(1);
      expect(viewModel.isHosting, isTrue);
      expect(viewModel.sessionSecret, 'test_secret');
    });

    test('stopHosting should reset state', () async {
      // Logic for stopHosting...
    });

    test(
      'isHosting should be true immediately after startHosting is called to prevent UI snap-back',
      () async {
        final completer = Completer<void>();
        when(
          () => mockManager.initHost(name: any(named: 'name')),
        ).thenAnswer((_) => completer.future);
        when(() => mockHandshake.secret).thenReturn('test_secret');

        final future = viewModel.startHosting(deviceName: 'My Phone');

        // If the fix is applied, this should be true. Currently it's false.
        expect(viewModel.isHosting, isTrue);

        completer.complete();
        await future;
        expect(viewModel.isHosting, isTrue);
      },
    );
  });

  group('ConnectivityViewModel - Discovery', () {
    test('startDiscovery should start discovery service', () async {
      when(
        () => mockDiscovery.deviceStream,
      ).thenAnswer((_) => Stream.fromIterable([[]]));
      when(() => mockDiscovery.scanForDevices()).thenAnswer((_) async => []);

      await viewModel.startDiscovery();

      verify(() => mockDiscovery.scanForDevices()).called(1);
      expect(viewModel.isScanning, isTrue);
    });
  });

  group('ConnectivityViewModel - Status', () {
    test('connectionStatus should map states correctly', () {
      when(() => mockManager.isAuthenticated).thenReturn(true);
      expect(viewModel.connectionStatus, 'Authenticated');

      when(() => mockManager.isAuthenticated).thenReturn(false);
      when(() => mockManager.isHost).thenReturn(true);
      expect(viewModel.connectionStatus, 'Hosting');

      when(() => mockManager.isHost).thenReturn(false);
      when(() => mockManager.isClient).thenReturn(true);
      expect(viewModel.connectionStatus, 'Connecting...');

      when(() => mockManager.isClient).thenReturn(false);
      expect(viewModel.connectionStatus, 'Disconnected');
    });
    group('ConnectivityViewModel - Connection', () {
      test('connectTo should call manager.connectToHost', () async {
        final device = DiscoveredDevice(
          name: 'Host',
          ip: '1.2.3.4',
          port: 8080,
        );
        when(
          () => mockManager.connectToHost(any(), any()),
        ).thenAnswer((_) async => {});

        await viewModel.connectTo(device, 'secret');

        verify(() => mockManager.connectToHost(device, 'secret')).called(1);
      });
    });
  });
}
