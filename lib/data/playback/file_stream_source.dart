import 'dart:io';
import 'package:just_audio/just_audio.dart';

/// A custom [StreamAudioSource] that opens the file in Dart and streams bytes.
/// This bypasses native filename/Unicode parsing issues on some platforms (like Windows).
class FileStreamSource extends StreamAudioSource {
  final File file;
  final String contentType;

  FileStreamSource(this.file, {this.contentType = 'audio/mpeg'});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final int size = await file.length();
    final int effectiveStart = start ?? 0;
    final int effectiveEnd = end ?? size;
    
    return StreamAudioResponse(
      sourceLength: size,
      contentLength: effectiveEnd - effectiveStart,
      offset: effectiveStart,
      stream: file.openRead(effectiveStart, effectiveEnd),
      contentType: contentType,
    );
  }
}
