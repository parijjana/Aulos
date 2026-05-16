import 'package:themer_flutter/themer_flutter.dart';

class ObsidianAudioTheme {
  static const String _json = '''
  {
    "version": "1",
    "name": "Obsidian Audio",
    "colors": {
      "primary": "#00F0FF",
      "onPrimary": "#001F22",
      "primaryContainer": "#004F54",
      "onPrimaryContainer": "#97F4FF",
      "secondary": "#B0CCC0",
      "onSecondary": "#1C352D",
      "surface": "#1A1C1E",
      "onSurface": "#E2E2E6",
      "surfaceVariant": "#40484B",
      "onSurfaceVariant": "#C0C8CB",
      "background": "#000000",
      "onBackground": "#E2E2E6",
      "outline": "#8A9295",
      "error": "#FFB4AB",
      "onError": "#690005"
    },
    "typography": {
      "fontFamily": "Inter",
      "headingSize": 36.0,
      "bodySize": 16.0,
      "labelSize": 14.0
    },
    "effects": {
      "roundness": 28.0,
      "elevation": 0.0
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
