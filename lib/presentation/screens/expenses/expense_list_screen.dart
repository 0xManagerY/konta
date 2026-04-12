import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/expense_provider.dart';
import 'package:konta/core/utils/logger.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');

  @override
  void initState() {
    super.initState();
    Logger.ui('ExpenseListScreen', 'INIT');
  }

  @override
  void dispose() {
    Logger.ui('ExpenseListScreen', 'DISPOSE');
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher une dépense...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {},
          ),
        ),
        Expanded(
          child: expensesAsync.when(
            data: (expenses) {
              if (expenses.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune dépense. Ajoutez votre première dépense.',
                  ),
                );
              }
              return ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return _buildExpenseCard(expense);
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

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(expense.category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getCategoryIcon(expense.category), color: Colors.white),
        ),
        title: Text(
          expense.category,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currencyFormat.format(expense.amount)),
            Text(
              DateFormat('dd/MM/yyyy').format(expense.date),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (expense.description != null)
              Text(
                expense.description!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: expense.isDeductible
            ? Chip(
                label: const Text('Déductible'),
                backgroundColor: Colors.green.shade100,
                labelStyle: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 11,
                ),
              )
            : null,
        onTap: () => context.push('/expenses/${expense.id}'),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Achat marchandises':
        return Colors.blue;
      case 'Fournitures':
        return Colors.orange;
      case 'Loyer':
        return Colors.purple;
      case 'Électricité':
      case 'Eau':
        return Colors.amber;
      case 'Téléphone/Internet':
        return Colors.cyan;
      case 'Transport':
        return Colors.indigo;
      case 'Salaires':
      case 'Charges sociales':
        return Colors.teal;
      case 'Frais bancaires':
        return Colors.red;
      case 'Impôts et taxes':
        return Colors.brown;
      case 'Maintenance':
        return Colors.grey;
      case 'Publicité':
        return Colors.pink;
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Achat marchandises':
        return Icons.shopping_bag;
      case 'Fournitures':
        return Icons.inventory_2;
      case 'Loyer':
        return Icons.home;
      case 'Électricité':
        return Icons.bolt;
      case 'Eau':
        return Icons.water_drop;
      case 'Téléphone/Internet':
        return Icons.wifi;
      case 'Transport':
        return Icons.directions_car;
      case 'Salaires':
        return Icons.people;
      case 'Charges sociales':
        return Icons.health_and_safety;
      case 'Frais bancaires':
        return Icons.account_balance;
      case 'Impôts et taxes':
        return Icons.receipt_long;
      case 'Maintenance':
        return Icons.build;
      case 'Publicité':
        return Icons.campaign;
      default:
        return Icons.receipt;
    }
  }
}
