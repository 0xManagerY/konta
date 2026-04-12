import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final _expenseProvider = StreamProvider.autoDispose.family<Expense?, String>((
  ref,
  expenseId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.expenses,
  )..where((e) => e.id.equals(expenseId))).watchSingleOrNull();
});

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;
  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(_expenseProvider(expenseId));
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_MA',
      symbol: 'MAD',
    );

    return expenseAsync.when(
      data: (expense) {
        if (expense == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Non trouvé')),
            body: const Center(child: Text('Dépense non trouvée')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(expense.category),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/expenses/edit/$expenseId'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteExpense(context, ref, expense),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Détails',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (expense.isDeductible)
                              Chip(
                                label: const Text('Déductible'),
                                backgroundColor: Colors.green.shade100,
                                labelStyle: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Catégorie',
                          expense.category,
                          Icons.category,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Montant',
                          currencyFormat.format(expense.amount),
                          Icons.attach_money,
                        ),
                        if (expense.tvaAmount > 0) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'TVA',
                            currencyFormat.format(expense.tvaAmount),
                            Icons.percent,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Date',
                          DateFormat('dd/MM/yyyy').format(expense.date),
                          Icons.calendar_today,
                        ),
                        if (expense.description != null &&
                            expense.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Description',
                            expense.description!,
                            Icons.description,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (expense.receiptUrl != null &&
                    expense.receiptUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reçu',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showReceiptPreview(
                              context,
                              expense.receiptUrl!,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(expense.receiptUrl!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Impossible de charger le reçu',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => _showReceiptPreview(
                                context,
                                expense.receiptUrl!,
                              ),
                              icon: const Icon(Icons.zoom_in),
                              label: const Text('Voir en grand'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReceiptPreview(BuildContext context, String receiptPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReceiptPreviewScreen(receiptPath: receiptPath),
      ),
    );
  }

  Future<void> _deleteExpense(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la dépense'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette dépense ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await (db.delete(
        db.expenses,
      )..where((e) => e.id.equals(expense.id))).go();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dépense supprimée')));
        context.pop();
      }
    }
  }
}

class ReceiptPreviewScreen extends StatelessWidget {
  final String receiptPath;
  const ReceiptPreviewScreen({super.key, required this.receiptPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçu'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(receiptPath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impossible de charger l\'image',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
