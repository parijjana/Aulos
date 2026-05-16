import 'dart:async';
import 'package:localaudioplayer/domain/network/discovery_service.dart';
import 'package:localaudioplayer/domain/network/handshake_service.dart';
import 'package:localaudioplayer/domain/network/socket_service.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

enum ConnectionRole { none, host, client }

class ConnectionManager extends ChangeNotifier {
  final DiscoveryService _discovery;
  final HandshakeService _handshake;
  final SocketService _socket;
  final SharedPreferences _prefs;
  final MediaLogService _logService;

  bool _isAuthenticated = false;
  ConnectionRole _role = ConnectionRole.none;
  String? _connectedHostName;

  final List<Map<String, String>> _connectedDevices = [];
  List<String> _bannedDeviceIds = [];

  final _commandController = StreamController<MediaCommand>.broadcast();
  StreamSubscription<MediaCommand>? _socketSub;

  ConnectionManager({
    required DiscoveryService discovery,
    required HandshakeService handshake,
    required SocketService socket,
    required SharedPreferences prefs,
    required MediaLogService logService,
  }) : _discovery = discovery,
       _handshake = handshake,
       _socket = socket,
       _prefs = prefs,
       _logService = logService {
    _loadBannedDevices();
    _socket.setEncryptionHooks(
      encrypt: (data) => _handshake.encryptPayload(data),
      decrypt: (data) => _handshake.decryptPayload(data),
    );
    _listenToSocket();
  }

  void _loadBannedDevices() {
    _bannedDeviceIds = _prefs.getStringList('banned_device_ids') ?? [];
  }

  bool get isAuthenticated => _isAuthenticated;
  ConnectionRole get role => _role;
  bool get isHost => _role == ConnectionRole.host;
  bool get isClient => _role == ConnectionRole.client;
  String? get connectedHostName => _connectedHostName;
  List<Map<String, String>> get connectedDevices =>
      List.unmodifiable(_connectedDevices);
  Stream<MediaCommand> get remoteCommands => _commandController.stream;

  void _listenToSocket() {
    _socketSub = _socket.commandStream.listen(
      (command) {
        _processIncomingCommand(command);
      },
      onError: (Object err) {
        _logService.log('ERROR: Socket error - $err');
        _isAuthenticated = false;
        notifyListeners();
      },
    );
  }

  Future<void> _processIncomingCommand(MediaCommand command) async {
    _logService.log('RECV: ${command.type.name}');

    if (isHost && command.type == CommandType.auth) {
      final secret = command.payload?['secret'] as String?;
      final deviceId = command.payload?['deviceId'] as String?;
      final deviceName =
          command.payload?['deviceName'] as String? ?? 'Unknown Remote';

      if (deviceId != null && _bannedDeviceIds.contains(deviceId)) {
        _logService.log('AUTH: Blocked banned device $deviceName ($deviceId)');
        return;
      }

      final isPinValid =
          secret == _handshake.pin || secret == 'dev-phase-no-auth';
      final isTokenValid = _handshake.isTokenValid(secret);

      if (secret != null && (isPinValid || isTokenValid)) {
        _logService.log('AUTH: Validating credentials from $deviceName...');

        if (secret != 'dev-phase-no-auth') {
          await _handshake.deriveSessionKey(secret);
        }

        _isAuthenticated = true;
        _connectedDevices.add({
          'name': deviceName,
          'id': deviceId ?? 'unknown',
        });

        String clientToken = secret;
        if (isPinValid && secret != 'dev-phase-no-auth') {
          clientToken = _handshake.generateAndSaveToken();
          _handshake.generateNewPin();
        }

        await sendCommand(
          MediaCommand(
            type: CommandType.syncState,
            payload: {
              'status': 'success',
              'message': 'Handshake complete',
              'token': clientToken,
            },
          ),
        );

        _commandController.add(MediaCommand(type: CommandType.syncState));
        notifyListeners();
      } else {
        _logService.log(
          'AUTH: Handshake failed - Invalid secret from $deviceName',
        );
      }
    } else if (isClient && command.type == CommandType.syncState) {
      if (!_isAuthenticated) {
        _logService.log('SYNC: Handshake confirmed by host.');
        _isAuthenticated = true;

        final token = command.payload?['token'] as String?;
        if (token != null && _connectedHostName != null) {
          _handshake.saveHostToken(_connectedHostName!, token);
          _logService.log('AUTH: Saved persistent token for host');
        }

        notifyListeners();
      }
      _commandController.add(command);
    } else {
      if (_isAuthenticated || isHost) {
        _commandController.add(command);
      }
    }
  }

  Future<void> initHost({required String name, int port = 8080}) async {
    _logService.log('HOST: Starting server on port $port...');
    await _socket.startServer(port);
    await _discovery.startBroadcasting(name);
    _role = ConnectionRole.host;
    _isAuthenticated = true;
    _logService.log('HOST: Server ready.');
    notifyListeners();
  }

  Future<void> stopHosting() async {
    _logService.log('HOST: Stopping server...');
    await _discovery.stopBroadcasting();
    await _socket.stopServer();
    _role = ConnectionRole.none;
    _isAuthenticated = false;
    _connectedDevices.clear();
    _logService.log('HOST: Server stopped.');
    notifyListeners();
  }

  Future<void> connectToHost(
    DiscoveredDevice device,
    String secret, {
    String? deviceId,
    String? deviceName,
  }) async {
    final uri = 'ws://${device.ip}:${device.port}';
    _logService.log('CLIENT: Connecting to $uri...');
    _role = ConnectionRole.client;
    _connectedHostName = device.name;
    notifyListeners();

    try {
      // Add timeout to connection attempt
      await _socket.connect(uri).timeout(const Duration(seconds: 5));

      if (secret != 'dev-phase-no-auth' && secret.isNotEmpty) {
        _logService.log('CLIENT: Deriving secure session key...');
        await _handshake.deriveSessionKey(secret);
      }

      _logService.log('CLIENT: Sending authentication...');
      await _socket.sendCommand(
        MediaCommand(
          type: CommandType.auth,
          payload: {
            'secret': secret,
            'deviceId': deviceId,
            'deviceName': deviceName,
          },
        ),
      );
    } catch (e) {
      _logService.log('CLIENT: Connection failed - $e');
      _role = ConnectionRole.none;
      _connectedHostName = null;
    }
    notifyListeners();
  }

  void banDevice(String id) {
    if (!_bannedDeviceIds.contains(id)) {
      _bannedDeviceIds.add(id);
      _prefs.setStringList('banned_device_ids', _bannedDeviceIds);
      _connectedDevices.removeWhere((d) => d['id'] == id);
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _logService.log('NETWORK: Disconnecting...');
    await _socket.disconnect();
    _role = ConnectionRole.none;
    _isAuthenticated = false;
    _connectedHostName = null;
    _connectedDevices.clear();
    notifyListeners();
  }

  Future<void> sendCommand(MediaCommand command) async {
    if (_isAuthenticated || isHost) {
      await _socket.sendCommand(command);
    }
  }

  void broadcastState({
    required String title,
    required String artist,
    String? album,
    required bool isPlaying,
    required int positionMs,
    required int durationMs,
  }) {
    if (isHost && _isAuthenticated) {
      sendCommand(
        MediaCommand(
          type: CommandType.syncState,
          payload: {
            'title': title,
            'artist': artist,
            'album': album,
            'isPlaying': isPlaying,
            'positionMs': positionMs,
            'durationMs': durationMs,
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }
}
