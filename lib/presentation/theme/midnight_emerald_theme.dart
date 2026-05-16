import 'package:themer_flutter/themer_flutter.dart';

class MidnightEmeraldTheme {
  static const String _json = '''
  {
    "version": "1",
    "name": "Midnight Emerald",
    "colors": {
      "primary": "#00FF85",
      "secondary": "#004D2B",
      "background": "#000000",
      "surface": "#0A1F14",
      "onPrimary": "#000000",
      "onSecondary": "#FFFFFF",
      "onBackground": "#FFFFFF",
      "onSurface": "#E0FFF0"
    },
    "typography": {
      "headingFont": "Inter",
      "bodyFont": "Inter",
      "headingSize": 36.0,
      "bodySize": 16.0,
      "labelSize": 14.0
    },
    "effects": {
      "roundness": 12.0,
      "elevation": 0.0
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
