import 'package:themer_flutter/themer_flutter.dart';

class AmberGlassTheme {
  static const String _json = '''
  {
    "version": "1.2.0",
    "name": "Amber Glass",
    "colors": {
      "primary": "#FFC107",
      "secondary": "#FFA000",
      "background": "#1A1A00",
      "surface": "#333300",
      "onPrimary": "#000000",
      "onSecondary": "#000000",
      "onBackground": "#FFFDE7",
      "onSurface": "#FFF9C4"
    },
    "typography": {
      "headingFont": "Inter",
      "bodyFont": "Inter"
    },
    "effects": {
      "roundness": 28.0,
      "elevation": 0.0,
      "opacity": 0.12,
      "blur": 20.0,
      "style": "glass"
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
