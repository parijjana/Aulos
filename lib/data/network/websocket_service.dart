import 'dart:async';
import 'dart:io';
import 'package:aulos/domain/network/socket_service.dart';
import 'package:flutter/foundation.dart';

class WebSocketService implements SocketService {
  HttpServer? _server;
  final List<WebSocket> _serverSockets = [];
  WebSocket? _clientSocket;

  final _commandController = StreamController<MediaCommand>.broadcast();

  Future<String> Function(String)? _encryptHook;
  Future<String> Function(String)? _decryptHook;

  @override
  Stream<MediaCommand> get commandStream => _commandController.stream;

  @override
  int? get serverPort => _server?.port;

  @override
  void setEncryptionHooks({
    required Future<String> Function(String) encrypt,
    required Future<String> Function(String) decrypt,
  }) {
    _encryptHook = encrypt;
    _decryptHook = decrypt;
  }

  @override
  Future<void> startServer(int port) async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server!.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((socket) {
          _serverSockets.add(socket);
          debugPrint('WS_SERVER: New connection upgraded.');
          socket.listen(
            (data) => _handleIncomingData(data),
            onDone: () {
              _serverSockets.remove(socket);
              debugPrint('WS_SERVER: Connection closed.');
            },
            onError: (Object err) {
              debugPrint('WS_SERVER: Socket error: $err');
              _serverSockets.remove(socket);
            },
          );
        });
      }
    });
  }

  void _handleIncomingData(dynamic data) async {
    String raw = data.toString();
    if (_decryptHook != null) {
      raw = await _decryptHook!(raw);
    }
    try {
      _commandController.add(MediaCommand.fromJson(raw));
    } catch (e) {
      debugPrint('WS_ERROR: Failed to parse command: $e');
    }
  }

  @override
  Future<void> connect(String uri) async {
    _clientSocket = await WebSocket.connect(uri);
    debugPrint('WS_CLIENT: Connected to $uri');
    _clientSocket!.listen(
      (data) => _handleIncomingData(data),
      onDone: () {
        debugPrint('WS_CLIENT: Connection closed.');
        _clientSocket = null;
      },
      onError: (Object err) {
        debugPrint('WS_CLIENT: Socket error: $err');
        _clientSocket = null;
      },
    );
  }

  @override
  Future<void> disconnect() async {
    await _clientSocket?.close();
    _clientSocket = null;
  }

  @override
  Future<void> stopServer() async {
    final sockets = List<WebSocket>.from(_serverSockets);
    for (final socket in sockets) {
      await socket.close();
    }
    _serverSockets.clear();
    await _server?.close();
    _server = null;
  }

  @override
  Future<void> sendCommand(MediaCommand command) async {
    String json = command.toJson();
    final bool isHandshake =
        command.type == CommandType.auth ||
        (command.type == CommandType.syncState &&
            command.payload?['status'] == 'success');

    if (_encryptHook != null && !isHandshake) {
      json = await _encryptHook!(json);
    }

    if (_clientSocket != null) {
      debugPrint('WS_CLIENT: Sending: $json');
      _clientSocket!.add(json);
    }
    for (final socket in _serverSockets) {
      debugPrint('WS_SERVER: Broadcasting: $json');
      socket.add(json);
    }
  }
}
