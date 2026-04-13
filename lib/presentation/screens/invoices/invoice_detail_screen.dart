import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:konta/data/local/database.dart';
import 'package:konta/domain/services/pdf_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/presentation/providers/invoice_provider.dart';
import 'package:konta/presentation/providers/customer_provider.dart';
import 'package:konta/data/remote/supabase_service.dart';

final _invoiceProvider = StreamProvider.autoDispose.family<Invoice?, String>((
  ref,
  invoiceId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.invoices,
  )..where((i) => i.id.equals(invoiceId))).watchSingleOrNull();
});

final _customerProvider = StreamProvider.autoDispose.family<Customer?, String>((
  ref,
  customerId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.customers,
  )..where((c) => c.id.equals(customerId))).watchSingleOrNull();
});

final _itemsProvider = StreamProvider.autoDispose
    .family<List<InvoiceItem>, String>((ref, invoiceId) {
      final db = ref.watch(databaseProvider);
      return (db.select(
        db.invoiceItems,
      )..where((i) => i.invoiceId.equals(invoiceId))).watch();
    });

final _paymentsProvider = StreamProvider.autoDispose
    .family<List<Payment>, String>((ref, invoiceId) {
      final db = ref.watch(databaseProvider);
      return (db.select(db.payments)
            ..where((p) => p.invoiceId.equals(invoiceId))
            ..orderBy([
              (p) => OrderingTerm(
                expression: p.paymentDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();
    });

final _relatedDocumentsProvider = StreamProvider.autoDispose
    .family<List<Invoice>, ({String parentId, String parentType})>((
      ref,
      params,
    ) {
      final db = ref.watch(databaseProvider);
      return (db.select(db.invoices)
            ..where(
              (i) =>
                  i.parentDocumentId.equals(params.parentId) &
                  i.type.equals(params.parentType),
            )
            ..orderBy([
              (i) => OrderingTerm(
                expression: i.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();
    });

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(_invoiceProvider(widget.invoiceId));

    return invoiceAsync.when(
      data: (invoice) {
        if (invoice == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Non trouvé')),
            body: const Center(child: Text('Facture non trouvée')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(invoice.number),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _sharePdf(invoice),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, invoice),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: !(invoice.type == 'devis' && invoice.isConverted),
                    child: ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: (invoice.type == 'devis' && invoice.isConverted)
                            ? Colors.grey
                            : null,
                      ),
                      title: Text(
                        'Modifier',
                        style: (invoice.type == 'devis' && invoice.isConverted)
                            ? const TextStyle(color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: ListTile(
                      leading: Icon(Icons.copy),
                      title: Text('Dupliquer'),
                    ),
                  ),
                  if (invoice.type == 'devis' && !invoice.isConverted)
                    const PopupMenuItem(
                      value: 'convert',
                      child: ListTile(
                        leading: Icon(Icons.transform),
                        title: Text('Convertir en facture'),
                      ),
                    ),
                  if (invoice.type == 'invoice')
                    const PopupMenuItem(
                      value: 'create_avoir',
                      child: ListTile(
                        leading: Icon(Icons.receipt_long),
                        title: Text('Créer un avoir'),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _buildContent(invoice),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _previewPdf(invoice),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Aperçu PDF'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chargement')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildContent(Invoice invoice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(invoice),
          const SizedBox(height: 16),
          _buildItemsCard(invoice),
          const SizedBox(height: 16),
          _buildTotalsCard(invoice),
          const SizedBox(height: 16),
          if (invoice.type == 'invoice') _buildPaymentsCard(invoice),
          if (invoice.type == 'invoice') const SizedBox(height: 16),
          _buildRelatedDocumentsCard(invoice),
          const SizedBox(height: 16),
          _buildActionsCard(invoice),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Invoice invoice) {
    final paymentsAsync = ref.watch(_paymentsProvider(invoice.id));
    final totalPaid =
        paymentsAsync.valueOrNull?.fold<double>(
          0,
          (sum, p) => sum + p.amount,
        ) ??
        0;
    final remaining = invoice.total - totalPaid;
    final isFullyPaid =
        invoice.type == 'invoice' && totalPaid > 0 && remaining.abs() < 0.01;
    final displayStatus = isFullyPaid ? 'paid' : invoice.status;

    final typeLabel = switch (invoice.type) {
      'invoice' => 'FACTURE',
      'devis' => 'DEVIS',
      'avoir' => 'AVOIR',
      _ => 'DOCUMENT',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      typeLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (invoice.isConverted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Converti',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                _buildStatusChip(displayStatus),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Numéro', invoice.number),
            _buildInfoRow(
              'Date',
              DateFormat('dd/MM/yyyy').format(invoice.issueDate),
            ),
            if (invoice.dueDate != null)
              _buildInfoRow(
                'Échéance',
                DateFormat('dd/MM/yyyy').format(invoice.dueDate!),
              ),
            if (invoice.parentDocumentId != null &&
                invoice.parentDocumentType != null)
              _buildParentDocumentLink(invoice),
            const SizedBox(height: 16),
            const Text(
              'Client:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCustomerInfo(invoice.customerId),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildParentDocumentLink(Invoice invoice) {
    final parentType = invoice.parentDocumentType ?? '';
    final parentLabel = switch (parentType) {
      'invoice' => 'Facture',
      'devis' => 'Devis',
      'avoir' => 'Avoir',
      _ => parentType,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _navigateToParentDocument(invoice),
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            Text(
              'Document d\'origine: ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Icon(
              Icons.link,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              parentLabel,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToParentDocument(Invoice invoice) {
    final parentType = invoice.parentDocumentType;
    final parentId = invoice.parentDocumentId;

    if (parentType == null || parentId == null) return;

    final route = switch (parentType) {
      'invoice' => '/invoices/$parentId',
      'devis' => '/quotes/$parentId',
      'avoir' => '/avoirs/$parentId',
      _ => null,
    };

    if (route != null) {
      context.push(route);
    }
  }

  Widget _buildCustomerInfo(String customerId) {
    final customerAsync = ref.watch(_customerProvider(customerId));

    return customerAsync.when(
      data: (customer) {
        if (customer == null) return const Text('Client inconnu');
        final phones = _parseJsonList(customer.phones);
        final emails = _parseJsonList(customer.emails);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            if (customer.address != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(customer.address!),
              ),
            if (customer.ice != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('ICE: ${customer.ice}'),
              ),
            if (phones.isNotEmpty || emails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...phones.map(
                      (p) => _buildContactChip(
                        p,
                        Icons.phone,
                        const Color(0xFF10B981),
                      ),
                    ),
                    ...emails.map(
                      (e) => _buildContactChip(
                        e,
                        Icons.email,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Text('...'),
      error: (_, __) => const Text('Erreur chargement client'),
    );
  }

  List<String> _parseJsonList(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  Widget _buildContactChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Invoice invoice) {
    final itemsAsync = ref.watch(_itemsProvider(invoice.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Articles', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            itemsAsync.when(
              data: (items) {
                if (items.isEmpty) return const Text('Aucun article');
                return Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.5),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Qté',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'P.U.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...items.map(
                      (item) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(item.description),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(item.quantity.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(_currencyFormat.format(item.unitPrice)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(_currencyFormat.format(item.total)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Erreur: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard(Invoice invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Total HT', invoice.subtotal),
            _buildTotalRow('TVA', invoice.tvaAmount),
            const Divider(),
            _buildTotalRow('Total TTC', invoice.total, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            _currencyFormat.format(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsCard(Invoice invoice) {
    final paymentsAsync = ref.watch(_paymentsProvider(invoice.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paiements', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            paymentsAsync.when(
              data: (payments) {
                if (payments.isEmpty) {
                  return const Text(
                    'Aucun paiement enregistré',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                final totalPaid = payments.fold<double>(
                  0,
                  (sum, p) => sum + p.amount,
                );
                final remaining = invoice.total - totalPaid;

                return Column(
                  children: [
                    ...payments.map(
                      (payment) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          _getPaymentIcon(payment.method),
                          color: Colors.green,
                        ),
                        title: Text(_currencyFormat.format(payment.amount)),
                        subtitle: Text(
                          '${_getPaymentMethodLabel(payment.method)} • ${DateFormat('dd/MM/yyyy').format(payment.paymentDate)}',
                        ),
                        trailing:
                            payment.method == 'check' &&
                                payment.checkDueDate != null
                            ? Text(
                                'Échéance: ${DateFormat('dd/MM/yyyy').format(payment.checkDueDate!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const Divider(),
                    _buildTotalRow('Total payé', totalPaid),
                    _buildTotalRow(
                      'Reste à payer',
                      remaining,
                      isBold: remaining > 0,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Erreur: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedDocumentsCard(Invoice invoice) {
    if (invoice.type != 'devis' && invoice.type != 'invoice') {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents liés',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildRelatedDocumentsList(invoice),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedDocumentsList(Invoice invoice) {
    if (invoice.type == 'devis') {
      final facturesAsync = ref.watch(
        _relatedDocumentsProvider((
          parentId: invoice.id,
          parentType: 'invoice',
        )),
      );

      return facturesAsync.when(
        data: (factures) {
          if (factures.isEmpty) {
            return Text(
              'Aucune facture créée à partir de ce devis',
              style: TextStyle(color: Colors.grey[600]),
            );
          }
          return Column(
            children: factures
                .map((f) => _buildRelatedDocumentTile(f, 'invoice'))
                .toList(),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const Text('Erreur de chargement'),
      );
    }

    if (invoice.type == 'invoice') {
      final avoirsAsync = ref.watch(
        _relatedDocumentsProvider((parentId: invoice.id, parentType: 'avoir')),
      );

      return avoirsAsync.when(
        data: (avoirs) {
          if (avoirs.isEmpty) {
            return Text(
              'Aucun avoir lié',
              style: TextStyle(color: Colors.grey[600]),
            );
          }
          return Column(
            children: avoirs
                .map((a) => _buildRelatedDocumentTile(a, 'avoir'))
                .toList(),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const Text('Erreur de chargement'),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRelatedDocumentTile(Invoice doc, String type) {
    final typeLabel = switch (type) {
      'invoice' => 'Facture',
      'avoir' => 'Avoir',
      _ => 'Document',
    };

    final route = switch (type) {
      'invoice' => '/invoices/${doc.id}',
      'avoir' => '/avoirs/${doc.id}',
      _ => null,
    };

    final statusLabel = switch (doc.status) {
      'draft' => 'Brouillon',
      'sent' => 'Envoyé',
      'paid' => 'Payé',
      'partially_paid' => 'Partiellement payé',
      'cancelled' => 'Annulé',
      _ => doc.status,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        type == 'avoir' ? Icons.receipt_long : Icons.receipt,
        color: type == 'avoir' ? Colors.orange : null,
      ),
      title: Text('${doc.number} - $typeLabel'),
      subtitle: Text('${_currencyFormat.format(doc.total)} • $statusLabel'),
      trailing: const Icon(Icons.chevron_right),
      onTap: route != null ? () => context.push(route) : null,
    );
  }

  IconData _getPaymentIcon(String method) {
    return switch (method) {
      'cash' => Icons.money,
      'transfer' => Icons.account_balance,
      'check' => Icons.receipt_long,
      _ => Icons.payment,
    };
  }

  String _getPaymentMethodLabel(String method) {
    return switch (method) {
      'cash' => 'Espèces',
      'transfer' => 'Virement',
      'check' => 'Chèque',
      _ => method,
    };
  }

  Widget _buildActionsCard(Invoice invoice) {
    final paymentsAsync = ref.watch(_paymentsProvider(invoice.id));
    final totalPaid =
        paymentsAsync.valueOrNull?.fold<double>(
          0,
          (sum, p) => sum + p.amount,
        ) ??
        0;
    final remaining = invoice.total - totalPaid;
    final isFullyPaid =
        invoice.type == 'invoice' && totalPaid > 0 && remaining.abs() < 0.01;
    final canMakePayment =
        invoice.type == 'invoice' &&
        !isFullyPaid &&
        (invoice.status == 'sent' ||
            invoice.status == 'paid' ||
            invoice.status == 'partially_paid');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (invoice.status == 'draft')
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(invoice, 'sent'),
                    icon: const Icon(Icons.send),
                    label: const Text('Marquer envoyé'),
                  ),
                if (invoice.type == 'devis' &&
                    invoice.status == 'sent' &&
                    !invoice.isConverted)
                  ElevatedButton.icon(
                    onPressed: () => _convertToInvoice(invoice),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Créer la facture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (canMakePayment)
                  ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(invoice),
                    icon: const Icon(Icons.payment),
                    label: const Text('Enregistrer un paiement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (invoice.type == 'invoice' &&
                    (invoice.status == 'sent' ||
                        invoice.status == 'paid' ||
                        invoice.status == 'partially_paid'))
                  ElevatedButton.icon(
                    onPressed: () => _createAvoir(invoice),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Créer un avoir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (invoice.status == 'sent' || invoice.status == 'draft')
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus(invoice, 'cancelled'),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Annuler'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final (color, label) = switch (status) {
      'draft' => (Colors.grey, 'Brouillon'),
      'sent' => (Colors.blue, 'Envoyé'),
      'paid' => (Colors.green, 'Payé'),
      'overdue' => (Colors.red, 'En retard'),
      'cancelled' => (Colors.orange, 'Annulé'),
      'refused' => (Colors.red, 'Refusé'),
      'expired' => (Colors.grey, 'Expiré'),
      'partially_paid' => (Colors.amber, 'Partiellement payé'),
      'converted' => (Colors.purple, 'Converti'),
      _ => (Colors.grey, status),
    };

    return Chip(
      label: Text(label, style: TextStyle(color: color)),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Future<void> _previewPdf(Invoice invoice) async {
    try {
      final db = ref.read(databaseProvider);
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur non connecté')),
          );
        }
        return;
      }

      final profile = await (db.select(
        db.profiles,
      )..where((p) => p.id.equals(userId))).getSingleOrNull();
      if (profile == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profil non trouvé')));
        }
        return;
      }

      final customerRepo = ref.read(customerRepositoryProvider);
      final customer = await customerRepo.getById(invoice.customerId);
      if (customer == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Client non trouvé')));
        }
        return;
      }

      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      final items = await invoiceRepo.getItems(invoice.id);

      final pdf = await PdfService.generateInvoicePdf(
        company: profile,
        customer: customer,
        invoice: invoice,
        items: items,
        languageCode: 'fr',
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(pdf: pdf, invoice: invoice),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur PDF: $e')));
      }
    }
  }

  Future<void> _sharePdf(Invoice invoice) async {
    final db = ref.read(databaseProvider);
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    final profile = await (db.select(
      db.profiles,
    )..where((p) => p.id.equals(userId))).getSingleOrNull();
    if (profile == null) return;

    final customerRepo = ref.read(customerRepositoryProvider);
    final customer = await customerRepo.getById(invoice.customerId);
    if (customer == null) return;

    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final items = await invoiceRepo.getItems(invoice.id);

    final pdf = await PdfService.generateInvoicePdf(
      company: profile,
      customer: customer,
      invoice: invoice,
      items: items,
      languageCode: 'fr',
    );

    final bytes = await pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${invoice.number}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: '${invoice.number} - ${profile.companyName}');
  }

  Future<void> _updateStatus(Invoice invoice, String newStatus) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.invoices)..where((i) => i.id.equals(invoice.id))).write(
      InvoicesCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Statut mis à jour: $newStatus')));
    }
  }

  void _handleMenuAction(String action, Invoice invoice) {
    switch (action) {
      case 'edit':
        if (invoice.type == 'devis' && invoice.isConverted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ce devis a déjà été converti et ne peut plus être modifié',
              ),
            ),
          );
          return;
        }
        final editPath = switch (invoice.type) {
          'invoice' => '/invoices/edit/${invoice.id}',
          'devis' => '/quotes/edit/${invoice.id}',
          'avoir' => '/avoirs/edit/${invoice.id}',
          _ => '/invoices/edit/${invoice.id}',
        };
        context.push(editPath);
        break;
      case 'duplicate':
        _duplicateInvoice(invoice);
        break;
      case 'convert':
        _convertToInvoice(invoice);
        break;
      case 'create_avoir':
        _createAvoir(invoice);
        break;
      case 'delete':
        _deleteInvoice(invoice);
        break;
    }
  }

  Future<void> _duplicateInvoice(Invoice invoice) async {
    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final items = await invoiceRepo.getItems(invoice.id);
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    final newNumber = await invoiceRepo.generateNumber(userId, invoice.type);
    final newId = await invoiceRepo.generateId();
    final now = DateTime.now();

    final newInvoice = Invoice(
      id: newId,
      userId: invoice.userId,
      customerId: invoice.customerId,
      type: invoice.type,
      number: newNumber,
      status: 'draft',
      issueDate: now,
      dueDate: invoice.dueDate,
      subtotal: invoice.subtotal,
      tvaAmount: invoice.tvaAmount,
      total: invoice.total,
      notes: invoice.notes,
      isConverted: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );

    final newItems = items.map(
      (item) => InvoiceItem(
        id: const Uuid().v4(),
        invoiceId: newId,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        tvaRate: item.tvaRate,
        total: item.total,
        syncStatus: 'pending',
      ),
    );

    await invoiceRepo.insertWithItems(newInvoice, newItems.toList());

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document dupliqué')));
    }
  }

  Future<void> _convertToInvoice(Invoice quote) async {
    if (quote.isConverted || quote.status == 'converted') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ce devis a déjà été converti')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convertir en facture'),
        content: Text('Créer une facture à partir du devis ${quote.number} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Convertir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final facture = await invoiceRepo.createFactureFromDevis(quote);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facture créée à partir du devis')),
      );
      context.go('/invoices/${facture.id}');
    }
  }

  Future<void> _createAvoir(Invoice invoice) async {
    final reasonController = TextEditingController();
    final amountController = TextEditingController();
    amountController.text = invoice.total.toStringAsFixed(2);

    final confirmed = await showDialog<_AvoirResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un avoir'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Créer un avoir pour la facture ${invoice.number} ?'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Montant de l\'avoir',
                  border: const OutlineInputBorder(),
                  suffixText: 'MAD',
                  helperText:
                      'Total facture: ${_currencyFormat.format(invoice.total)}',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motif du remboursement (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0 || amount > invoice.total) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Montant invalide')),
                );
                return;
              }
              Navigator.pop(
                context,
                _AvoirResult(
                  amount: amount,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Créer l\'avoir'),
          ),
        ],
      ),
    );

    if (confirmed == null || !mounted) return;

    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final avoir = await invoiceRepo.createAvoirFromDocument(
      invoice,
      refundReason: confirmed.reason,
      refundAmount: confirmed.amount,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Avoir créé')));
      context.go('/avoirs/${avoir.id}');
    }
  }

  Future<void> _showPaymentDialog(Invoice invoice) async {
    final paymentsAsync = ref.read(_paymentsProvider(invoice.id));
    final payments = paymentsAsync.valueOrNull ?? [];
    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
    final remaining = invoice.total - totalPaid;

    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette facture est déjà entièrement payée'),
        ),
      );
      return;
    }

    final amountController = TextEditingController();
    amountController.text = remaining.toStringAsFixed(2);

    DateTime? checkDueDate;

    final confirmed = await showDialog<_PaymentResult>(
      context: context,
      builder: (context) => _PaymentDialog(
        invoice: invoice,
        currencyFormat: _currencyFormat,
        amountController: amountController,
        remaining: remaining,
        totalPaid: totalPaid,
        onCheckDueDateChanged: (date) {
          checkDueDate = date;
        },
      ),
    );

    if (confirmed == null || !mounted) return;

    final amount = double.tryParse(confirmed.amount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }

    if (confirmed.method == 'check' && checkDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner une date d\'échéance pour le chèque',
          ),
        ),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final paymentId = const Uuid().v4();

    final payment = PaymentsCompanion(
      id: Value(paymentId),
      invoiceId: Value(invoice.id),
      amount: Value(amount),
      method: Value(confirmed.method),
      paymentDate: Value(DateTime.now()),
      checkDueDate: Value(checkDueDate),
      syncStatus: const Value('pending'),
      createdAt: Value(DateTime.now()),
    );

    await db.into(db.payments).insert(payment);

    final newStatus = amount >= invoice.total - 0.01
        ? 'paid'
        : 'partially_paid';
    await (db.update(db.invoices)..where((i) => i.id.equals(invoice.id))).write(
      InvoicesCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Paiement de ${_currencyFormat.format(amount)} enregistré',
          ),
        ),
      );
    }
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer ${invoice.number} ?'),
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

    if (confirmed == true && mounted) {
      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      await invoiceRepo.delete(invoice.id);
      if (mounted) context.pop();
    }
  }
}

class PdfPreviewScreen extends StatefulWidget {
  final pw.Document pdf;
  final Invoice invoice;

  const PdfPreviewScreen({super.key, required this.pdf, required this.invoice});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  String? _pdfPath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    _saveAndLoadPdf();
  }

  Future<void> _saveAndLoadPdf() async {
    final bytes = await widget.pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${widget.invoice.number}.pdf');
    await file.writeAsBytes(bytes);
    if (mounted) {
      setState(() {
        _pdfPath = file.path;
        _isLoading = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfPath == null) return;
    await Share.shareXFiles([
      XFile(_pdfPath!),
    ], subject: '${widget.invoice.number} - Document');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice.number),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _pdfPath != null ? _sharePdf : null,
            tooltip: 'Partager',
          ),
        ],
      ),
      body: _isLoading || _pdfPath == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PDFView(
                  filePath: _pdfPath!,
                  enableSwipe: true,
                  autoSpacing: true,
                  pageFling: true,
                  nightMode: false,
                  onRender: (pages) {
                    setState(() => _totalPages = pages ?? 0);
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur PDF: $error')),
                    );
                  },
                  onPageError: (page, error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur page $page: $error')),
                    );
                  },
                  onViewCreated: (controller) {
                    _pdfController = controller;
                  },
                  onPageChanged: (page, total) {
                    setState(() => _currentPage = page ?? 0);
                  },
                ),
                if (_totalPages > 0)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Page ${_currentPage + 1} / $_totalPages',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: _pdfPath == null
          ? null
          : BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () => _pdfController?.setPage(_currentPage - 1)
                        : null,
                    tooltip: 'Page précédente',
                  ),
                  TextButton.icon(
                    onPressed: _sharePdf,
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1
                        ? () => _pdfController?.setPage(_currentPage + 1)
                        : null,
                    tooltip: 'Page suivante',
                  ),
                ],
              ),
            ),
    );
  }
}

class _PaymentResult {
  final String amount;
  final String method;

  _PaymentResult({required this.amount, required this.method});
}

class _AvoirResult {
  final double amount;
  final String? reason;

  _AvoirResult({required this.amount, this.reason});
}

class _PaymentDialog extends StatefulWidget {
  final Invoice invoice;
  final NumberFormat currencyFormat;
  final TextEditingController amountController;
  final double remaining;
  final double totalPaid;
  final ValueChanged<DateTime> onCheckDueDateChanged;

  const _PaymentDialog({
    required this.invoice,
    required this.currencyFormat,
    required this.amountController,
    required this.remaining,
    required this.totalPaid,
    required this.onCheckDueDateChanged,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  String _selectedMethod = 'cash';
  DateTime? _checkDueDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enregistrer un paiement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Facture: ${widget.invoice.number}'),
            Text(
              'Total TTC: ${widget.currencyFormat.format(widget.invoice.total)}',
            ),
            Text(
              'Déjà payé: ${widget.currencyFormat.format(widget.totalPaid)}',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              'Reste à payer: ${widget.currencyFormat.format(widget.remaining)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.amountController,
              decoration: InputDecoration(
                labelText: 'Montant du paiement',
                border: const OutlineInputBorder(),
                suffixText: 'MAD',
                helperText:
                    'Reste: ${widget.currencyFormat.format(widget.remaining)}',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Mode de paiement:'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'cash', label: Text('Espèces')),
                ButtonSegment(value: 'transfer', label: Text('Virement')),
                ButtonSegment(value: 'check', label: Text('Chèque')),
              ],
              selected: {_selectedMethod},
              onSelectionChanged: (Set<String> value) {
                setState(() => _selectedMethod = value.first);
              },
            ),
            if (_selectedMethod == 'check') ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectCheckDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'échéance du chèque',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _checkDueDate != null
                        ? DateFormat('dd/MM/yyyy').format(_checkDueDate!)
                        : 'Sélectionner une date',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              _PaymentResult(
                amount: widget.amountController.text,
                method: _selectedMethod,
              ),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _selectCheckDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _checkDueDate = date);
      widget.onCheckDueDateChanged(date);
    }
  }
}
