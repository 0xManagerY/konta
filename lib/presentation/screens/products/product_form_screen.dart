import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/product_provider.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/core/utils/logger.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  Item? _existingProduct;

  @override
  void initState() {
    super.initState();
    Logger.ui('ProductFormScreen', 'INIT', widget.productId ?? 'new');
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    Logger.ui('ProductFormScreen', 'LOAD_PRODUCT', widget.productId!);
    final repo = ref.read(productRepositoryProvider);
    final product = await repo.getById(widget.productId!);
    if (product != null && mounted) {
      Logger.ui('ProductFormScreen', 'PRODUCT_LOADED', product.name);
      setState(() {
        _existingProduct = product;
        _nameController.text = product.name;
        _descriptionController.text = product.description ?? '';
      });
    }
  }

  @override
  void dispose() {
    Logger.ui('ProductFormScreen', 'DISPOSE');
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    Logger.ui('ProductFormScreen', 'SAVE_ATTEMPT', _nameController.text);
    if (!_formKey.currentState!.validate()) {
      Logger.ui('ProductFormScreen', 'VALIDATION_FAILED');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(productRepositoryProvider);
      final userId = SupabaseService.currentUserId;

      if (userId == null) {
        Logger.error('User not authenticated', tag: 'PRODUCT_FORM');
        throw Exception('Utilisateur non connecté');
      }

      final now = DateTime.now();

      if (_existingProduct == null) {
        final product = ItemsCompanion(
          companyId: Value(userId),
          name: Value(_nameController.text.trim()),
          description: Value(
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          ),
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
        );

        Logger.ui('ProductFormScreen', 'INSERT_PRODUCT');
        await repo.insert(product);
      } else {
        final product = Item(
          id: _existingProduct!.id,
          companyId: userId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          defaultUnitPrice: _existingProduct!.defaultUnitPrice,
          isActive: _existingProduct!.isActive,
          createdAt: _existingProduct!.createdAt,
          updatedAt: now,
          syncStatus: 'pending',
        );

        Logger.ui('ProductFormScreen', 'UPDATE_PRODUCT', product.id);
        await repo.update(product);
      }

      Logger.ui('ProductFormScreen', 'SAVE_SUCCESS');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingProduct == null
                  ? 'Produit ajouté avec succès'
                  : 'Produit mis à jour avec succès',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    } catch (e, st) {
      Logger.error(
        'Save product failed',
        tag: 'PRODUCT_FORM',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    Logger.ui('ProductFormScreen', 'DELETE_ATTEMPT', widget.productId!);

    final repo = ref.read(productRepositoryProvider);
    final isUsed = await repo.isUsedInInvoices(widget.productId!);

    if (isUsed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ce produit est utilisé dans des documents et ne peut pas être supprimé',
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Logger.ui('ProductFormScreen', 'DELETE_CONFIRMED', widget.productId!);
      await repo.delete(widget.productId!);
      if (mounted) {
        Logger.ui('ProductFormScreen', 'DELETE_SUCCESS');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit supprimé'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingProduct == null ? 'Nouveau produit' : 'Modifier le produit',
        ),
        actions: [
          if (_existingProduct != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Description affichée dans les documents',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
