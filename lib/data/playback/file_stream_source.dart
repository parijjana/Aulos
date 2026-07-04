import 'dart:io';
import 'package:just_audio/just_audio.dart';

// ignore: EXPERIMENTAL_MEMBER_USE
/// A custom [StreamAudioSource] that opens the file in Dart and streams bytes.
/// This bypasses native filename/Unicode parsing issues on some platforms (like Windows).
// ignore: EXPERIMENTAL_MEMBER_USE
class FileStreamSource extends StreamAudioSource {
  final File file;
  final String contentType;

  FileStreamSource(this.file, {this.contentType = 'audio/mpeg'});

  @override
  // ignore: EXPERIMENTAL_MEMBER_USE
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final int size = await file.length();
    final int effectiveStart = start ?? 0;
    final int effectiveEnd = end ?? size;
    
    // ignore: EXPERIMENTAL_MEMBER_USE
    return StreamAudioResponse(
      sourceLength: size,
      contentLength: effectiveEnd - effectiveStart,
      offset: effectiveStart,
      stream: file.openRead(effectiveStart, effectiveEnd),
      contentType: contentType,
    );
  }
}
