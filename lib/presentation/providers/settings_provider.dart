import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:konta/core/utils/logger.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  Logger.method('Provider', 'settingsProvider', {'init': true});
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final bool autoSyncEnabled;
  final bool notificationsEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('fr'),
    this.autoSyncEnabled = true,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? autoSyncEnabled,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  static const _keyTheme = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyAutoSync = 'auto_sync';
  static const _keyNotifications = 'notifications';

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    Logger.method('SettingsNotifier', 'constructor');
    _loadSettings();
  }

  void _loadSettings() {
    Logger.method('SettingsNotifier', '_loadSettings');
    final themeStr = _prefs.getString(_keyTheme) ?? 'system';
    final localeStr = _prefs.getString(_keyLocale) ?? 'fr';
    final autoSync = _prefs.getBool(_keyAutoSync) ?? true;
    final notifications = _prefs.getBool(_keyNotifications) ?? true;

    Logger.debug(
      'Loaded settings: theme=$themeStr, locale=$localeStr, autoSync=$autoSync, notifications=$notifications',
      tag: 'SETTINGS',
    );

    state = AppSettings(
      themeMode: _parseThemeMode(themeStr),
      locale: Locale(localeStr),
      autoSyncEnabled: autoSync,
      notificationsEnabled: notifications,
    );
  }

  ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    Logger.method('SettingsNotifier', 'setThemeMode', {
      'mode': mode.toString(),
    });
    final themeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_keyTheme, themeStr);
    state = state.copyWith(themeMode: mode);
    Logger.success('Theme mode saved: $themeStr', tag: 'SETTINGS');
  }

  Future<void> setLocale(Locale locale) async {
    Logger.method('SettingsNotifier', 'setLocale', {
      'locale': locale.languageCode,
    });
    await _prefs.setString(_keyLocale, locale.languageCode);
    state = state.copyWith(locale: locale);
    Logger.success('Locale saved: ${locale.languageCode}', tag: 'SETTINGS');
  }

  Future<void> setAutoSync(bool enabled) async {
    Logger.method('SettingsNotifier', 'setAutoSync', {'enabled': enabled});
    await _prefs.setBool(_keyAutoSync, enabled);
    state = state.copyWith(autoSyncEnabled: enabled);
    Logger.success('Auto sync saved: $enabled', tag: 'SETTINGS');
  }

  Future<void> setNotifications(bool enabled) async {
    Logger.method('SettingsNotifier', 'setNotifications', {'enabled': enabled});
    await _prefs.setBool(_keyNotifications, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    Logger.success('Notifications saved: $enabled', tag: 'SETTINGS');
  }
}
