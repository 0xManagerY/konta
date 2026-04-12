import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/domain/services/ocr_service.dart';
import 'package:konta/presentation/providers/expense_provider.dart';
import 'package:konta/core/utils/logger.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final String? expenseId;

  const ExpenseFormScreen({super.key, this.expenseId});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tvaController = TextEditingController();

  String _selectedCategory = 'Achat marchandises';
  DateTime _selectedDate = DateTime.now();
  bool _isDeductible = true;
  String? _receiptPath;
  bool _isLoading = false;
  bool _isProcessingOcr = false;
  final _imagePicker = ImagePicker();

  static const _categories = [
    'Achat marchandises',
    'Fournitures',
    'Loyer',
    'Électricité',
    'Eau',
    'Téléphone/Internet',
    'Transport',
    'Salaires',
    'Charges sociales',
    'Frais bancaires',
    'Impôts et taxes',
    'Maintenance',
    'Publicité',
    'Autres',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _tvaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expenseId == null ? 'Nouvelle dépense' : 'Modifier dépense',
        ),
        actions: [
          if (widget.expenseId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteExpense(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scanner un reçu',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_isProcessingOcr)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Caméra'),
                              onPressed: () =>
                                  _pickAndProcessImage(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galerie'),
                              onPressed: () =>
                                  _pickAndProcessImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                    if (_receiptPath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Reçu sélectionné',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Montant (MAD)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le montant est obligatoire';
                }
                if (double.tryParse(value) == null) {
                  return 'Montant invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tvaController,
              decoration: const InputDecoration(
                labelText: 'TVA (MAD)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dépense déductible'),
              subtitle: const Text(
                'Cette dépense peut être déduite des impôts',
              ),
              value: _isDeductible,
              onChanged: (value) => setState(() => _isDeductible = value),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : () => _saveExpense(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    Logger.info('Starting image picker', tag: 'EXPENSE_FORM');
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      Logger.info(
        'Image picker returned: ${image != null ? "image" : "null"}',
        tag: 'EXPENSE_FORM',
      );

      if (image == null) {
        Logger.info('User cancelled image picker', tag: 'EXPENSE_FORM');
        return;
      }

      Logger.info('Image path: ${image.path}', tag: 'EXPENSE_FORM');

      if (!mounted) {
        Logger.warning(
          'Widget not mounted after picking image',
          tag: 'EXPENSE_FORM',
        );
        return;
      }

      setState(() {
        _isProcessingOcr = true;
        _receiptPath = image.path;
      });

      Logger.info(
        'Set _isProcessingOcr = true, starting OCR',
        tag: 'EXPENSE_FORM',
      );

      final result = await OcrService.instance.processReceipt(image.path);
      Logger.info(
        'OCR completed, success: ${result.success}',
        tag: 'EXPENSE_FORM',
      );

      if (!mounted) {
        Logger.warning('Widget not mounted after OCR', tag: 'EXPENSE_FORM');
        return;
      }

      if (result.success) {
        setState(() {
          _isProcessingOcr = false;
          if (result.extractedAmount != null) {
            _amountController.text = result.extractedAmount!.toStringAsFixed(2);
            Logger.info(
              'Extracted amount: ${result.extractedAmount}',
              tag: 'EXPENSE_FORM',
            );
          }
          if (result.extractedDate != null) {
            _selectedDate = result.extractedDate!;
            Logger.info(
              'Extracted date: ${result.extractedDate}',
              tag: 'EXPENSE_FORM',
            );
          }
          if (result.merchantName != null &&
              _descriptionController.text.isEmpty) {
            _descriptionController.text = result.merchantName!;
            Logger.info(
              'Extracted merchant: ${result.merchantName}',
              tag: 'EXPENSE_FORM',
            );
          }
          if (result.compressedImagePath != null) {
            _receiptPath = result.compressedImagePath;
          }
        });

        if (result.extractedAmount != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Montant détecté: ${result.extractedAmount!.toStringAsFixed(2)} MAD',
              ),
            ),
          );
        }
      } else {
        setState(() => _isProcessingOcr = false);
        Logger.error('OCR failed', tag: 'EXPENSE_FORM', error: result.error);
        if (result.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur OCR: ${result.error}')),
          );
        }
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Exception in _pickAndProcessImage',
        tag: 'EXPENSE_FORM',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isProcessingOcr = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      if (mounted) context.go('/login');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.create(
        userId: userId,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        tvaAmount: _tvaController.text.isNotEmpty
            ? double.parse(_tvaController.text)
            : 0,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        receiptLocalPath: _receiptPath,
        isDeductible: _isDeductible,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dépense enregistrée')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExpense() async {
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

    if (confirmed == true && widget.expenseId != null) {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.delete(widget.expenseId!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dépense supprimée')));
        context.pop();
      }
    }
  }
}
