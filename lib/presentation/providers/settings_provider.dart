import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:konta/domain/services/log_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  final log = LogService();
  log.debug(LogTags.provider, 'settingsProvider - initializing');
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final bool autoSyncEnabled;
  final bool notificationsEnabled;
  final bool hasVisitedTeam;
  final int teamMembersCount;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('fr'),
    this.autoSyncEnabled = true,
    this.notificationsEnabled = true,
    this.hasVisitedTeam = false,
    this.teamMembersCount = 0,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? autoSyncEnabled,
    bool? notificationsEnabled,
    bool? hasVisitedTeam,
    int? teamMembersCount,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hasVisitedTeam: hasVisitedTeam ?? this.hasVisitedTeam,
      teamMembersCount: teamMembersCount ?? this.teamMembersCount,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;
  final LogService _log = LogService();

  static const _keyTheme = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyAutoSync = 'auto_sync';
  static const _keyNotifications = 'notifications';
  static const _keyHasVisitedTeam = 'has_visited_team';
  static const _keyTeamMembersCount = 'team_members_count';

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _log.debug(LogTags.config, 'SettingsNotifier - initializing');
    _loadSettings();
  }

  void _loadSettings() {
    _log.debug(LogTags.config, '_loadSettings - loading');
    final themeStr = _prefs.getString(_keyTheme) ?? 'system';
    final localeStr = _prefs.getString(_keyLocale) ?? 'fr';
    final autoSync = _prefs.getBool(_keyAutoSync) ?? true;
    final notifications = _prefs.getBool(_keyNotifications) ?? true;
    final hasVisitedTeam = _prefs.getBool(_keyHasVisitedTeam) ?? false;
    final teamMembersCount = _prefs.getInt(_keyTeamMembersCount) ?? 0;

    _log.debug(
      LogTags.config,
      '_loadSettings - loaded',
      data: {
        'theme': themeStr,
        'locale': localeStr,
        'autoSync': autoSync,
        'notifications': notifications,
        'hasVisitedTeam': hasVisitedTeam,
        'teamMembersCount': teamMembersCount,
      },
    );

    state = AppSettings(
      themeMode: _parseThemeMode(themeStr),
      locale: Locale(localeStr),
      autoSyncEnabled: autoSync,
      notificationsEnabled: notifications,
      hasVisitedTeam: hasVisitedTeam,
      teamMembersCount: teamMembersCount,
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
    _log.debug(
      LogTags.config,
      'setThemeMode - setting',
      data: {'mode': mode.toString()},
    );
    final themeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_keyTheme, themeStr);
    state = state.copyWith(themeMode: mode);
    _log.info(
      LogTags.config,
      'setThemeMode - completed',
      data: {'theme': themeStr},
    );
  }

  Future<void> setLocale(Locale locale) async {
    _log.debug(
      LogTags.config,
      'setLocale - setting',
      data: {'locale': locale.languageCode},
    );
    await _prefs.setString(_keyLocale, locale.languageCode);
    state = state.copyWith(locale: locale);
    _log.info(
      LogTags.config,
      'setLocale - completed',
      data: {'locale': locale.languageCode},
    );
  }

  Future<void> setAutoSync(bool enabled) async {
    _log.debug(
      LogTags.config,
      'setAutoSync - setting',
      data: {'enabled': enabled},
    );
    await _prefs.setBool(_keyAutoSync, enabled);
    state = state.copyWith(autoSyncEnabled: enabled);
    _log.info(
      LogTags.config,
      'setAutoSync - completed',
      data: {'enabled': enabled},
    );
  }

  Future<void> setNotifications(bool enabled) async {
    _log.debug(
      LogTags.config,
      'setNotifications - setting',
      data: {'enabled': enabled},
    );
    await _prefs.setBool(_keyNotifications, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    _log.info(
      LogTags.config,
      'setNotifications - completed',
      data: {'enabled': enabled},
    );
  }

  Future<void> setHasVisitedTeam(bool visited) async {
    _log.debug(
      LogTags.config,
      'setHasVisitedTeam - setting',
      data: {'visited': visited},
    );
    await _prefs.setBool(_keyHasVisitedTeam, visited);
    state = state.copyWith(hasVisitedTeam: visited);
    _log.info(
      LogTags.config,
      'setHasVisitedTeam - completed',
      data: {'visited': visited},
    );
  }

  Future<void> setTeamMembersCount(int count) async {
    _log.debug(
      LogTags.config,
      'setTeamMembersCount - setting',
      data: {'count': count},
    );
    await _prefs.setInt(_keyTeamMembersCount, count);
    state = state.copyWith(teamMembersCount: count);
    _log.info(
      LogTags.config,
      'setTeamMembersCount - completed',
      data: {'count': count},
    );
  }
}
