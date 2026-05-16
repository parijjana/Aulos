import 'package:flutter/foundation.dart';

enum UIContextMode { minimalist, highContext, collapsed }

class DisplayViewModel extends ChangeNotifier {
  UIContextMode _mode = UIContextMode.highContext;

  UIContextMode _previousMode = UIContextMode.highContext;

  UIContextMode get mode => _mode;
  bool get isHighContext => _mode == UIContextMode.highContext;
  bool get isCollapsed => _mode == UIContextMode.collapsed;

  void toggleMode() {
    _mode = _mode == UIContextMode.minimalist
        ? UIContextMode.highContext
        : UIContextMode.minimalist;
    notifyListeners();
  }

  void setMode(UIContextMode mode) {
    if (_mode != UIContextMode.collapsed) {
      _previousMode = _mode;
    }
    _mode = mode;
    notifyListeners();
  }

  void toggleCollapsed() {
    if (_mode == UIContextMode.collapsed) {
      _mode = _previousMode;
    } else {
      _previousMode = _mode;
      _mode = UIContextMode.collapsed;
    }
    notifyListeners();
  }
}
