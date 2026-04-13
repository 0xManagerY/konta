import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/presentation/providers/payment_provider.dart';
import 'package:konta/core/utils/logger.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  const PaymentListScreen({super.key});

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    Logger.ui('PaymentListScreen', 'INIT');
  }

  @override
  Widget build(BuildContext context) {
    Logger.ui('PaymentListScreen', 'BUILD');
    final paymentsAsync = ref.watch(checkRemindersProvider);
    final overdueAsync = ref.watch(overdueChecksProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paiements'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tous'),
              Tab(text: 'Chèques à encaisser'),
              Tab(text: 'Chèques en retard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllPayments(),
            _buildPaymentsList(paymentsAsync, 'Aucun chèque à encaisser'),
            _buildPaymentsList(overdueAsync, 'Aucun chèque en retard'),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPayments() {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<Payment>>(
      stream:
          (db.select(db.payments)..orderBy([
                (p) => OrderingTerm(
                  expression: p.paymentDate,
                  mode: OrderingMode.desc,
                ),
              ]))
              .watch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final payments = snapshot.data ?? [];
        if (payments.isEmpty) {
          return const Center(child: Text('Aucun paiement enregistré'));
        }
        return ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
        );
      },
    );
  }

  Widget _buildPaymentsList(
    AsyncValue<List<Payment>> asyncValue,
    String emptyMessage,
  ) {
    return asyncValue.when(
      data: (payments) {
        if (payments.isEmpty) {
          return Center(child: Text(emptyMessage));
        }
        return ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erreur: $error')),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final methodIcon = _getMethodIcon(payment.method);
    final methodColor = _getMethodColor(payment.method);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: methodColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(methodIcon, color: Colors.white),
        ),
        title: Text(_currencyFormat.format(payment.amount)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getMethodName(payment.method)),
            Text('Le ${_dateFormat.format(payment.paymentDate)}'),
            if (payment.checkDueDate != null)
              Text(
                'Échéance: ${_dateFormat.format(payment.checkDueDate!)}',
                style: TextStyle(
                  color: payment.checkDueDate!.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            if (payment.notes != null)
              Text(
                payment.notes!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing:
            payment.checkDueDate != null &&
                payment.checkDueDate!.isBefore(DateTime.now())
            ? const Icon(Icons.warning, color: Colors.red)
            : null,
      ),
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments;
      case 'transfer':
        return Icons.account_balance;
      case 'check':
        return Icons.receipt_long;
      case 'bill':
        return Icons.description;
      default:
        return Icons.payment;
    }
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'cash':
        return Colors.green;
      case 'transfer':
        return Colors.blue;
      case 'check':
        return Colors.orange;
      case 'bill':
        return Colors.purple;
      default:
        return const Color(0xFF2563EB);
    }
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Espèces';
      case 'transfer':
        return 'Virement bancaire';
      case 'check':
        return 'Chèque';
      case 'bill':
        return 'Effet de commerce';
      default:
        return method;
    }
  }
}
