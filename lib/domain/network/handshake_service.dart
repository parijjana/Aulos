abstract class HandshakeService {
  String get pin;
  String get secret;
  void generateNewPin();
  bool isTokenValid(String? token);
  String generateAndSaveToken();
  void saveHostToken(String hostName, String token);
  String? getSavedToken(String hostName);
  Future<void> deriveSessionKey(String sharedSecret);
  Future<String> encryptPayload(String plainText);
  Future<String> decryptPayload(String encryptedBase64);
}
