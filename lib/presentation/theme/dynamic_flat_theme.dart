import 'package:themer_flutter/themer_flutter.dart';

class DynamicFlatTheme {
  static const String _json = '''
  {
    "version": "1.2.0",
    "name": "Dynamic Flat",
    "colors": {
      "primary": "#2962FF",
      "secondary": "#D50000",
      "background": "#FFFFFF",
      "surface": "#F5F5F5",
      "onPrimary": "#FFFFFF",
      "onSecondary": "#FFFFFF",
      "onBackground": "#000000",
      "onSurface": "#000000"
    },
    "typography": {
      "headingFont": "Inter",
      "bodyFont": "Inter"
    },
    "effects": {
      "roundness": 4.0,
      "elevation": 1.0,
      "opacity": 1.0,
      "blur": 0.0,
      "style": "flat"
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
