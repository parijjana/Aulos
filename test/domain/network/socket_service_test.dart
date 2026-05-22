import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/domain/network/socket_service.dart';

class MockSocketService extends Mock implements SocketService {}

void main() {
  late MockSocketService mockSocket;

  setUpAll(() {
    registerFallbackValue(MediaCommand(type: CommandType.play));
  });

  setUp(() {
    mockSocket = MockSocketService();
  });

  group('SocketService Interface', () {
    test('should send a command', () async {
      final command = MediaCommand(type: CommandType.play);
      when(() => mockSocket.sendCommand(any())).thenAnswer((_) async => {});

      await mockSocket.sendCommand(command);

      verify(() => mockSocket.sendCommand(command)).called(1);
    });

    test('should receive a stream of commands', () {
      final command = MediaCommand(type: CommandType.pause);
      when(
        () => mockSocket.commandStream,
      ).thenAnswer((_) => Stream.value(command));

      expect(mockSocket.commandStream, emits(command));
    });
  });
}
