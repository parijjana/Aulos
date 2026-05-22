import 'package:flutter/foundation.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';

enum UIContextMode { minimalist, highContext, collapsed }

class DisplayViewModel extends ChangeNotifier {
  final SettingsViewModel? _settingsVM;
  UIContextMode _mode = UIContextMode.highContext;
  int _selectedTabIndex = 0;

  UIContextMode _previousMode = UIContextMode.highContext;

  DisplayViewModel({SettingsViewModel? settingsVM}) : _settingsVM = settingsVM {
    _selectedTabIndex = _settingsVM?.mainTabIndex ?? 0;
  }

  UIContextMode get mode => _mode;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isHighContext => _mode == UIContextMode.highContext;
  bool get isCollapsed => _mode == UIContextMode.collapsed;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    _settingsVM?.setMainTabIndex(index);
    notifyListeners();
  }

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
