import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger.ui('SettingsScreen', 'BUILD');
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader(context, 'Apparence'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Langue'),
                  subtitle: Text(_getLanguageLabel(settings.locale)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context, ref, settings),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Thème'),
                  subtitle: Text(_getThemeLabel(settings.themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, ref, settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Données'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.sync),
                  title: const Text('Synchronisation automatique'),
                  subtitle: const Text(
                    'Synchroniser les données avec le serveur',
                  ),
                  value: settings.autoSyncEnabled,
                  onChanged: (value) {
                    Logger.ui(
                      'SettingsScreen',
                      'AUTO_SYNC_CHANGED',
                      'value: $value',
                    );
                    ref.read(settingsProvider.notifier).setAutoSync(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: const Text('Sauvegarder les données'),
                  subtitle: const Text('Exporter une copie de vos données'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBackupDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Restaurer les données'),
                  subtitle: const Text('Importer une sauvegarde'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRestoreDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Notifications'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Rappels de paiements et échéances'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                _showComingSoon(context);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Facturation'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Taux de TVA par défaut'),
                  subtitle: const Text('20%'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Modes de paiement'),
                  subtitle: const Text('Espèces, Virement, Chèque'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Modèles de documents'),
                  subtitle: const Text('Personnaliser les modèles de factures'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/templates'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'À propos'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('v0.3.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text("Conditions d'utilisation"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Politique de confidentialité'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context, ref),
              icon: const Icon(Icons.restore, color: Colors.red),
              label: const Text(
                'Réinitialiser les données',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getLanguageLabel(Locale locale) {
    return switch (locale.languageCode) {
      'fr' => 'Français',
      'ar' => 'العربية (Arabe)',
      _ => locale.languageCode,
    };
  }

  String _getThemeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Clair',
      ThemeMode.dark => 'Sombre',
      ThemeMode.system => 'Système',
    };
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    Logger.ui('SettingsScreen', 'SHOW_LANGUAGE_DIALOG');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectionArea(
              child: ListTile(
                leading: Icon(
                  settings.locale.languageCode == 'fr'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: settings.locale.languageCode == 'fr'
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                title: const Text('Français'),
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setLocale(const Locale('fr'));
                  Navigator.pop(dialogContext);
                },
              ),
            ),
            SelectionArea(
              child: ListTile(
                leading: Icon(
                  settings.locale.languageCode == 'ar'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: settings.locale.languageCode == 'ar'
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                title: const Text('العربية (Arabe)'),
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setLocale(const Locale('ar'));
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    Logger.ui('SettingsScreen', 'SHOW_THEME_DIALOG');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectionArea(
              child: ListTile(
                leading: Icon(
                  settings.themeMode == ThemeMode.light
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: settings.themeMode == ThemeMode.light
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                title: const Text('Clair'),
                onTap: () {
                  Logger.ui('SettingsScreen', 'THEME_CHANGED', 'theme: light');
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(ThemeMode.light);
                  Navigator.pop(dialogContext);
                },
              ),
            ),
            SelectionArea(
              child: ListTile(
                leading: Icon(
                  settings.themeMode == ThemeMode.dark
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: settings.themeMode == ThemeMode.dark
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                title: const Text('Sombre'),
                onTap: () {
                  Logger.ui('SettingsScreen', 'THEME_CHANGED', 'theme: dark');
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(ThemeMode.dark);
                  Navigator.pop(dialogContext);
                },
              ),
            ),
            SelectionArea(
              child: ListTile(
                leading: Icon(
                  settings.themeMode == ThemeMode.system
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: settings.themeMode == ThemeMode.system
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                title: const Text('Système'),
                onTap: () {
                  Logger.ui('SettingsScreen', 'THEME_CHANGED', 'theme: system');
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(ThemeMode.system);
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sauvegarder les données'),
        content: const Text(
          'Voulez-vous exporter une copie de vos données ? '
          'Le fichier sera sauvegardé sur votre appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer les données'),
        content: const Text(
          'Sélectionnez un fichier de sauvegarde pour restaurer vos données. '
          'Attention: cette opération remplacera vos données actuelles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Sélectionner'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    Logger.ui('SettingsScreen', 'SHOW_RESET_DIALOG');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les données'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes vos données locales ? '
          'Cette action est irréversible. Les données sur le serveur seront '
          'conservées et pourront être synchronisées à nouveau.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}
