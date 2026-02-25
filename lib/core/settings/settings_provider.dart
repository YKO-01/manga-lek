import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // Reading settings
  bool _defaultVerticalMode = true;
  bool _keepScreenOn = true;
  bool _volumeButtonNavigation = false;
  double _readerBrightness = -1; // -1 means system default

  // Appearance settings
  String _fontSize = 'Medium';
  String _accentColor = 'Orange';

  // Getters
  bool get defaultVerticalMode => _defaultVerticalMode;
  bool get keepScreenOn => _keepScreenOn;
  bool get volumeButtonNavigation => _volumeButtonNavigation;
  double get readerBrightness => _readerBrightness;
  String get fontSize => _fontSize;
  String get accentColor => _accentColor;

  bool get isSystemBrightness => _readerBrightness < 0;

  // Setters
  void setDefaultVerticalMode(bool value) {
    _defaultVerticalMode = value;
    notifyListeners();
  }

  void setKeepScreenOn(bool value) {
    _keepScreenOn = value;
    notifyListeners();
  }

  void setVolumeButtonNavigation(bool value) {
    _volumeButtonNavigation = value;
    notifyListeners();
  }

  void setReaderBrightness(double value) {
    _readerBrightness = value;
    notifyListeners();
  }

  void resetReaderBrightness() {
    _readerBrightness = -1;
    notifyListeners();
  }

  void setFontSize(String value) {
    _fontSize = value;
    notifyListeners();
  }

  void setAccentColor(String value) {
    _accentColor = value;
    notifyListeners();
  }
}
