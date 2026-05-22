import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/domain/network/discovery_service.dart';
import 'package:aulos/domain/network/handshake_service.dart';
import 'package:aulos/domain/network/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aulos/domain/network/log_service.dart';

class MockDiscoveryService extends Mock implements DiscoveryService {}

class MockHandshakeService extends Mock implements HandshakeService {}

class MockSocketService extends Mock implements SocketService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockMediaLogService extends Mock implements MediaLogService {}

void main() {
  late MockDiscoveryService mockDiscovery;
  late MockHandshakeService mockHandshake;
  late MockSocketService mockSocket;
  late MockSharedPreferences mockPrefs;
  late MockMediaLogService mockLog;

  setUpAll(() {
    registerFallbackValue(MediaCommand(type: CommandType.play));
  });

  void setupMocks() {
    mockDiscovery = MockDiscoveryService();
    mockHandshake = MockHandshakeService();
    mockSocket = MockSocketService();
    mockPrefs = MockSharedPreferences();
    mockLog = MockMediaLogService();

    when(() => mockSocket.commandStream).thenAnswer((_) => const Stream.empty());
    when(() => mockSocket.sendCommand(any())).thenAnswer((_) async => {});
    when(() => mockSocket.startServer(any())).thenAnswer((_) async => {});
    when(() => mockSocket.stopServer()).thenAnswer((_) async => {});
    when(() => mockSocket.connect(any())).thenAnswer((_) async => {});
    when(() => mockSocket.disconnect()).thenAnswer((_) async => {});
    when(() => mockDiscovery.startBroadcasting(any())).thenAnswer((_) async => {});
    when(() => mockDiscovery.stopBroadcasting()).thenAnswer((_) async => {});
    when(() => mockSocket.setEncryptionHooks(
      encrypt: any(named: 'encrypt'),
      decrypt: any(named: 'decrypt'),
    )).thenReturn(null);
    
    // CRITICAL: Stub handshake methods used in connectToHost
    when(() => mockHandshake.deriveSessionKey(any())).thenAnswer((_) async => {});
    when(() => mockHandshake.pin).thenReturn('123456');
    when(() => mockHandshake.isTokenValid(any())).thenReturn(false);
  }

  group('ConnectionManager', () {
    test('Host Side: should emit syncState if client secret matches PIN', () async {
      setupMocks();
      final commandStream = StreamController<MediaCommand>.broadcast();
      when(() => mockSocket.commandStream).thenAnswer((_) => commandStream.stream);
      
      when(() => mockHandshake.deriveSessionKey(any())).thenAnswer((_) async => {});
      when(() => mockHandshake.generateAndSaveToken()).thenReturn('new_token');
      when(() => mockHandshake.generateNewPin()).thenReturn(null);

      final manager = ConnectionManager(
        discovery: mockDiscovery,
        handshake: mockHandshake,
        socket: mockSocket,
        prefs: mockPrefs,
        logService: mockLog,
      );

      await manager.initHost(name: 'Host');

      final List<MediaCommand> receivedCommands = [];
      final sub = manager.remoteCommands.listen(receivedCommands.add);

      commandStream.add(MediaCommand(type: CommandType.auth, payload: {'secret': '123456'}));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedCommands.any((c) => c.type == CommandType.syncState), isTrue);
      
      await sub.cancel();
      manager.dispose();
      await commandStream.close();
    });

    test('Client Side: should become authenticated upon receiving syncState from Host', () async {
      setupMocks();
      final commandStream = StreamController<MediaCommand>.broadcast();
      when(() => mockSocket.commandStream).thenAnswer((_) => commandStream.stream);

      final manager = ConnectionManager(
        discovery: mockDiscovery,
        handshake: mockHandshake,
        socket: mockSocket,
        prefs: mockPrefs,
        logService: mockLog,
      );

      final device = DiscoveredDevice(name: 'Host', ip: '1.2.3.4', port: 8080);
      await manager.connectToHost(device, 'some_secret');

      expect(manager.isAuthenticated, isFalse);

      commandStream.add(MediaCommand(type: CommandType.syncState));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(manager.isAuthenticated, isTrue);
      
      manager.dispose();
      await commandStream.close();
    });
  });
}
