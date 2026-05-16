import 'package:themer_flutter/themer_flutter.dart';

class CeramicTrioTheme {
  static const String _json = '''
  {
    "version": "1.2.0",
    "name": "Ceramic Trio",
    "colors": {
      "primary": "#2196F3",
      "secondary": "#FDD835",
      "background": "#FFFFFF",
      "surface": "#F5F5F5",
      "onPrimary": "#FFFFFF",
      "onSecondary": "#000000",
      "onBackground": "#1A237E",
      "onSurface": "#1A237E"
    },
    "typography": {
      "headingFont": "Inter",
      "bodyFont": "Inter"
    },
    "effects": {
      "roundness": 32.0,
      "elevation": 4.0,
      "opacity": 1.0,
      "blur": 0.0,
      "style": "ceramic"
    }
  }
  ''';

  static final ThemerModel model = ThemerParser.parse(_json);
}
