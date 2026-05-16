import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/domain/network/connection_manager.dart';
import 'package:localaudioplayer/domain/network/discovery_service.dart';
import 'package:localaudioplayer/domain/network/handshake_service.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:io';

import 'package:localaudioplayer/domain/network/log_service.dart';

class ConnectivityViewModel extends ChangeNotifier {
  final ConnectionManager _connectionManager;
  final DiscoveryService _discoveryService;
  final HandshakeService _handshakeService;
  final MediaLogService _logService;
  final _appLinks = AppLinks();

  // FIXED: Removed network_info_plus as it triggers Location permissions on Windows.
  // We use standard dart:io NetworkInterface instead.

  StreamSubscription<Uri>? _linkSub;

  bool _isHosting = false;
  bool _isScanning = false;
  String? _sessionSecret;
  String? _localIp;
  List<DiscoveredDevice> _discoveredDevices = [];

  ConnectivityViewModel({
    required ConnectionManager connectionManager,
    required DiscoveryService discoveryService,
    required HandshakeService handshakeService,
    required MediaLogService logService,
  }) : _connectionManager = connectionManager,
       _discoveryService = discoveryService,
       _handshakeService = handshakeService,
       _logService = logService {
    _initDeepLinks();
    _updateLocalIp();
    _listenToConnectionManager();
    _logService.addListener(notifyListeners);
  }

  void _listenToConnectionManager() {
    _connectionManager.addListener(() {
      if (_connectionManager.isAuthenticated && _isScanning) {
        stopDiscovery();
      }
      notifyListeners();
    });
  }

  List<String> get logs => _logService.logs;
  void clearLogs() => _logService.clear();

  Future<void> _updateLocalIp() async {
    try {
      // Use standard dart:io to get IP. This does NOT trigger location permission.
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            _localIp = addr.address;
            break;
          }
        }
        if (_localIp != null) break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting IP: $e');
    }
  }

  void _initDeepLinks() {
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Deep link received: $uri');
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'localaudio' && uri.host == 'connect') {
      final ip = uri.queryParameters['ip'];
      final portStr = uri.queryParameters['port'];
      final secret = uri.queryParameters['secret'];

      if (ip != null && portStr != null && secret != null) {
        final port = int.tryParse(portStr) ?? 8080;
        final device = DiscoveredDevice(name: 'QR Device', ip: ip, port: port);
        _connectionManager.connectToHost(device, secret);
      }
    }
  }

  Future<void> connectByUrl(String input) async {
    try {
      final trimmed = input.trim();
      if (trimmed.startsWith('localaudio://')) {
        final uri = Uri.parse(trimmed);
        _handleDeepLink(uri);
      } else {
        final parts = trimmed.split(':');
        if (parts.length == 2) {
          final ip = parts[0];
          final port = int.tryParse(parts[1]) ?? 8080;
          final device = DiscoveredDevice(
            name: 'Manual Device',
            ip: ip,
            port: port,
          );
          await connectTo(device, 'dev-phase-no-auth');
        }
      }
    } catch (e) {
      debugPrint('Invalid input: $e');
    }
  }

  bool get isHosting => _isHosting;
  bool get isScanning => _isScanning;
  bool get isHostMode => _connectionManager.isHost;
  bool get isRemoteMode => _connectionManager.isClient;
  String? get sessionSecret => _sessionSecret;
  String? get localIp => _localIp;
  int get port => 8080;
  List<DiscoveredDevice> get discoveredDevices => _discoveredDevices;
  List<Map<String, String>> get connectedDevices =>
      _connectionManager.connectedDevices;

  String get connectionStatus {
    if (_connectionManager.isAuthenticated) return 'Authenticated';
    if (_connectionManager.isHost) return 'Hosting';
    if (_connectionManager.isClient) return 'Connecting...';
    return 'Disconnected';
  }

  Future<void> startHosting({required String deviceName}) async {
    _isHosting = true;
    notifyListeners();
    try {
      await _updateLocalIp();
      await _connectionManager.initHost(name: deviceName);
      _sessionSecret = _handshakeService.secret;
    } catch (e) {
      _isHosting = false;
      _sessionSecret = null;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> stopHosting() async {
    _isHosting = false;
    _sessionSecret = null;
    notifyListeners();
    try {
      await _connectionManager.stopHosting();
    } catch (e) {
      // If it fails to stop, maybe we should set it back to true?
      // But usually stopHosting is reliable.
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> startDiscovery() async {
    _isScanning = true;
    notifyListeners();

    _discoveryService.deviceStream.listen((devices) {
      _discoveredDevices = devices;
      notifyListeners();
    });

    await _discoveryService.scanForDevices();
  }

  Future<void> stopDiscovery() async {
    _isScanning = false;
    notifyListeners();
  }

  String? getSavedToken(String hostName) =>
      _handshakeService.getSavedToken(hostName);

  Future<void> connectTo(
    DiscoveredDevice device,
    String secret, {
    String? deviceId,
    String? deviceName,
  }) async {
    String finalSecret = secret;
    final token = getSavedToken(device.name);
    if (token != null && secret.isEmpty) {
      finalSecret = token;
    }
    await _connectionManager.connectToHost(
      device,
      finalSecret,
      deviceId: deviceId,
      deviceName: deviceName,
    );
    notifyListeners();
  }

  void banDevice(String id) {
    _connectionManager.banDevice(id);
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_isHosting) {
      await stopHosting();
    } else {
      await _connectionManager.disconnect();
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }
}
