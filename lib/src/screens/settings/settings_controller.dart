import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  late ThemeMode _themeMode;
  late String _instanceHost;

  ThemeMode get themeMode => _themeMode;
  String get instanceHost => _instanceHost;

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _themeMode = prefs.getString('themeMode') != null
        ? ThemeMode.values.byName(prefs.getString("themeMode")!)
        : ThemeMode.system;
    _instanceHost = prefs.getString('instanceHost') ?? 'kbin.run';

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newThemeMode.name);
  }

  Future<void> updateInstanceHost(String? newInstanceHost) async {
    if (newInstanceHost == null) return;

    if (newInstanceHost == _instanceHost) return;

    _instanceHost = newInstanceHost;

    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('instanceHost', newInstanceHost);
  }
}
