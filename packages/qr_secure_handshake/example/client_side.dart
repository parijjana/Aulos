import 'package:qr_secure_handshake/qr_secure_handshake.dart';

// Simulating a Client
void startClient(String scannedQrData) {
  // 1. Extract the secret from the QR code
  final uri = Uri.parse(scannedQrData);
  final secret = uri.queryParameters['secret'];

  if (secret == null) {
    // ignore: avoid_print
    print("CLIENT: Invalid QR code format.");
    return;
  }

  // 2. Initialize the manager with the scanned secret
  final handshake = HandshakeManager.fromSecret(secret);

  // ignore: avoid_print
  print("CLIENT: Authorized. Initialized encryption engine.");

  // 3. Handle incoming broadcast (logic placeholder)
  /*
  void onBroadcastReceived(String encryptedPayload) {
    try {
      final json = handshake.decrypt(encryptedPayload);
      print("CLIENT: Received secure update: $json");
    } catch (e) {
      print("CLIENT: Failed to decrypt. Host key may have rotated.");
    }
  }
  */

  // 4. Send secure submission
  final _ = handshake.encrypt('{"type": "submit", "expression": "10+5"}');
  // socket.send(encrypted);
}
