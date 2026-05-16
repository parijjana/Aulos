import 'package:qr_secure_handshake/qr_secure_handshake.dart';

// Simulating a Host Server
void startHost() {
  // 1. Initialize the secure manager
  final handshake = HandshakeManager.generate();

  // 2. Prepare the QR code data
  const String ip = "192.168.1.10";
  const int port = 8080;
  final qrData = handshake.buildUri("ws://$ip:$port");

  // ignore: avoid_print
  print("HOST: Show this in a QR Code: $qrData");

  // 3. Handle incoming connection (logic placeholder)
  /*
  void onMessageReceived(dynamic socket, String encryptedMessage) {
    try {
      // 4. Decrypt incoming data using the session secret
      final plainText = handshake.decrypt(encryptedMessage);
      print("HOST: Decrypted message: $plainText");
      
      // Perform game logic...
      
      // 5. Encrypt outgoing broadcast
      final response = handshake.encrypt('{"type": "roundStarted", "target": 100}');
      // socket.send(response);
    } catch (e) {
      print("HOST: Unauthorized access attempt or tampered packet. Closing socket.");
      // socket.close();
    }
  }
  */
}
