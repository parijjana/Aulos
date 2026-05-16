import 'package:themer_flutter/themer_flutter.dart';

class InvertedHatchedTheme {
  static const String _json = '''
  {
    "version": "1.2.0",
    "name": "Inverted Hatched",
    "colors": {
      "primary": "#000000",
      "secondary": "#E0E0E0",
      "background": "#000000",
      "surface": "#1A1A1A",
      "onPrimary": "#FFFFFF",
      "onSecondary": "#000000",
      "onBackground": "#FFFFFF",
      "onSurface": "#FFFFFF"
    },
    "typography": {
      "headingFont": "Inter",
      "bodyFont": "Inter"
    },
    "effects": {
      "roundness": 4.0,
      "elevation": 0.0,
      "opacity": 1.0,
      "blur": 0.0,
      "style": "hatched"
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
