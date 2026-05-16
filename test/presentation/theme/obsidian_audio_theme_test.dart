import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localaudioplayer/presentation/theme/obsidian_audio_theme.dart';
import 'package:themer_flutter/themer_flutter.dart';

void main() {
  group('ObsidianAudioTheme', () {
    testWidgets('should apply the Obsidian Audio theme correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThemerProvider(
            theme: ObsidianAudioTheme.model,
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

      expect(primaryText.style?.color, ObsidianAudioTheme.model.colors.primary);
      expect(surfaceText.style?.color, ObsidianAudioTheme.model.colors.surface);
    });
  });
}
