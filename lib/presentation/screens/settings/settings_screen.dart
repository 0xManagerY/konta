import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLanguage = 'fr';
  String _selectedTheme = 'system';
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader('Apparence'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Langue'),
                  subtitle: Text(_getLanguageLabel(_selectedLanguage)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Thème'),
                  subtitle: Text(_getThemeLabel(_selectedTheme)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Données'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Synchronisation automatique'),
                  subtitle: const Text(
                    'Synchroniser les données avec le serveur',
                  ),
                  trailing: Switch(
                    value: _autoSyncEnabled,
                    onChanged: (value) {
                      setState(() => _autoSyncEnabled = value);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: const Text('Sauvegarder les données'),
                  subtitle: const Text('Exporter une copie de vos données'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBackupDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Restaurer les données'),
                  subtitle: const Text('Importer une sauvegarde'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRestoreDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Notifications'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Rappels de paiements et échéances'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Facturation'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('Taux de TVA par défaut'),
                  subtitle: const Text('20%'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTvaDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Modes de paiement'),
                  subtitle: const Text('Espèces, Virement, Chèque'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('À propos'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Conditions d\'utilisation'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Politique de confidentialité'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(),
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

  Widget _buildSectionHeader(String title) {
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

  String _getLanguageLabel(String code) {
    return switch (code) {
      'fr' => 'Français',
      'ar' => 'العربية (Arabe)',
      _ => code,
    };
  }

  String _getThemeLabel(String theme) {
    return switch (theme) {
      'light' => 'Clair',
      'dark' => 'Sombre',
      'system' => 'Système',
      _ => theme,
    };
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'fr',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية (Arabe)'),
              value: 'ar',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Clair'),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Sombre'),
              value: 'dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Système'),
              value: 'system',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTvaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taux de TVA par défaut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<double>(
              title: const Text('20%'),
              subtitle: const Text('Taux normal'),
              value: 20,
              groupValue: 20,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<double>(
              title: const Text('14%'),
              subtitle: const Text('Taux intermédiaire'),
              value: 14,
              groupValue: 20,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<double>(
              title: const Text('10%'),
              subtitle: const Text('Hôtels, restaurants'),
              value: 10,
              groupValue: 20,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<double>(
              title: const Text('7%'),
              subtitle: const Text('Eau, électricité'),
              value: 7,
              groupValue: 20,
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<double>(
              title: const Text('0%'),
              subtitle: const Text('Exonéré'),
              value: 0,
              groupValue: 20,
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
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
                const SnackBar(content: Text('Sauvegarde en cours...')),
              );
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
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
                const SnackBar(content: Text('Sélection du fichier...')),
              );
            },
            child: const Text('Sélectionner'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
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
                const SnackBar(content: Text('Fonctionnalité à venir')),
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
