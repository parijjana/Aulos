import 'dart:convert';
import 'package:aulos/core/network/json_types.dart';

abstract class SocketService {
  // As Host
  Future<void> startServer(int port);
  Future<void> stopServer();
  int? get serverPort;

  // As Client
  Future<void> connect(String uri);
  Future<void> disconnect();

  // Common
  Future<void> sendCommand(MediaCommand command);
  Stream<MediaCommand> get commandStream;

  // Encryption Hooks
  void setEncryptionHooks({
    required Future<String> Function(String) encrypt,
    required Future<String> Function(String) decrypt,
  });
}

enum CommandType {
  play,
  pause,
  stop,
  seek,
  skipNext,
  skipPrev,
  getQueue,
  queueData,
  moveTrack,
  removeTrack,
  getLibrary,
  libraryData,
  getArt,
  artData,
  syncState,
  auth,
  unknown,
}

class MediaCommand {
  final CommandType type;
  final JsonMap? payload;

  MediaCommand({required this.type, this.payload});

  String toJson() => jsonEncode({'type': type.name, 'payload': payload});

  factory MediaCommand.fromJson(String source) {
    final data = jsonDecode(source) as JsonMap;
    return MediaCommand(
      type: CommandType.values.byName(data['type']?.toString() ?? ''),
      payload: data['payload'] as JsonMap?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaCommand &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}
