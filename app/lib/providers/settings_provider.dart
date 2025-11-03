import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kNarrationKey = 'narration_enabled';

  bool _narrationEnabled = true;

  bool get narrationEnabled => _narrationEnabled;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _narrationEnabled = prefs.getBool(_kNarrationKey) ?? true;
    notifyListeners();
  }

  Future<void> setNarrationEnabled(bool enabled) async {
    _narrationEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNarrationKey, enabled);
  }
}
