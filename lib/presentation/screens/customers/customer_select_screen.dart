import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/presentation/providers/customer_provider.dart';

class CustomerSelectScreen extends ConsumerStatefulWidget {
  const CustomerSelectScreen({super.key});

  @override
  ConsumerState<CustomerSelectScreen> createState() =>
      _CustomerSelectScreenState();
}

class _CustomerSelectScreenState extends ConsumerState<CustomerSelectScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sélectionner un client')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {},
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return const Center(child: Text('Aucun client disponible'));
                }

                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(customer.name),
                      subtitle: Text(customer.ice ?? 'Pas d\'ICE'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context, customer);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
