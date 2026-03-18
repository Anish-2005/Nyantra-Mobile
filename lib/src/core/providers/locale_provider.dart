import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

enum AppLocale { en, hi }

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'nyantra_locale';

  static const Map<String, String> _enBuiltInFallbacks = {
    'profile': 'Profile',
    'settings': 'Settings',
    'copy_id': 'Copy ID',
    'extracted.loading': 'Loading...',
    'extracted.viewCertificate': 'View Certificate',
    'grievances.categories.disbursement-delay': 'Disbursement Delay',
    'profilePage.title': 'Profile',
    'profilePage.defaultName': 'Nyantra User',
    'profilePage.noEmail': 'No email linked',
    'profilePage.noPhone': 'Not provided',
    'profilePage.notAvailable': 'Not available',
    'profilePage.accountDetails': 'Account Details',
    'profilePage.securityAccess': 'Security & Access',
    'profilePage.copyUserId': 'Copy User ID',
    'profilePage.userIdCopied': 'User ID copied',
    'profilePage.labels.userId': 'User ID',
    'profilePage.labels.email': 'Email',
    'profilePage.labels.phone': 'Phone',
    'profilePage.labels.joined': 'Joined',
    'profilePage.labels.lastSignIn': 'Last Sign-in',
    'profilePage.labels.provider': 'Provider',
    'profilePage.provider.unknown': 'Unknown',
    'profilePage.provider.google': 'Google',
    'profilePage.provider.phone': 'Phone',
    'profilePage.provider.emailPassword': 'Email / Password',
    'profilePage.provider.connected': 'Connected',
    'settingsPage.title': 'Settings',
    'settingsPage.appearance.title': 'Appearance',
    'settingsPage.appearance.subtitle':
        'Switch between orange light mode and blue dark mode',
    'settingsPage.appearance.darkTheme': 'Dark Theme',
    'settingsPage.appearance.lightTheme': 'Light Theme',
    'settingsPage.appearance.applyInstantly': 'Apply across the app instantly',
    'settingsPage.language.title': 'Language',
    'settingsPage.language.subtitle': 'Choose your preferred app language',
    'settingsPage.language.english': 'English',
    'settingsPage.language.hindi': 'Hindi',
    'settingsPage.dataSync.title': 'Data & Sync',
    'settingsPage.dataSync.subtitle':
        'Monitor status and trigger manual cloud sync',
    'settingsPage.dataSync.lastSync': 'Last sync:',
    'settingsPage.dataSync.notSyncedYet': 'Not synced yet',
    'settingsPage.dataSync.syncing': 'Syncing...',
    'settingsPage.dataSync.syncNow': 'Sync Now',
    'settingsPage.session.title': 'Session',
    'settingsPage.session.subtitle': 'Manage your active account',
    'settingsPage.about.title': 'About',
    'settingsPage.about.subtitle': 'App information',
    'settingsPage.about.appName': 'Nyantra User Dashboard',
    'settingsPage.about.version': 'Version',
    'settingsPage.sync.noInternetError': 'No internet connection available',
    'settingsPage.sync.offlineSnack': 'You are offline. Try again later.',
    'settingsPage.sync.successSnack': 'Sync completed successfully',
    'settingsPage.sync.failedSnack': 'Sync failed: {error}',
  };

  static const Map<String, String> _hiBuiltInFallbacks = {
    'profile': 'प्रोफ़ाइल',
    'settings': 'सेटिंग्स',
    'copy_id': 'आईडी कॉपी करें',
    'extracted.loading': 'लोड हो रहा है...',
    'extracted.viewCertificate': 'प्रमाणपत्र देखें',
    'grievances.categories.disbursement-delay': 'वितरण में देरी',
    'profilePage.title': 'प्रोफ़ाइल',
    'profilePage.defaultName': 'न्यंत्रा उपयोगकर्ता',
    'profilePage.noEmail': 'कोई ईमेल लिंक नहीं है',
    'profilePage.noPhone': 'प्रदान नहीं किया गया',
    'profilePage.notAvailable': 'उपलब्ध नहीं',
    'profilePage.accountDetails': 'खाता विवरण',
    'profilePage.securityAccess': 'सुरक्षा और एक्सेस',
    'profilePage.copyUserId': 'यूज़र आईडी कॉपी करें',
    'profilePage.userIdCopied': 'यूज़र आईडी कॉपी हो गई',
    'profilePage.labels.userId': 'यूज़र आईडी',
    'profilePage.labels.email': 'ईमेल',
    'profilePage.labels.phone': 'फ़ोन',
    'profilePage.labels.joined': 'जुड़े',
    'profilePage.labels.lastSignIn': 'आखिरी साइन-इन',
    'profilePage.labels.provider': 'प्रदाता',
    'profilePage.provider.unknown': 'अज्ञात',
    'profilePage.provider.google': 'गूगल',
    'profilePage.provider.phone': 'फ़ोन',
    'profilePage.provider.emailPassword': 'ईमेल / पासवर्ड',
    'profilePage.provider.connected': 'कनेक्टेड',
    'settingsPage.title': 'सेटिंग्स',
    'settingsPage.appearance.title': 'दिखावट',
    'settingsPage.appearance.subtitle':
        'ऑरेंज लाइट मोड और ब्लू डार्क मोड के बीच स्विच करें',
    'settingsPage.appearance.darkTheme': 'डार्क थीम',
    'settingsPage.appearance.lightTheme': 'लाइट थीम',
    'settingsPage.appearance.applyInstantly': 'पूरे ऐप में तुरंत लागू करें',
    'settingsPage.language.title': 'भाषा',
    'settingsPage.language.subtitle': 'अपनी पसंदीदा ऐप भाषा चुनें',
    'settingsPage.language.english': 'अंग्रेज़ी',
    'settingsPage.language.hindi': 'हिंदी',
    'settingsPage.dataSync.title': 'डेटा और सिंक',
    'settingsPage.dataSync.subtitle':
        'स्थिति मॉनिटर करें और मैन्युअल क्लाउड सिंक ट्रिगर करें',
    'settingsPage.dataSync.lastSync': 'आखिरी सिंक:',
    'settingsPage.dataSync.notSyncedYet': 'अभी तक सिंक नहीं हुआ',
    'settingsPage.dataSync.syncing': 'सिंक हो रहा है...',
    'settingsPage.dataSync.syncNow': 'अभी सिंक करें',
    'settingsPage.session.title': 'सेशन',
    'settingsPage.session.subtitle': 'अपने सक्रिय खाते को प्रबंधित करें',
    'settingsPage.about.title': 'ऐप के बारे में',
    'settingsPage.about.subtitle': 'ऐप की जानकारी',
    'settingsPage.about.appName': 'न्यंत्रा यूज़र डैशबोर्ड',
    'settingsPage.about.version': 'संस्करण',
    'settingsPage.sync.noInternetError': 'कोई इंटरनेट कनेक्शन उपलब्ध नहीं है',
    'settingsPage.sync.offlineSnack':
        'आप ऑफलाइन हैं। बाद में फिर प्रयास करें।',
    'settingsPage.sync.successSnack': 'सिंक सफलतापूर्वक पूरा हुआ',
    'settingsPage.sync.failedSnack': 'सिंक विफल: {error}',
  };

  AppLocale _locale = AppLocale.hi;
  Map<String, dynamic> _translations = {};
  Map<String, dynamic> _fallbackTranslations = {};
  bool _translationsLoaded = false;

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
    _translationsLoaded = false;
    final localeFile = _locale == AppLocale.en ? 'en.json' : 'hi.json';
    _translations = await _loadTranslationFile(localeFile);
    _fallbackTranslations = _locale == AppLocale.en
        ? _translations
        : await _loadTranslationFile('en.json');
    _translationsLoaded = true;
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
    if (!_translationsLoaded) {
      return key;
    }
    try {
      dynamic value = _resolveValue(_translations, key);
      value ??= _resolveValue(_fallbackTranslations, key);
      if (value == null) {
        final builtInValue = _resolveBuiltInFallback(key);
        if (builtInValue != null) {
          return args != null ? _interpolate(builtInValue, args) : builtInValue;
        }
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

  String? _resolveBuiltInFallback(String key) {
    if (_locale == AppLocale.hi) {
      return _hiBuiltInFallbacks[key] ?? _enBuiltInFallbacks[key];
    }
    return _enBuiltInFallbacks[key];
  }

  String Function(String, [Map<String, dynamic>?]) get t => translate;

  bool get hasTranslations => _translationsLoaded && _translations.isNotEmpty;
}
