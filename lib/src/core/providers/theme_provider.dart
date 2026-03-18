import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart' as app_theme;
import '../utils/app_logger.dart';

enum AppTheme { light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'nyantra_theme';
  AppTheme _theme = AppTheme.dark;

  AppTheme get theme => _theme;

  bool get isDark => _theme == AppTheme.dark;

  ThemeData get themeData => _getThemeData();

  ThemeProvider() {
    unawaited(_loadTheme());
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);

      if (themeString == 'light') {
        _theme = AppTheme.light;
      } else if (themeString == 'dark') {
        _theme = AppTheme.dark;
      } else {
        // Check system preference
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _theme = brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to load saved theme, defaulting to dark',
        error: error,
        stackTrace: stackTrace,
      );
      _theme = AppTheme.dark;
    }

    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _theme = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme.name);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to persist selected theme',
        error: error,
        stackTrace: stackTrace,
      );
    }
    notifyListeners();
  }

  void toggleTheme() {
    unawaited(setTheme(isDark ? AppTheme.light : AppTheme.dark));
  }

  ThemeData _getThemeData() {
    return isDark ? app_theme.AppTheme.dark() : app_theme.AppTheme.light();
  }
}
