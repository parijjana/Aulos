import 'dart:typed_data';
import 'dart:convert';
import 'package:xxh3/xxh3.dart';

String generateContentId(String fingerprint) {
  final bytes = Uint8List.fromList(utf8.encode(fingerprint));
  final hashVal = xxh3(bytes);
  if (hashVal >= 0) return hashVal.toRadixString(36);
  final BigInt unsigned = BigInt.from(hashVal).toUnsigned(64);
  return unsigned.toRadixString(36);
}
