import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/data/remote/supabase_service.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String title;

  const MainShell({super.key, required this.child, required this.title});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

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
                Navigator.pop(context);
                context.push('/customers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Paiements'),
              onTap: () {
                Navigator.pop(context);
                context.push('/payments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Produits'),
              onTap: () {
                Navigator.pop(context);
                context.push('/products');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export mensuel'),
              onTap: () {
                Navigator.pop(context);
                context.push('/export');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
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
