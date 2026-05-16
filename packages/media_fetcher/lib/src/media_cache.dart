import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;

class MediaCache {
  final String cachePath;

  MediaCache({required this.cachePath}) {
    _ensureDirectory();
  }

  void _ensureDirectory() {
    final dir = Directory(cachePath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  String _hash(String key) {
    return sha256.convert(utf8.encode(key)).toString();
  }

  Future<Uint8List?> get(String key) async {
    final file = File(p.join(cachePath, _hash(key)));
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  Future<void> put(String key, Uint8List data) async {
    final file = File(p.join(cachePath, _hash(key)));
    await file.writeAsBytes(data);
  }

  Future<void> clear() async {
    final dir = Directory(cachePath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      _ensureDirectory();
    }
  }
}
