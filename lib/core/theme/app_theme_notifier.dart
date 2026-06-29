import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global singleton that holds the current [ThemeMode].
/// Widgets that need to toggle the theme can access [AppThemeNotifier.instance].
class AppThemeNotifier extends ValueNotifier<ThemeMode> {
  AppThemeNotifier._() : super(ThemeMode.dark);

  static final AppThemeNotifier instance = AppThemeNotifier._();

  static const _prefKey = 'theme_mode';

  /// Load the persisted theme mode from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == 'light') {
      value = ThemeMode.light;
    } else {
      value = ThemeMode.dark;
    }
  }

  /// Toggle between dark and light and persist the choice.
  Future<void> toggle() async {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, value == ThemeMode.light ? 'light' : 'dark');
  }

  bool get isDark => value == ThemeMode.dark;
}
