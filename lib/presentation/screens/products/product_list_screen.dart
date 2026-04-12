import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/product_provider.dart';
import 'package:konta/core/utils/logger.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Logger.ui('ProductListScreen', 'INIT');
  }

  @override
  void dispose() {
    Logger.ui('ProductListScreen', 'DISPOSE');
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/products/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = _filterProducts(products);
                if (filtered.isEmpty) {
                  return const Center(child: Text('Aucun produit'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return _buildProductCard(product);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2563EB),
          child: Icon(Icons.inventory_2, color: Colors.white),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: product.description != null && product.description!.isNotEmpty
            ? Text(
                product.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/products/edit/${product.id}'),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchController.text.isEmpty) {
      return products;
    }
    final query = _searchController.text.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(query);
    }).toList();
  }
}
