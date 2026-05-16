import 'package:themer_flutter/themer_flutter.dart';

class RubyGlassTheme {
  static const String _json = '''
  {
    "version": "1.2.0",
    "name": "Ruby Glass",
    "colors": {
      "primary": "#FF1744",
      "secondary": "#D50000",
      "background": "#1A0000",
      "surface": "#330000",
      "onPrimary": "#FFFFFF",
      "onSecondary": "#FFFFFF",
      "onBackground": "#FFEBEE",
      "onSurface": "#FFCDD2"
    },
    "typography": {
      "headingFont": "Inter",
      "bodyFont": "Inter"
    },
    "effects": {
      "roundness": 28.0,
      "elevation": 0.0,
      "opacity": 0.15,
      "blur": 25.0,
      "style": "glass"
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
