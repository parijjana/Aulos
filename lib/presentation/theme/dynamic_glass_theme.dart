import 'package:themer_flutter/themer_flutter.dart';

class DynamicGlassTheme {
  static const String _json = '''
  {
    "version": "1.2.0",
    "name": "Dynamic Glass",
    "colors": {
      "primary": "#00F0FF",
      "secondary": "#B0CCC0",
      "background": "#000000",
      "surface": "#1A1C1E",
      "onPrimary": "#000000",
      "onSecondary": "#000000",
      "onBackground": "#FFFFFF",
      "onSurface": "#FFFFFF"
    },
    "typography": {
      "headingFont": "Inter",
      "bodyFont": "Inter"
    },
    "effects": {
      "roundness": 28.0,
      "elevation": 0.0,
      "opacity": 0.1,
      "blur": 20.0,
      "style": "glass"
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
