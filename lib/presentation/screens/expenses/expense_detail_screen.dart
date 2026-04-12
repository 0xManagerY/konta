import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/storage_service.dart';
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

        final hasReceipt =
            expense.receiptLocalPath != null &&
            expense.receiptLocalPath!.isNotEmpty;

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
                if (hasReceipt) ...[
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
                              expense.receiptLocalPath!,
                              expense.receiptUrl,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _ReceiptThumbnail(
                                localPath: expense.receiptLocalPath,
                                remoteUrl: expense.receiptUrl,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => _showReceiptPreview(
                                context,
                                expense.receiptLocalPath!,
                                expense.receiptUrl,
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

  void _showReceiptPreview(
    BuildContext context,
    String localPath,
    String? remoteUrl,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ReceiptPreviewScreen(localPath: localPath, remoteUrl: remoteUrl),
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

class _ReceiptThumbnail extends StatefulWidget {
  final String? localPath;
  final String? remoteUrl;

  const _ReceiptThumbnail({this.localPath, this.remoteUrl});

  @override
  State<_ReceiptThumbnail> createState() => _ReceiptThumbnailState();
}

class _ReceiptThumbnailState extends State<_ReceiptThumbnail> {
  File? _localFile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.localPath != null && widget.localPath!.isNotEmpty) {
      final file = File(widget.localPath!);
      if (await file.exists()) {
        setState(() {
          _localFile = file;
          _loading = false;
        });
        return;
      }
    }

    if (widget.remoteUrl != null &&
        widget.remoteUrl!.isNotEmpty &&
        StorageService.isRemoteUrl(widget.remoteUrl)) {
      final file = await StorageService.downloadReceipt(widget.remoteUrl!);
      if (mounted && file != null) {
        setState(() {
          _localFile = file;
          _loading = false;
        });
        return;
      }
    }

    if (mounted) {
      setState(() {
        _error = 'Impossible de charger le reçu';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _localFile == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger le reçu',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Image.file(
      _localFile!,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

class ReceiptPreviewScreen extends StatefulWidget {
  final String localPath;
  final String? remoteUrl;

  const ReceiptPreviewScreen({
    super.key,
    required this.localPath,
    this.remoteUrl,
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  File? _localFile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(widget.localPath);
    if (await file.exists()) {
      setState(() {
        _localFile = file;
        _loading = false;
      });
      return;
    }

    if (widget.remoteUrl != null &&
        widget.remoteUrl!.isNotEmpty &&
        StorageService.isRemoteUrl(widget.remoteUrl)) {
      final downloaded = await StorageService.downloadReceipt(
        widget.remoteUrl!,
      );
      if (mounted && downloaded != null) {
        setState(() {
          _localFile = downloaded;
          _loading = false;
        });
        return;
      }
    }

    if (mounted) {
      setState(() {
        _error = 'Impossible de charger l\'image';
        _loading = false;
      });
    }
  }

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
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : _error != null || _localFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error ?? 'Impossible de charger l\'image',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              )
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(_localFile!, fit: BoxFit.contain),
              ),
      ),
    );
  }
}
