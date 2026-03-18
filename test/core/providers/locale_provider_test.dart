import 'package:flutter_test/flutter_test.dart';
import 'package:user_dashboard_app/src/core/providers/locale_provider.dart';

void main() {
  group('LocaleProvider.translate', () {
    test('returns localized value when key exists in active locale', () {
      final provider = LocaleProvider.forTest(
        locale: AppLocale.hi,
        translations: {
          'dashboard': {'title': 'Hindi Dashboard'},
        },
      );

      expect(provider.translate('dashboard.title'), 'Hindi Dashboard');
    });

    test('falls back to fallback translations when key is missing', () {
      final provider = LocaleProvider.forTest(
        locale: AppLocale.hi,
        translations: {
          'dashboard': {'title': 'Hindi Dashboard'},
        },
        fallbackTranslations: {
          'dashboard': {'subtitle': 'Track progress'},
        },
      );

      expect(provider.translate('dashboard.subtitle'), 'Track progress');
    });

    test('replaces both single and double brace placeholders', () {
      final provider = LocaleProvider.forTest(
        translations: {
          'greeting': 'Hello {name}',
          'explore': 'Explore {{tab}}',
        },
      );

      expect(provider.translate('greeting', {'name': 'Anish'}), 'Hello Anish');
      expect(
        provider.translate('explore', {'tab': 'Reports'}),
        'Explore Reports',
      );
    });

    test('returns key when translation is missing', () {
      final provider = LocaleProvider.forTest(
        translations: {
          'dashboard': {'title': 'Dashboard'},
        },
      );

      expect(provider.translate('dashboard.subtitle'), 'dashboard.subtitle');
    });
  });
}
