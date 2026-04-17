import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/invoice_provider.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  final String type;
  const InvoiceListScreen({super.key, required this.type});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
  String _selectedStatus = 'all';

  final List<String> _statusFilters = [
    'all',
    'draft',
    'sent',
    'paid',
    'overdue',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    Logger.ui('InvoiceListScreen', 'INIT', widget.type);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    Logger.ui('InvoiceListScreen', 'DISPOSE');
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.ui('InvoiceListScreen', 'BUILD', 'type: ${widget.type}');
    final invoicesAsync = ref.watch(invoicesByTypeProvider(widget.type));
    final title = widget.type == 'invoice' ? 'Factures' : 'Devis';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(
              widget.type == 'invoice' ? '/invoices/new' : '/quotes/new',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Liste'),
            Tab(text: 'Statistiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildListTab(invoicesAsync), _buildStatsTab(invoicesAsync)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          widget.type == 'invoice' ? '/invoices/new' : '/quotes/new',
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListTab(AsyncValue<List<Document>> invoicesAsync) {
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  Logger.ui(
                    'InvoiceListScreen',
                    'FILTER_CHANGED',
                    'status: $value',
                  );
                  setState(() => _selectedStatus = value);
                },
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
        Expanded(
          child: invoicesAsync.when(
            data: (invoices) {
              final filtered = _filterInvoices(invoices);
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun${widget.type == 'invoice' ? 'e facture' : ' devis'}',
                  ),
                );
              }
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final invoice = filtered[index];
                  return _buildInvoiceCard(invoice);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Erreur: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(AsyncValue<List<Document>> invoicesAsync) {
    return invoicesAsync.when(
      data: (invoices) {
        final totalHT = invoices.fold<double>(0, (sum, i) => sum + i.subtotal);
        final totalTTC = invoices.fold<double>(0, (sum, i) => sum + i.total);
        final paidCount = invoices.where((i) => i.status.name == 'paid').length;
        final pendingCount = invoices
            .where((i) => i.status.name == 'sent' || i.status.name == 'overdue')
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
                      'Payé${widget.type == 'invoice' ? 'es' : ''}',
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
                        final count = invoices
                            .where((i) => i.status.name == status)
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erreur: $error')),
    );
  }

  Widget _buildInvoiceCard(Document invoice) {
    final customerAsync = ref.watch(
      StreamProvider.autoDispose<Contact?>((ref) {
        final db = ref.watch(databaseProvider);
        return (db.select(
          db.contacts,
        )..where((c) => c.id.equals(invoice.contactId))).watchSingleOrNull();
      }),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(invoice.status.name),
          child: Icon(
            _getStatusIcon(invoice.status.name),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          invoice.number,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customerAsync.when(
              data: (customer) => Text(customer?.name ?? 'Client inconnu'),
              loading: () => const Text('...'),
              error: (_, __) => const Text('Erreur'),
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(invoice.issueDate),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currencyFormat.format(invoice.total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _getStatusChip(invoice.status.name),
          ],
        ),
        onTap: () => context.push('/invoices/${invoice.id}'),
      ),
    );
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

  List<Document> _filterInvoices(List<Document> invoices) {
    var filtered = invoices;
    if (_selectedStatus != 'all') {
      filtered = filtered
          .where((i) => i.status.name == _selectedStatus)
          .toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((i) {
        return i.number.toLowerCase().contains(query) ||
            i.notes?.toLowerCase().contains(query) == true;
      }).toList();
    }
    return filtered;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'all':
        return 'Tous';
      case 'draft':
        return 'Brouillon';
      case 'sent':
        return 'Envoyé${widget.type == 'invoice' ? 'e' : ''}';
      case 'paid':
        return 'Payé${widget.type == 'invoice' ? 'e' : ''}';
      case 'overdue':
        return 'En retard';
      case 'cancelled':
        return 'Annulé${widget.type == 'invoice' ? 'e' : ''}';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'draft':
        return Icons.edit;
      case 'sent':
        return Icons.send;
      case 'paid':
        return Icons.check;
      case 'overdue':
        return Icons.warning;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.receipt;
    }
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
