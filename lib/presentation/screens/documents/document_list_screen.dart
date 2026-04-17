import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/core/utils/logger.dart';

final _customerProvider = StreamProvider.autoDispose.family<Contact?, String>((
  ref,
  customerId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.contacts,
  )..where((c) => c.id.equals(customerId))).watchSingleOrNull();
});

final _paymentsProvider = StreamProvider.autoDispose
    .family<List<Payment>, String>((ref, invoiceId) {
      final db = ref.watch(databaseProvider);
      return (db.select(
        db.payments,
      )..where((p) => p.documentId.equals(invoiceId))).watch();
    });

class DocumentListScreen extends ConsumerStatefulWidget {
  final String type;
  const DocumentListScreen({super.key, required this.type});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
  String _selectedStatus = 'all';
  String _selectedType = 'all';
  final Set<String> _selectedIds = {};
  bool _isSelecting = false;

  final List<String> _statusFilters = [
    'all',
    'draft',
    'sent',
    'paid',
    'overdue',
    'cancelled',
  ];

  final List<String> _typeFilters = ['all', 'devis', 'invoice', 'avoir'];

  @override
  void initState() {
    super.initState();
    Logger.ui('DocumentListScreen', 'INIT', widget.type);
    _tabController = TabController(length: 2, vsync: this);
    _selectedType = widget.type == 'all' ? 'all' : widget.type;
  }

  @override
  void dispose() {
    Logger.ui('DocumentListScreen', 'DISPOSE');
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final userId = SupabaseService.currentUserId;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Liste'),
            Tab(text: 'Statistiques'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildListTab(db, userId), _buildStatsTab(db, userId)],
          ),
        ),
      ],
    );
  }

  Widget _buildListTab(AppDatabase db, String? userId) {
    if (userId == null) {
      return const Center(child: Text('Veuillez vous connecter'));
    }

    return StreamBuilder<List<Document>>(
      stream: _getDocumentsStream(db, userId),
      builder: (context, snapshot) {
        final documents = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.type == 'all') ...[
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      onSelected: (value) =>
                          setState(() => _selectedType = value),
                      itemBuilder: (context) => _typeFilters.map((type) {
                        return PopupMenuItem(
                          value: type,
                          child: Text(_getTypeLabel(type)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_alt),
                    onSelected: (value) =>
                        setState(() => _selectedStatus = value),
                    itemBuilder: (context) => _statusFilters.map((status) {
                      return PopupMenuItem(
                        value: status,
                        child: Text(_getStatusLabel(status)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (_isSelecting)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('${_selectedIds.length} sélectionné(s)'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedIds.clear();
                        _isSelecting = false;
                      }),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedIds.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () => _deleteSelected(db),
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child:
                  snapshot.connectionState == ConnectionState.waiting &&
                      documents.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _filterDocuments(documents).isEmpty
                  ? Center(child: Text('Aucun${_getDocumentSuffix()}'))
                  : ListView.builder(
                      itemCount: _filterDocuments(documents).length,
                      itemBuilder: (context, index) {
                        final doc = _filterDocuments(documents)[index];
                        return _buildDocumentCard(doc, db);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Stream<List<Document>> _getDocumentsStream(AppDatabase db, String userId) {
    final baseQuery = db.select(db.documents)
      ..where((i) => i.companyId.equals(userId))
      ..orderBy([
        (i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
      ]);

    return baseQuery.watch();
  }

  Widget _buildStatsTab(AppDatabase db, String? userId) {
    if (userId == null) {
      return const Center(child: Text('Veuillez vous connecter'));
    }

    return StreamBuilder<List<Document>>(
      stream: _getDocumentsStream(db, userId),
      builder: (context, snapshot) {
        final documents = snapshot.data ?? [];
        final filtered = _filterDocuments(documents);

        final totalHT = filtered.fold<double>(0, (sum, d) => sum + d.subtotal);
        final totalTTC = filtered.fold<double>(0, (sum, d) => sum + d.total);
        final paidCount = filtered.where((d) => d.status.name == 'paid').length;
        final pendingCount = filtered
            .where((d) => d.status.name == 'sent' || d.status.name == 'overdue')
            .length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total HT',
                      _currencyFormat.format(totalHT),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total TTC',
                      _currencyFormat.format(totalTTC),
                      Icons.payments,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Payé${_getPaidSuffix()}',
                      paidCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'En attente',
                      pendingCount.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Par statut',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ..._statusFilters.skip(1).map((status) {
                        final count = filtered
                            .where((d) => d.status.name == status)
                            .length;
                        if (count == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _getStatusChip(status),
                                  const SizedBox(width: 12),
                                  Text(_getStatusLabel(status)),
                                ],
                              ),
                              Text(
                                count.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(Document doc, AppDatabase db) {
    final customerAsync = ref.watch(_customerProvider(doc.contactId));
    final paymentsAsync = ref.watch(_paymentsProvider(doc.id));

    final totalPaid =
        paymentsAsync.valueOrNull?.fold<double>(
          0,
          (sum, p) => sum + p.amount,
        ) ??
        0;
    final remaining = doc.total - totalPaid;
    final isFullyPaid = remaining.abs() < 0.01;
    final isSelected = _selectedIds.contains(doc.id);
    final canEdit =
        (doc.type.name == 'quote' && !doc.isConverted) ||
        doc.status.name == 'draft';

    final displayStatus =
        doc.type.name == 'invoice' && isFullyPaid && totalPaid > 0
        ? 'paid'
        : doc.status.name;

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer'),
            content: Text('Supprimer ${doc.number} ?'),
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
      },
      onDismissed: (direction) async {
        await _deleteDocument(db, doc.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        child: ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSelecting)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(doc.id);
                      } else {
                        _selectedIds.remove(doc.id);
                      }
                    });
                  },
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(doc.type.name).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTypeAbbreviation(doc.type.name),
                  style: TextStyle(
                    color: _getTypeColor(doc.type.name),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: _getStatusColor(displayStatus),
                child: Icon(
                  _getStatusIcon(displayStatus),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          title: Text(
            doc.number,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customerAsync.when(
                data: (customer) => Text(
                  customer?.name ?? 'Client inconnu',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                loading: () => const Text('Chargement...'),
                error: (_, __) => const Text('Erreur'),
              ),
              if (doc.type.name == 'invoice' && totalPaid > 0)
                Text(
                  'Payé: ${_currencyFormat.format(totalPaid)} | Reste: ${_currencyFormat.format(remaining)}',
                  style: TextStyle(
                    color: isFullyPaid ? Colors.green[700] : Colors.orange[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Text(
                DateFormat('dd/MM/yyyy').format(doc.issueDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit && !_isSelecting)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    final route = switch (doc.type.name) {
                      'invoice' => '/invoices/edit/${doc.id}',
                      'devis' => '/quotes/edit/${doc.id}',
                      'avoir' => '/avoirs/edit/${doc.id}',
                      _ => '/invoices/edit/${doc.id}',
                    };
                    context.push(route);
                  },
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currencyFormat.format(doc.total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _getStatusChip(displayStatus),
                ],
              ),
            ],
          ),
          onLongPress: () {
            setState(() {
              _isSelecting = true;
              _selectedIds.add(doc.id);
            });
          },
          onTap: () {
            if (_isSelecting) {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(doc.id);
                  if (_selectedIds.isEmpty) {
                    _isSelecting = false;
                  }
                } else {
                  _selectedIds.add(doc.id);
                }
              });
            } else {
              final route = switch (doc.type.name) {
                'invoice' => '/invoices/${doc.id}',
                'devis' => '/quotes/${doc.id}',
                'avoir' => '/avoirs/${doc.id}',
                _ => '/invoices/${doc.id}',
              };
              context.push(route);
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteDocument(AppDatabase db, String id) async {
    await db.transaction(() async {
      await (db.delete(
        db.documentLines,
      )..where((i) => i.documentId.equals(id))).go();
      await (db.delete(
        db.payments,
      )..where((p) => p.documentId.equals(id))).go();
      await (db.delete(db.documents)..where((i) => i.id.equals(id))).go();
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document supprimé')));
    }
  }

  Future<void> _deleteSelected(AppDatabase db) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer ${_selectedIds.length} document(s) ?'),
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
      for (final id in _selectedIds) {
        await _deleteDocument(db, id);
      }
      setState(() {
        _selectedIds.clear();
        _isSelecting = false;
      });
    }
  }

  Widget _buildStatCard(
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
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

  List<Document> _filterDocuments(List<Document> documents) {
    var filtered = documents;

    if (_selectedType != 'all') {
      filtered = filtered.where((d) => d.type.name == _selectedType).toList();
    }

    if (_selectedStatus != 'all') {
      filtered = filtered
          .where((d) => d.status.name == _selectedStatus)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((d) {
        return d.number.toLowerCase().contains(query) ||
            d.notes?.toLowerCase().contains(query) == true;
      }).toList();
    }

    return filtered;
  }

  String _getTypeLabel(String type) {
    return switch (type) {
      'all' => 'Tous',
      'devis' => 'Devis',
      'invoice' => 'Factures',
      'avoir' => 'Avoirs',
      _ => type,
    };
  }

  String _getTypeAbbreviation(String type) {
    return switch (type) {
      'devis' || 'quote' => 'DEV',
      'invoice' => 'FAC',
      'avoir' || 'creditNote' => 'AVR',
      _ => 'DOC',
    };
  }

  Color _getTypeColor(String type) {
    return switch (type) {
      'devis' || 'quote' => Colors.purple,
      'invoice' => Colors.blue,
      'avoir' || 'creditNote' => Colors.orange,
      _ => Colors.grey,
    };
  }

  String _getDocumentSuffix() {
    return switch (widget.type) {
      'invoice' => 'e facture',
      'devis' => ' devis',
      'avoir' => ' avoir',
      _ => ' document',
    };
  }

  String _getPaidSuffix() {
    return switch (widget.type) {
      'invoice' => 'es',
      'devis' => 's',
      'avoir' => 's',
      _ => 's',
    };
  }

  String _getStatusLabel(String status) {
    return switch (status) {
      'all' => 'Tous',
      'draft' => 'Brouillon',
      'sent' => 'Envoyé${_getSentSuffix()}',
      'paid' => 'Payé${_getPaidSuffix()}',
      'overdue' => 'En retard',
      'cancelled' => 'Annulé${_getCancelledSuffix()}',
      _ => status,
    };
  }

  String _getSentSuffix() {
    return switch (widget.type) {
      'invoice' => 'e',
      _ => '',
    };
  }

  String _getCancelledSuffix() {
    return switch (widget.type) {
      'invoice' => 'e',
      'avoir' => '',
      _ => '',
    };
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'draft' => Colors.grey,
      'sent' => Colors.blue,
      'paid' => Colors.green,
      'overdue' => Colors.red,
      'cancelled' => Colors.orange,
      _ => Colors.grey,
    };
  }

  IconData _getStatusIcon(String status) {
    return switch (status) {
      'draft' => Icons.edit,
      'sent' => Icons.send,
      'paid' => Icons.check,
      'overdue' => Icons.warning,
      'cancelled' => Icons.cancel,
      _ => Icons.receipt,
    };
  }

  Widget _getStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
