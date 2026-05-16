import 'package:themer_flutter/themer_flutter.dart';

class HatchedMonochromeTheme {
  static const String _json = '''
  {
    "version": "1.2.0",
    "name": "Hatched Mono",
    "colors": {
      "primary": "#000000",
      "secondary": "#FFFFFF",
      "background": "#FFFFFF",
      "surface": "#FFFFFF",
      "onPrimary": "#FFFFFF",
      "onSecondary": "#000000",
      "onBackground": "#000000",
      "onSurface": "#000000"
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
