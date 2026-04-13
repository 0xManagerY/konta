import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:uuid/uuid.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/database_provider.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    Logger.ui('AdminSettingsScreen', 'DISPOSE');
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.ui('AdminSettingsScreen', 'BUILD');
    final db = ref.watch(databaseProvider);
    final settingsAsync = ref.watch(
      StreamProvider<List<AdminSetting>>((ref) {
        return (db.select(
          db.adminSettings,
        )..orderBy([(s) => OrderingTerm(expression: s.key)])).watch();
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addSettingDialog(),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (settings.isEmpty) {
            return const Center(child: Text('Aucun paramètre'));
          }
          return ListView.builder(
            itemCount: settings.length,
            itemBuilder: (context, index) {
              final setting = settings[index];
              return _buildSettingTile(setting);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildSettingTile(AdminSetting setting) {
    _controllers[setting.key] ??= TextEditingController(text: setting.value);

    return ListTile(
      title: Text(setting.key),
      subtitle: Text(setting.value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSettingDialog(setting),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSetting(setting),
          ),
        ],
      ),
    );
  }

  Future<void> _addSettingDialog() async {
    Logger.ui('AdminSettingsScreen', 'ADD_SETTING_DIALOG');
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau paramètre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(labelText: 'Clé'),
            ),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Valeur'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyController.text.isNotEmpty) {
                Logger.ui(
                  'AdminSettingsScreen',
                  'ADD_SETTING',
                  'key: ${keyController.text}',
                );
                final db = ref.read(databaseProvider);
                await db
                    .into(db.adminSettings)
                    .insert(
                      AdminSettingsCompanion(
                        id: Value(const Uuid().v4()),
                        key: Value(keyController.text),
                        value: Value(valueController.text),
                        updatedAt: Value(DateTime.now()),
                      ),
                    );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _editSettingDialog(AdminSetting setting) async {
    Logger.ui(
      'AdminSettingsScreen',
      'EDIT_SETTING_DIALOG',
      'key: ${setting.key}',
    );
    final valueController = TextEditingController(text: setting.value);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${setting.key}'),
        content: TextField(
          controller: valueController,
          decoration: const InputDecoration(labelText: 'Valeur'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Logger.ui(
                'AdminSettingsScreen',
                'UPDATE_SETTING',
                'key: ${setting.key}',
              );
              final db = ref.read(databaseProvider);
              await (db.update(
                db.adminSettings,
              )..where((s) => s.id.equals(setting.id))).write(
                AdminSettingsCompanion(
                  value: Value(valueController.text),
                  updatedAt: Value(DateTime.now()),
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSetting(AdminSetting setting) async {
    Logger.ui('AdminSettingsScreen', 'DELETE_SETTING', 'key: ${setting.key}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer ${setting.key} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await (db.delete(
        db.adminSettings,
      )..where((s) => s.id.equals(setting.id))).go();
    }
  }
}
