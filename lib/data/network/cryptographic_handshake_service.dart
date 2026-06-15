import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:aulos/domain/network/handshake_service.dart';

class CryptographicHandshakeService implements HandshakeService {
  final SharedPreferences _prefs;
  String _currentPin = '';
  final _uuid = const Uuid();
  final _cipher = AesGcm.with256bits();

  SecretKey? _sessionKey;

  CryptographicHandshakeService(this._prefs) {
    _generatePin();
  }

  void _generatePin() {
    final random = Random();
    _currentPin = (random.nextInt(900000) + 100000).toString(); // 6 digits
  }

  @override
  String get pin => _currentPin;
  
  @override
  String get secret => _currentPin;

  @override
  void generateNewPin() {
    _generatePin();
  }

  @override
  bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    final savedTokens = _prefs.getStringList('authorized_tokens') ?? [];
    return savedTokens.contains(token);
  }

  @override
  String generateAndSaveToken() {
    final token = _uuid.v4();
    final savedTokens = _prefs.getStringList('authorized_tokens') ?? [];
    savedTokens.add(token);
    _prefs.setStringList('authorized_tokens', savedTokens);
    return token;
  }

  @override
  void saveHostToken(String hostName, String token) {
    _prefs.setString('host_token_$hostName', token);
  }

  @override
  String? getSavedToken(String hostName) {
    return _prefs.getString('host_token_$hostName');
  }

  // --- Encryption Layer ---

  @override
  Future<void> deriveSessionKey(String sharedSecret) async {
    // Offload to isolate to prevent UI freeze
    _sessionKey = await compute(_deriveKeyTask, sharedSecret);
  }

  static Future<SecretKey> _deriveKeyTask(String sharedSecret) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final salt = utf8.encode('AulosLocalAudioSalt');
    return await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(sharedSecret)),
      nonce: salt,
    );
  }

  @override
  Future<String> encryptPayload(String plainText) async {
    if (_sessionKey == null) return plainText;

    final nonce = _cipher.newNonce();
    final secretBox = await _cipher.encrypt(
      utf8.encode(plainText),
      secretKey: _sessionKey!,
      nonce: nonce,
    );

    final combined = Uint8List.fromList([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    return base64.encode(combined);
  }

  @override
  Future<String> decryptPayload(String encryptedBase64) async {
    if (_sessionKey == null) return encryptedBase64;

    try {
      final combined = base64.decode(encryptedBase64);
      if (combined.length < 28) {
        return encryptedBase64; // Nonce(12) + Mac(16) minimum
      }

      final nonce = combined.sublist(0, 12);
      final mac = combined.sublist(combined.length - 16);
      final cipherText = combined.sublist(12, combined.length - 16);

      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));

      final clearText = await _cipher.decrypt(
        secretBox,
        secretKey: _sessionKey!,
      );
      return utf8.decode(clearText);
    } catch (e) {
      return encryptedBase64;
    }
  }
}
