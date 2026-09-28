import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

/// How the app picks between the light and dark palettes.
enum AppThemePreference {
  system,
  light,
  dark;

  static AppThemePreference fromName(String? name) {
    return AppThemePreference.values.firstWhere(
      (value) => value.name == name,
      orElse: () => AppThemePreference.system,
    );
  }
}

/// User-facing app settings, persisted locally with GetStorage.
///
/// Deliberately not synced to Firestore: appearance and language are
/// device-level preferences and should apply before sign-in (the splash,
/// onboarding and auth screens are localised and themed too).
class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'themePreference';
  static const String _localeKey = 'localeCode';

  /// Locales the app ships translations for. `null` [locale] means "follow
  /// the device language".
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ha'),
    Locale('yo'),
    Locale('ig'),
    Locale('fr'),
    Locale('es'),
  ];

  /// Endonyms — a language picker should always show each language in itself.
  static const Map<String, String> languageNames = <String, String>{
    'en': 'English',
    'ha': 'Hausa',
    'yo': 'Yorùbá',
    'ig': 'Igbo',
    'fr': 'Français',
    'es': 'Español',
  };

  final GetStorage _storage = GetStorage();

  AppThemePreference _themePreference = AppThemePreference.system;
  Locale? _locale;

  AppThemePreference get themePreference => _themePreference;
  Locale? get locale => _locale;

  ThemeMode get themeMode {
    switch (_themePreference) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.system:
        return ThemeMode.system;
    }
  }

  SettingsProvider() {
    _load();
  }

  void _load() {
    try {
      _themePreference =
          AppThemePreference.fromName(_storage.read<String>(_themeKey));
      final code = _storage.read<String>(_localeKey);
      _locale = _localeFor(code);
    } catch (e) {
      // Corrupt or unavailable storage must not stop the app from starting.
      _themePreference = AppThemePreference.system;
      _locale = null;
    }
  }

  static Locale? _localeFor(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final locale in supportedLocales) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    if (_themePreference == preference) return;
    _themePreference = preference;
    notifyListeners();
    try {
      await _storage.write(_themeKey, preference.name);
    } catch (e) {
      // Non-fatal: the in-memory preference still applies this session.
    }
  }

  /// Pass `null` to follow the device language.
  Future<void> setLocale(Locale? locale) async {
    final normalised = _localeFor(locale?.languageCode);
    if (_locale?.languageCode == normalised?.languageCode) return;
    _locale = normalised;
    notifyListeners();
    try {
      await _storage.write(_localeKey, normalised?.languageCode ?? '');
    } catch (e) {
      // Non-fatal.
    }
  }
}
