import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/presentation/providers/invoice_provider.dart';
import 'package:konta/presentation/providers/product_provider.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final String? invoiceId;
  final String type;

  const InvoiceFormScreen({super.key, this.invoiceId, required this.type});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Contact? _selectedCustomer;
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;
  String _status = 'draft';
  final _notesController = TextEditingController();

  List<DocumentLine> _items = [];
  List<Item> _products = [];
  double _subtotal = 0;
  double _tvaAmount = 0;
  double _total = 0;

  bool _isLoading = false;
  Document? _existingInvoice;

  final _descriptionControllers = <int, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    Logger.ui('InvoiceFormScreen', 'INIT', widget.invoiceId ?? 'new');
    _loadProducts();
    if (widget.invoiceId != null) {
      _loadInvoice();
    }
  }

  Future<void> _loadProducts() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    final products = await ref.read(productRepositoryProvider).getAll(userId);
    if (mounted) {
      setState(() => _products = products);
    }
  }

  Future<void> _loadInvoice() async {
    Logger.ui('InvoiceFormScreen', 'LOAD_INVOICE', widget.invoiceId!);
    final db = ref.read(databaseProvider);
    final invoice = await (db.select(
      db.documents,
    )..where((i) => i.id.equals(widget.invoiceId!))).getSingleOrNull();

    if (invoice != null && mounted) {
      final items = await (db.select(
        db.documentLines,
      )..where((i) => i.documentId.equals(invoice.id))).get();

      if (invoice.contactId.isNotEmpty) {
        final customer = await (db.select(
          db.contacts,
        )..where((c) => c.id.equals(invoice.contactId))).getSingleOrNull();
        if (customer != null && mounted) {
          setState(() => _selectedCustomer = customer);
        }
      }

      Logger.ui('InvoiceFormScreen', 'INVOICE_LOADED', invoice.number);
      setState(() {
        _existingInvoice = invoice;
        _status = invoice.status.name;
        _issueDate = invoice.issueDate;
        _dueDate = invoice.dueDate;
        _notesController.text = invoice.notes ?? '';
        _items = items;
      });

      _calculateTotals();
    }
  }

  @override
  void dispose() {
    Logger.ui('InvoiceFormScreen', 'DISPOSE');
    _notesController.dispose();
    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    Logger.ui('InvoiceFormScreen', 'ADD_ITEM');
    setState(() {
      _items.add(
        DocumentLine(
          id: const Uuid().v4(),
          documentId: widget.invoiceId ?? '',
          itemId: null,
          description: '',
          quantity: 1,
          unitPrice: 0,
          tvaRate: 20,
          total: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
        ),
      );
    });
  }

  void _removeItem(int index) {
    Logger.ui('InvoiceFormScreen', 'REMOVE_ITEM', 'index: $index');
    setState(() {
      _items.removeAt(index);
      _descriptionControllers[index]?.dispose();
      _descriptionControllers.remove(index);
      _calculateTotals();
    });
  }

  void _updateItem(int index, DocumentLine item) {
    setState(() {
      _items[index] = item;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _subtotal = 0;
    _tvaAmount = 0;
    _total = 0;

    for (final item in _items) {
      final itemTotal = item.quantity * item.unitPrice;
      final itemTva = itemTotal * (item.tvaRate / 100);
      _subtotal += itemTotal;
      _tvaAmount += itemTva;
    }

    _total = _subtotal + _tvaAmount;
  }

  Future<void> _handleSave() async {
    Logger.ui('InvoiceFormScreen', 'SAVE_ATTEMPT');
    if (!_formKey.currentState!.validate()) {
      Logger.ui('InvoiceFormScreen', 'VALIDATION_FAILED');
      return;
    }
    if (_selectedCustomer == null) {
      Logger.ui('InvoiceFormScreen', 'NO_CUSTOMER');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un client'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      Logger.ui('InvoiceFormScreen', 'NO_ITEMS');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une ligne'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUserId;

      if (userId == null) throw Exception('Utilisateur non connecté');

      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final invoiceId = _existingInvoice?.id ?? const Uuid().v4();
      final invoiceType = widget.type == 'invoice'
          ? DocumentType.invoice
          : widget.type == 'devis'
          ? DocumentType.quote
          : DocumentType.creditNote;
      final number =
          _existingInvoice?.number ??
          await invoiceRepo.generateNumber(userId, invoiceType);

      final now = DateTime.now();

      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        if (item.itemId == null && item.description.isNotEmpty) {
          final existing = _products
              .where(
                (p) => p.name.toLowerCase() == item.description.toLowerCase(),
              )
              .firstOrNull;

          if (existing != null) {
            _items[i] = item.copyWith(itemId: Value(existing.id));
          } else {
            final newProduct = ItemsCompanion(
              companyId: Value(userId),
              name: Value(item.description),
              defaultUnitPrice: Value(item.unitPrice),
              isActive: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            );
            final newId = await productRepo.insert(newProduct);
            _items[i] = item.copyWith(itemId: Value(newId));
          }
        }
      }

      final invoiceStatus = DocumentStatus.values.byName(_status);

      final invoice = Document(
        id: invoiceId,
        companyId: userId,
        contactId: _selectedCustomer!.id,
        type: invoiceType,
        number: number,
        status: invoiceStatus,
        issueDate: _issueDate,
        dueDate: _dueDate,
        subtotal: _subtotal,
        tvaAmount: _tvaAmount,
        total: _total,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isConverted: false,
        createdAt: _existingInvoice?.createdAt ?? now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      final itemsWithDocumentId = _items
          .map(
            (item) => DocumentLine(
              id: item.id,
              documentId: invoiceId,
              itemId: item.itemId,
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              tvaRate: item.tvaRate,
              total: item.quantity * item.unitPrice,
              createdAt: now,
              updatedAt: now,
              syncStatus: 'pending',
            ),
          )
          .toList();

      if (_existingInvoice == null) {
        Logger.ui('InvoiceFormScreen', 'INSERT_INVOICE', invoiceId);
        await invoiceRepo.insertWithItems(invoice, itemsWithDocumentId);
      } else {
        Logger.ui('InvoiceFormScreen', 'UPDATE_INVOICE', invoiceId);
        await invoiceRepo.update(invoice);
        await invoiceRepo.updateItems(invoiceId, itemsWithDocumentId);
      }

      Logger.ui('InvoiceFormScreen', 'SAVE_SUCCESS');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingInvoice == null
                  ? '${widget.type == 'invoice'
                        ? 'Facture'
                        : widget.type == 'devis'
                        ? 'Devis'
                        : 'Avoir'} créé avec succès'
                  : 'Mis à jour avec succès',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    } catch (e, st) {
      Logger.error(
        'Save invoice failed',
        tag: 'INVOICE_FORM',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingInvoice == null
              ? widget.type == 'invoice'
                    ? 'Nouvelle facture'
                    : widget.type == 'devis'
                    ? 'Nouveau devis'
                    : 'Nouvel avoir'
              : 'Modifier',
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: const Text('Enregistrer'),
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
              _buildCustomerSelector(),
              const SizedBox(height: 16),
              _buildDatePickers(),
              const SizedBox(height: 16),
              _buildItemsSection(),
              const SizedBox(height: 16),
              _buildTotalsCard(context),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return InkWell(
      onTap: () async {
        final customer = await context.push('/customers/select') as Contact?;
        if (customer != null) {
          setState(() => _selectedCustomer = customer);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Client',
          prefixIcon: Icon(Icons.person),
          suffixIcon: Icon(Icons.chevron_right),
        ),
        child: Text(
          _selectedCustomer?.name ?? 'Sélectionner un client',
          style: TextStyle(
            color: _selectedCustomer == null ? Colors.grey : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _issueDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _issueDate = date);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date d\'émission',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                '${_issueDate.day}/${_issueDate.month}/${_issueDate.year}',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _dueDate = date);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date d\'échéance (optionnel)',
                prefixIcon: Icon(Icons.event),
              ),
              child: Text(
                _dueDate != null
                    ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                    : 'Non définie',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lignes', style: Theme.of(context).textTheme.titleMedium),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildItemCard(index, item);
        }),
      ],
    );
  }

  Widget _buildItemCard(int index, DocumentLine item) {
    _descriptionControllers[index] ??= TextEditingController(
      text: item.description,
    );

    if (_descriptionControllers[index]!.text != item.description &&
        item.description.isNotEmpty) {
      _descriptionControllers[index]!.text = item.description;
      _descriptionControllers[index]!.selection = TextSelection.collapsed(
        offset: item.description.length,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Autocomplete<String>(
              initialValue: TextEditingValue(
                text: item.itemId != null ? item.description : '',
              ),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _products.map((p) => p.name);
                }
                return _products
                    .where(
                      (p) => p.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    )
                    .map((p) => p.name);
              },
              onSelected: (String selection) {
                final product = _products.firstWhere(
                  (p) => p.name == selection,
                  orElse: () => _products.first,
                );
                final newDescription = product.description ?? product.name;
                _descriptionControllers[index]?.text = newDescription;
                _updateItem(
                  index,
                  item.copyWith(
                    itemId: Value(product.id),
                    description: newDescription,
                  ),
                );
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextFormField(
                      controller: textController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Produit',
                        isDense: true,
                        hintText: 'Tapez ou sélectionnez un produit',
                      ),
                      onChanged: (value) {
                        _updateItem(
                          index,
                          item.copyWith(
                            description: value,
                            itemId: const Value(null),
                          ),
                        );
                      },
                    );
                  },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionControllers[index],
              decoration: const InputDecoration(
                labelText: 'Description',
                isDense: true,
              ),
              onChanged: (value) {
                _updateItem(index, item.copyWith(description: value));
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantité',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 1;
                      _updateItem(index, item.copyWith(quantity: qty));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item.unitPrice.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Prix unitaire',
                      isDense: true,
                      suffixText: 'MAD',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0;
                      _updateItem(index, item.copyWith(unitPrice: price));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<double>(
                    initialValue: item.tvaRate,
                    decoration: const InputDecoration(
                      labelText: 'TVA',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 0.0, child: Text('0%')),
                      DropdownMenuItem(value: 1.0, child: Text('1%')),
                      DropdownMenuItem(value: 10.0, child: Text('10%')),
                      DropdownMenuItem(value: 20.0, child: Text('20%')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _updateItem(index, item.copyWith(tvaRate: value));
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[850] : const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total HT:',
                  style: TextStyle(color: isDark ? Colors.grey[300] : null),
                ),
                Text(
                  '${_subtotal.toStringAsFixed(2)} MAD',
                  style: TextStyle(color: isDark ? Colors.grey[300] : null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TVA:',
                  style: TextStyle(color: isDark ? Colors.grey[300] : null),
                ),
                Text(
                  '${_tvaAmount.toStringAsFixed(2)} MAD',
                  style: TextStyle(color: isDark ? Colors.grey[300] : null),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total TTC:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : null,
                  ),
                ),
                Text(
                  '${_total.toStringAsFixed(2)} MAD',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
