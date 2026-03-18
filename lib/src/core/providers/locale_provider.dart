import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

enum AppLocale { en, hi }

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'nyantra_locale';
  AppLocale _locale = AppLocale.hi;
  Map<String, dynamic> _translations = {};
  Map<String, dynamic> _fallbackTranslations = {};

  AppLocale get locale => _locale;
  Locale get flutterLocale =>
      _locale == AppLocale.en ? const Locale('en') : const Locale('hi');

  LocaleProvider() {
    unawaited(_loadLocale());
  }

  LocaleProvider.forTest({
    AppLocale locale = AppLocale.en,
    Map<String, dynamic>? translations,
    Map<String, dynamic>? fallbackTranslations,
  }) {
    _locale = locale;
    _translations = translations ?? {};
    _fallbackTranslations = fallbackTranslations ?? {};
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_localeKey);

      if (localeString == 'en') {
        _locale = AppLocale.en;
      } else if (localeString == 'hi') {
        _locale = AppLocale.hi;
      } else {
        // Check system language
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        _locale = systemLocale.languageCode.startsWith('hi')
            ? AppLocale.hi
            : AppLocale.en;
      }
    } catch (error, stackTrace) {
      _locale = AppLocale.en;
      AppLogger.warning(
        'Failed to load saved locale, defaulting to English',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await _loadTranslations();
    notifyListeners();
  }

  Future<void> _loadTranslations() async {
    final localeFile = _locale == AppLocale.en ? 'en.json' : 'hi.json';
    _translations = await _loadTranslationFile(localeFile);
    _fallbackTranslations = _locale == AppLocale.en
        ? _translations
        : await _loadTranslationFile('en.json');
  }

  Future<Map<String, dynamic>> _loadTranslationFile(String localeFile) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$localeFile',
      );
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      AppLogger.warning(
        'Translation file has invalid root object',
        error: localeFile,
      );
      return {};
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to load translation file',
        error: '$localeFile: $error',
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.name);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to persist selected locale',
        error: error,
        stackTrace: stackTrace,
      );
    }
    await _loadTranslations();
    notifyListeners();
  }

  String translate(String key, [Map<String, dynamic>? args]) {
    try {
      dynamic value = _resolveValue(_translations, key);
      value ??= _resolveValue(_fallbackTranslations, key);
      if (value == null) {
        AppLogger.debug('Missing translation key: $key');
        return key;
      }

      if (value is String && args != null) {
        return _interpolate(value, args);
      }

      return value?.toString() ?? key;
    } catch (_) {
      return key;
    }
  }

  dynamic _resolveValue(Map<String, dynamic> source, String key) {
    final keys = key.split('.');
    dynamic value = source;
    for (final k in keys) {
      if (value is Map<String, dynamic>) {
        value = value[k];
      } else {
        return null;
      }
    }
    return value;
  }

  String _interpolate(String template, Map<String, dynamic> args) {
    var result = template;
    for (final entry in args.entries) {
      final value = entry.value.toString();
      result = result
          .replaceAll('{${entry.key}}', value)
          .replaceAll('{{${entry.key}}}', value);
    }
    return result;
  }

  String Function(String, [Map<String, dynamic>?]) get t => translate;

  bool get hasTranslations => _translations.isNotEmpty;
}
