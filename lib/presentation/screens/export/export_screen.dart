import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/repositories/invoice_repository.dart';
import 'package:konta/data/repositories/expense_repository.dart';
import 'package:konta/data/repositories/customer_repository.dart';
import 'package:konta/domain/services/export_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/data/remote/supabase_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export mensuel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sélectionner le mois',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _selectMonth,
                          icon: const Icon(Icons.edit),
                          label: const Text('Changer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenu de l\'export',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildExportItem(
                      Icons.table_chart,
                      'ventes_YYYY_MM.xlsx',
                      'Liste des factures du mois',
                    ),
                    _buildExportItem(
                      Icons.table_chart,
                      'depenses_YYYY_MM.xlsx',
                      'Liste des dépenses du mois',
                    ),
                    _buildExportItem(
                      Icons.picture_as_pdf,
                      'FAC-YYYY-XXXX.pdf',
                      'Factures en PDF',
                    ),
                    _buildExportItem(
                      Icons.image,
                      'recu_*.jpg',
                      'Reçus de dépenses',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportMonth,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Export en cours...' : 'Exporter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportItem(IconData icon, String filename, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _exportMonth() async {
    final db = ref.read(databaseProvider);
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

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

    setState(() => _isExporting = true);

    try {
      final invoiceRepo = InvoiceRepository(db);
      final expenseRepo = ExpenseRepository(db);
      final customerRepo = CustomerRepository(db);

      final exportService = ExportService(
        invoiceRepo,
        expenseRepo,
        customerRepo,
      );

      final exportPath = await exportService.exportMonthlyBundle(
        company: profile,
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );

      await exportService.shareExport(exportPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
}
