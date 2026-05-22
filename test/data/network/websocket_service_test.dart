import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/network/websocket_service.dart';
import 'package:aulos/domain/network/socket_service.dart';

void main() {
  late WebSocketService service;

  setUp(() {
    service = WebSocketService();
  });

  tearDown(() async {
    await service.stopServer();
    await service.disconnect();
  });

  group('WebSocketService - Integration', () {
    test('should be able to start a server and connect as client', () async {
      // 1. Start Server (Host)
      await service.startServer(0); // Random port
      final port = service.serverPort!;

      // 2. Connect (Client)
      final clientService = WebSocketService();
      await clientService.connect('ws://localhost:$port');

      // 3. Send command from client to host
      final clientCommand = MediaCommand(type: CommandType.play);
      await clientService.sendCommand(clientCommand);

      // 4. Verify host receives command
      final receivedCommand = await service.commandStream.first;
      expect(receivedCommand.type, CommandType.play);

      await clientService.disconnect();
    });

    test('should be able to send command from host to client', () async {
      await service.startServer(0);
      final port = service.serverPort!;

      final clientService = WebSocketService();
      await clientService.connect('ws://localhost:$port');

      // Wait for connection to be established on server side
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final hostCommand = MediaCommand(type: CommandType.pause);
      await service.sendCommand(hostCommand);

      final receivedCommand = await clientService.commandStream.first;
      expect(receivedCommand.type, CommandType.pause);

      await clientService.disconnect();
    });
  });
}
