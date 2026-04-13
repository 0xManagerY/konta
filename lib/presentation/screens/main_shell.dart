import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/sync_provider.dart';
import 'package:konta/presentation/providers/settings_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String title;

  const MainShell({super.key, required this.child, required this.title});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Logger.ui('MainShell', 'INIT_STATE');
    Future.microtask(() {
      final autoSyncEnabled = ref.read(settingsProvider).autoSyncEnabled;
      if (autoSyncEnabled) {
        ref.read(syncControllerProvider).startPeriodicSync();
      }
      ref.read(syncControllerProvider).syncNow();
    });
  }

  @override
  void dispose() {
    Logger.ui('MainShell', 'DISPOSE');
    ref.read(syncControllerProvider).dispose();
    super.dispose();
  }

  void _showNewDocumentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Nouvelle facture'),
              onTap: () {
                Navigator.pop(context);
                context.push('/invoices/new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Nouveau devis'),
              onTap: () {
                Navigator.pop(context);
                context.push('/quotes/new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return),
              title: const Text('Nouvel avoir'),
              onTap: () {
                Navigator.pop(context);
                context.push('/avoirs/new');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Logger.ui('MainShell', 'BUILD');
    final isSyncing = ref.watch(isSyncingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Konta',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Mini-ERP Marocain', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Clients'),
              onTap: () {
                Logger.ui('MainShell', 'NAVIGATE', '/customers');
                Navigator.pop(context);
                context.push('/customers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Paiements'),
              onTap: () {
                Logger.ui('MainShell', 'NAVIGATE', '/payments');
                Navigator.pop(context);
                context.push('/payments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Produits'),
              onTap: () {
                Logger.ui('MainShell', 'NAVIGATE', '/products');
                Navigator.pop(context);
                context.push('/products');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Logger.ui('MainShell', 'NAVIGATE', '/profile');
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Logger.ui('MainShell', 'NAVIGATE', '/settings');
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export mensuel'),
              onTap: () {
                Logger.ui('MainShell', 'NAVIGATE', '/export');
                Navigator.pop(context);
                context.push('/export');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Logger.ui('MainShell', 'LOGOUT');
                Navigator.pop(context);
                SupabaseService.signOut();
              },
            ),
          ],
        ),
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          Logger.ui('MainShell', 'NAVIGATION_BAR_TAP', 'index: $index');
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/documents');
              break;
            case 2:
              context.go('/expenses');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_down_outlined),
            selectedIcon: Icon(Icons.trending_down),
            label: 'Dépenses',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showNewDocumentDialog(context),
              child: const Icon(Icons.add),
            )
          : _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () => context.push('/expenses/new'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
