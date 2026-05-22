import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/domain/network/handshake_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late HandshakeService service;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getStringList(any())).thenReturn([]);
    when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);
    service = HandshakeService(mockPrefs);
  });

  group('HandshakeService', () {
    test('should generate a 6-digit PIN on initialization', () {
      final pin = service.pin;
      expect(pin.length, 6);
      expect(int.tryParse(pin), isNotNull);
    });

    test('should validate persistent tokens', () {
      when(() => mockPrefs.getStringList('authorized_tokens')).thenReturn(['token1', 'token2']);
      
      expect(service.isTokenValid('token1'), isTrue);
      expect(service.isTokenValid('token2'), isTrue);
      expect(service.isTokenValid('token3'), isFalse);
    });

    test('should generate and save new tokens', () {
      final token = service.generateAndSaveToken();
      expect(token, isNotEmpty);
      verify(() => mockPrefs.setStringList('authorized_tokens', any())).called(1);
    });

    test('should handle encryption lifecycle (derive key -> encrypt -> decrypt)', () async {
      const secret = 'shared-secret-123';
      const payload = 'Sensitive Data';

      await service.deriveSessionKey(secret);
      
      final encrypted = await service.encryptPayload(payload);
      expect(encrypted, isNot(payload));

      final decrypted = await service.decryptPayload(encrypted);
      expect(decrypted, payload);
    });

    test('should return original text if decryption fails or key not derived', () async {
      const payload = 'No Key Yet';
      final result = await service.decryptPayload(payload);
      expect(result, payload);
    });
  });
}
