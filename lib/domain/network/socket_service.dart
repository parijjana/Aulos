import 'dart:convert';

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
  final Map<String, dynamic>? payload;

  MediaCommand({required this.type, this.payload});

  String toJson() => jsonEncode({'type': type.name, 'payload': payload});

  factory MediaCommand.fromJson(String source) {
    final data = jsonDecode(source) as Map<String, dynamic>;
    return MediaCommand(
      type: CommandType.values.byName(data['type'] as String),
      payload: data['payload'] as Map<String, dynamic>?,
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
