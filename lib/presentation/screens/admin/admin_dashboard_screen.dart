import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/presentation/screens/admin/audit_log_screen.dart';
import 'package:konta/presentation/screens/admin/admin_settings_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger.ui('AdminDashboardScreen', 'BUILD');
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperAdmin'),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Paramètres globaux'),
              subtitle: const Text('Gérer les paramètres de l\'application'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Logger.ui(
                  'AdminDashboardScreen',
                  'NAVIGATE',
                  'AdminSettingsScreen',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.purple),
              title: const Text('Journal d\'audit'),
              subtitle: const Text('Voir toutes les actions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Logger.ui('AdminDashboardScreen', 'NAVIGATE', 'AuditLogScreen');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuditLogScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people, color: Colors.green),
              title: const Text('Utilisateurs'),
              subtitle: const Text('Gérer les comptes utilisateurs'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Logger.ui('AdminDashboardScreen', 'USERS_TAP');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sync, color: Colors.orange),
              title: const Text('Synchronisation'),
              subtitle: const Text('Forcer la sync ou voir le statut'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Logger.ui('AdminDashboardScreen', 'SYNC_TAP');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Statistiques',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Utilisateurs',
                  '0',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Factures',
                  '0',
                  Icons.receipt,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
