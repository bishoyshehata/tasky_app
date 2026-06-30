import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier that holds the current [Locale] and persists it across restarts.
class AppLocaleNotifier extends ValueNotifier<Locale> {
  AppLocaleNotifier._() : super(const Locale('en'));

  static final AppLocaleNotifier instance = AppLocaleNotifier._();

  bool get isArabic => value.languageCode == 'ar';

  /// Load persisted locale (call once at startup, before [runApp]).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('locale') ?? 'en';
    value = Locale(lang);
  }

  /// Toggle between EN ↔ AR and persist the choice.
  Future<void> toggle() async {
    final next = isArabic ? 'en' : 'ar';
    value = Locale(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', next);
  }
}
