import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:themer_flutter/themer_flutter.dart';

void main() {
  group('AulosAudioTheme', () {
    testWidgets('should apply the Aulos Audio theme correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThemerProvider(
            theme: AulosAudioTheme.model,
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return Column(
                  children: [
                    Text(
                      'Primary Color',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                    Text(
                      'Surface Color',
                      style: TextStyle(color: theme.colorScheme.surface),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final primaryText = tester.widget<Text>(find.text('Primary Color'));
      final surfaceText = tester.widget<Text>(find.text('Surface Color'));

      expect(primaryText.style?.color, AulosAudioTheme.model.colors.primary);
      expect(surfaceText.style?.color, AulosAudioTheme.model.colors.surface);
    });
  });
}
