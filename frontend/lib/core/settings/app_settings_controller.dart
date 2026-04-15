import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppSettingsController extends ChangeNotifier {
  AppSettingsController._();

  static final AppSettingsController instance = AppSettingsController._();

  static const String _themeModeKey = "app_theme_mode";
  static const String _localeCodeKey = "app_locale_code";
  static const Set<String> _supportedLanguageCodes = <String>{"en", "fr", "de"};

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale("en");

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeModeKey);
    if (savedTheme != null) {
      _themeMode = _themeFromString(savedTheme);
    }

    final savedLocaleCode = prefs.getString(_localeCodeKey);
    if (savedLocaleCode != null && savedLocaleCode.isNotEmpty) {
      _locale = _supportedLanguageCodes.contains(savedLocaleCode)
          ? Locale(savedLocaleCode)
          : const Locale("en");
    }

    notifyListeners();
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await setThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeToString(mode));
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) {
      return;
    }
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeCodeKey, locale.languageCode);
  }

  ThemeMode _themeFromString(String value) {
    switch (value) {
      case "light":
        return ThemeMode.light;
      case "system":
        return ThemeMode.dark;
      case "dark":
      default:
        return ThemeMode.dark;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "light";
      case ThemeMode.system:
        return "dark";
      case ThemeMode.dark:
        return "dark";
    }
  }
}
