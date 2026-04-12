import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:konta/presentation/providers/payment_provider.dart';

class PaymentFormDialog extends ConsumerStatefulWidget {
  final String invoiceId;
  final double amountDue;
  final Function(double) onPaymentAdded;

  const PaymentFormDialog({
    super.key,
    required this.invoiceId,
    required this.amountDue,
    required this.onPaymentAdded,
  });

  @override
  ConsumerState<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends ConsumerState<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMethod = 'cash';
  DateTime _paymentDate = DateTime.now();
  DateTime? _checkDueDate;
  bool _isLoading = false;

  static const _methods = [
    {'value': 'cash', 'label': 'Espèces'},
    {'value': 'transfer', 'label': 'Virement bancaire'},
    {'value': 'check', 'label': 'Chèque'},
    {'value': 'bill', 'label': 'Effet de commerce'},
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amountDue.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_MA',
      symbol: 'MAD',
    );

    return AlertDialog(
      title: const Text('Enregistrer un paiement'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Montant dû: ${currencyFormat.format(widget.amountDue)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Mode de paiement',
                  border: OutlineInputBorder(),
                ),
                items: _methods.map((m) {
                  return DropdownMenuItem(
                    value: m['value'],
                    child: Text(m['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMethod = value);
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
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Montant invalide';
                  }
                  if (amount <= 0) {
                    return 'Le montant doit être positif';
                  }
                  if (amount > widget.amountDue) {
                    return 'Le montant ne peut pas dépasser le montant dû';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectPaymentDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de paiement',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_paymentDate)),
                ),
              ),
              if (_selectedMethod == 'check') ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectCheckDueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date d\'échéance du chèque',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                    ),
                    child: Text(
                      _checkDueDate != null
                          ? DateFormat('dd/MM/yyyy').format(_checkDueDate!)
                          : 'Sélectionner une date',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _savePayment,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _selectPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _paymentDate = date);
    }
  }

  Future<void> _selectCheckDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _checkDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _checkDueDate = date);
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(paymentRepositoryProvider);
      await repo.create(
        invoiceId: widget.invoiceId,
        amount: double.parse(_amountController.text),
        method: _selectedMethod,
        paymentDate: _paymentDate,
        checkDueDate: _checkDueDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      widget.onPaymentAdded(double.parse(_amountController.text));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paiement enregistré')));
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
}
