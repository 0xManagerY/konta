import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');

  @override
  void initState() {
    super.initState();
    Logger.ui('DashboardScreen', 'INIT');
  }

  @override
  Widget build(BuildContext context) {
    Logger.ui('DashboardScreen', 'BUILD');
    final db = ref.watch(databaseProvider);
    final userId = SupabaseService.currentUserId;
    final now = DateTime.now();

    return userId == null
        ? const Center(child: Text('Veuillez vous connecter'))
        : _buildDashboardContent(db, userId, now);
  }

  Widget _buildDashboardContent(AppDatabase db, String userId, DateTime now) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue sur Konta',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${_getMonthName(now.month)} ${now.year}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          StreamBuilder<double>(
            stream: _getTotalRevenue(db, userId, now),
            builder: (context, snapshot) {
              final revenue = snapshot.data ?? 0.0;
              return StreamBuilder<double>(
                stream: _getTotalExpenses(db, userId, now),
                builder: (context, snapshot) {
                  final expenses = snapshot.data ?? 0.0;
                  final cashFlow = revenue - expenses;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        context,
                        'Trésorerie',
                        _currencyFormat.format(cashFlow),
                        Icons.account_balance_wallet,
                        cashFlow >= 0
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFEF4444),
                      ),
                      _buildStatCard(
                        context,
                        'Revenus',
                        _currencyFormat.format(revenue),
                        Icons.trending_up,
                        const Color(0xFF10B981),
                      ),
                      _buildStatCard(
                        context,
                        'Dépenses',
                        _currencyFormat.format(expenses),
                        Icons.trending_down,
                        const Color(0xFFEF4444),
                      ),
                      StreamBuilder<int>(
                        stream: _getOutstandingInvoiceCount(db, userId),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return _buildStatCard(
                            context,
                            'Factures en attente',
                            count.toString(),
                            Icons.receipt_long,
                            const Color(0xFFF59E0B),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                context,
                'Nouvelle facture',
                Icons.receipt,
                () => context.push('/invoices/new'),
              ),
              _buildActionButton(
                context,
                'Nouveau devis',
                Icons.description,
                () => context.push('/quotes/new'),
              ),
              _buildActionButton(
                context,
                'Ajouter un client',
                Icons.person_add,
                () => context.push('/customers/new'),
              ),
              _buildActionButton(
                context,
                'Enregistrer une dépense',
                Icons.money_off,
                () => context.push('/expenses/new'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Chèques à encaisser',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Payment>>(
            stream: _getPendingChecks(db),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucun chèque à encaisser'),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.take(3).map((payment) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.receipt_long,
                        color: Colors.orange,
                      ),
                      title: Text(_currencyFormat.format(payment.amount)),
                      subtitle: Text(
                        'Échéance: ${DateFormat('dd/MM/yyyy').format(payment.checkDueDate!)}',
                      ),
                      trailing: payment.checkDueDate!.isBefore(DateTime.now())
                          ? const Icon(Icons.warning, color: Colors.red)
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Stream<double> _getTotalRevenue(
    AppDatabase db,
    String userId,
    DateTime now,
  ) async* {
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    await for (final _ in db.select(db.documents).watch()) {
      final invoices =
          await (db.select(db.documents)..where(
                (i) =>
                    i.companyId.equals(userId) &
                    i.type.equals(DocumentType.invoice.name) &
                    i.issueDate.isBiggerOrEqualValue(startOfMonth) &
                    i.issueDate.isSmallerOrEqualValue(endOfMonth) &
                    (i.status.equals(DocumentStatus.paid.name) |
                        i.status.equals(DocumentStatus.sent.name)),
              ))
              .get();

      final avoirs =
          await (db.select(db.documents)..where(
                (i) =>
                    i.companyId.equals(userId) &
                    i.type.equals(DocumentType.creditNote.name) &
                    i.issueDate.isBiggerOrEqualValue(startOfMonth) &
                    i.issueDate.isSmallerOrEqualValue(endOfMonth) &
                    i.status.equals(DocumentStatus.paid.name),
              ))
              .get();

      final invoiceTotal = invoices.fold<double>(
        0.0,
        (sum, inv) => sum + inv.total,
      );
      final avoirTotal = avoirs.fold<double>(0.0, (sum, av) => sum + av.total);

      yield invoiceTotal - avoirTotal;
    }
  }

  Stream<double> _getTotalExpenses(
    AppDatabase db,
    String userId,
    DateTime now,
  ) async* {
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    await for (final _ in db.select(db.expenses).watch()) {
      final expenses =
          await (db.select(db.expenses)..where(
                (e) =>
                    e.companyId.equals(userId) &
                    e.date.isBiggerOrEqualValue(startOfMonth) &
                    e.date.isSmallerOrEqualValue(endOfMonth),
              ))
              .get();

      yield expenses.fold<double>(0.0, (sum, exp) => sum + exp.amount);
    }
  }

  Stream<int> _getOutstandingInvoiceCount(
    AppDatabase db,
    String userId,
  ) async* {
    await for (final _ in db.select(db.documents).watch()) {
      final count =
          await (db.select(db.documents)..where(
                (i) =>
                    i.companyId.equals(userId) &
                    i.type.equals(DocumentType.invoice.name) &
                    (i.status.equals(DocumentStatus.sent.name) |
                        i.status.equals(DocumentStatus.overdue.name)),
              ))
              .get();

      yield count.length;
    }
  }

  Stream<List<Payment>> _getPendingChecks(AppDatabase db) {
    final now = DateTime.now();
    return (db.select(db.payments)
          ..where(
            (p) =>
                p.method.equals('check') &
                p.checkDueDate.isNotNull() &
                p.checkDueDate.isBiggerOrEqualValue(now),
          )
          ..orderBy([(p) => OrderingTerm(expression: p.checkDueDate)])
          ..limit(5))
        .watch();
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return months[month - 1];
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
