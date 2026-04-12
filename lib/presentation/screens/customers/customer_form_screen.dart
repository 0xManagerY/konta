import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/presentation/providers/customer_provider.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/domain/services/company_search_service.dart';
import 'package:konta/core/utils/logger.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const CustomerFormScreen({super.key, this.customerId});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iceController = TextEditingController();
  final _rcController = TextEditingController();
  final _ifController = TextEditingController();
  final _patenteController = TextEditingController();
  final _cnssController = TextEditingController();
  final _legalFormController = TextEditingController();
  final _capitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _faxController = TextEditingController();

  List<String> _phones = [];
  List<String> _emails = [];

  bool _isLoading = false;
  bool _isSearching = false;
  Customer? _existingCustomer;
  final _searchService = CompanySearchService();

  @override
  void initState() {
    super.initState();
    Logger.ui('CustomerFormScreen', 'INIT', widget.customerId ?? 'new');
    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    Logger.ui('CustomerFormScreen', 'LOAD_CUSTOMER', widget.customerId!);
    final repo = ref.read(customerRepositoryProvider);
    final customer = await repo.getById(widget.customerId!);
    if (customer != null && mounted) {
      Logger.ui('CustomerFormScreen', 'CUSTOMER_LOADED', customer.name);
      setState(() {
        _existingCustomer = customer;
        _nameController.text = customer.name;
        _iceController.text = customer.ice ?? '';
        _rcController.text = customer.rc ?? '';
        _ifController.text = customer.ifNumber ?? '';
        _patenteController.text = customer.patente ?? '';
        _cnssController.text = customer.cnss ?? '';
        _legalFormController.text = customer.legalForm ?? '';
        _capitalController.text = customer.capital ?? '';
        _addressController.text = customer.address ?? '';
        _faxController.text = customer.fax ?? '';
        _phones = _parseJsonList(customer.phones);
        _emails = _parseJsonList(customer.emails);
      });
    }
  }

  List<String> _parseJsonList(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      if (jsonStr.isNotEmpty) return [jsonStr];
      return [];
    }
  }

  String _listToJson(List<String> list) {
    if (list.isEmpty) return '';
    return jsonEncode(list);
  }

  @override
  void dispose() {
    Logger.ui('CustomerFormScreen', 'DISPOSE');
    _nameController.dispose();
    _iceController.dispose();
    _rcController.dispose();
    _ifController.dispose();
    _patenteController.dispose();
    _cnssController.dispose();
    _legalFormController.dispose();
    _capitalController.dispose();
    _addressController.dispose();
    _faxController.dispose();
    super.dispose();
  }

  Future<void> _searchByIce() async {
    final ice = _iceController.text.trim();
    Logger.ui('CustomerFormScreen', 'SEARCH_ICE', ice);
    if (ice.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez entrer un ICE')));
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _searchService.search(ice);
      Logger.ui(
        'CustomerFormScreen',
        'SEARCH_RESULTS',
        '${results.length} results',
      );

      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune entreprise trouvée')),
        );
        return;
      }

      final selectedInfo = results.length == 1
          ? results.first
          : await _showSearchResults(results);

      if (selectedInfo != null && mounted) {
        Logger.ui(
          'CustomerFormScreen',
          'FETCH_DETAILS',
          selectedInfo.ice ?? '',
        );
        final detailedInfo = await _searchService.getDetails(selectedInfo);
        if (detailedInfo != null && mounted) {
          Logger.ui('CustomerFormScreen', 'DETAILS_LOADED', detailedInfo.name);
          _fillFromCompanyInfo(detailedInfo);
        } else if (mounted) {
          _fillFromCompanyInfo(selectedInfo);
        }
      }
    } catch (e, st) {
      Logger.error(
        'ICE search failed',
        tag: 'CUSTOMER_FORM',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _fillFromCompanyInfo(CompanyInfo info) {
    Logger.ui('CustomerFormScreen', 'FILL_FROM_COMPANY', info.name);
    setState(() {
      _nameController.text = info.name;
      _iceController.text = info.ice ?? '';
      _rcController.text = info.rc ?? '';
      _ifController.text = info.ifNumber ?? '';
      _patenteController.text = info.patente ?? '';
      _cnssController.text = info.cnss ?? '';
      _legalFormController.text = info.legalForm ?? '';
      _capitalController.text = info.capital ?? '';
      if (info.address != null) _addressController.text = info.address!;
      _phones = List.from(info.phones);
      _emails = List.from(info.emails);
      if (info.fax != null) _faxController.text = info.fax!;
    });
  }

  Future<CompanyInfo?> _showSearchResults(List<CompanyInfo> results) async {
    return await showModalBottomSheet<CompanyInfo>(
      context: context,
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final company = results[index];
          return ListTile(
            title: Text(company.name),
            subtitle: Text('${company.ice ?? ''} • ${company.address ?? ''}'),
            onTap: () => Navigator.pop(context, company),
          );
        },
      ),
    );
  }

  Future<void> _handleSave() async {
    Logger.ui('CustomerFormScreen', 'SAVE_ATTEMPT', _nameController.text);
    if (!_formKey.currentState!.validate()) {
      Logger.ui('CustomerFormScreen', 'VALIDATION_FAILED');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(customerRepositoryProvider);
      final userId = SupabaseService.currentUserId;

      if (userId == null) {
        Logger.error('User not authenticated', tag: 'CUSTOMER_FORM');
        throw Exception('Utilisateur non connecté');
      }

      final now = DateTime.now();
      final customerId = _existingCustomer?.id ?? await repo.generateId();

      final customer = Customer(
        id: customerId,
        userId: userId,
        name: _nameController.text.trim(),
        ice: _iceController.text.trim().isEmpty
            ? null
            : _iceController.text.trim(),
        rc: _rcController.text.trim().isEmpty
            ? null
            : _rcController.text.trim(),
        ifNumber: _ifController.text.trim().isEmpty
            ? null
            : _ifController.text.trim(),
        patente: _patenteController.text.trim().isEmpty
            ? null
            : _patenteController.text.trim(),
        cnss: _cnssController.text.trim().isEmpty
            ? null
            : _cnssController.text.trim(),
        legalForm: _legalFormController.text.trim().isEmpty
            ? null
            : _legalFormController.text.trim(),
        capital: _capitalController.text.trim().isEmpty
            ? null
            : _capitalController.text.trim(),
        status: _existingCustomer?.status,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phones: _listToJson(_phones),
        fax: _faxController.text.trim().isEmpty
            ? null
            : _faxController.text.trim(),
        emails: _listToJson(_emails),
        createdAt: _existingCustomer?.createdAt ?? now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      if (_existingCustomer == null) {
        Logger.ui('CustomerFormScreen', 'INSERT_CUSTOMER', customer.id);
        await repo.insert(customer);
      } else {
        Logger.ui('CustomerFormScreen', 'UPDATE_CUSTOMER', customer.id);
        await repo.update(customer);
      }

      Logger.ui('CustomerFormScreen', 'SAVE_SUCCESS');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingCustomer == null
                  ? 'Client ajouté avec succès'
                  : 'Client mis à jour avec succès',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    } catch (e, st) {
      Logger.error(
        'Save customer failed',
        tag: 'CUSTOMER_FORM',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addPhone() {
    setState(() {
      _phones.add('');
    });
  }

  void _removePhone(int index) {
    setState(() {
      _phones.removeAt(index);
    });
  }

  void _updatePhone(int index, String value) {
    setState(() {
      _phones[index] = value;
    });
  }

  void _addEmail() {
    setState(() {
      _emails.add('');
    });
  }

  void _removeEmail(int index) {
    setState(() {
      _emails.removeAt(index);
    });
  }

  void _updateEmail(int index, String value) {
    setState(() {
      _emails[index] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingCustomer == null ? 'Nouveau client' : 'Modifier le client',
        ),
        actions: [
          if (_existingCustomer != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _handleDelete(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du client *',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iceController,
                decoration: InputDecoration(
                  labelText: 'ICE (15 chiffres)',
                  prefixIcon: const Icon(Icons.numbers),
                  suffixIcon: IconButton(
                    icon: _isSearching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    onPressed: _isSearching ? null : _searchByIce,
                    tooltip: 'Rechercher par ICE',
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\d{15}$').hasMatch(value)) {
                      return 'L\'ICE doit contenir exactement 15 chiffres';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rcController,
                      decoration: const InputDecoration(
                        labelText: 'RC',
                        prefixIcon: Icon(Icons.receipt_long),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ifController,
                      decoration: const InputDecoration(
                        labelText: 'IF',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _patenteController,
                      decoration: const InputDecoration(
                        labelText: 'Patente',
                        prefixIcon: Icon(Icons.assignment),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cnssController,
                      decoration: const InputDecoration(
                        labelText: 'CNSS',
                        prefixIcon: Icon(Icons.people),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _legalFormController,
                      decoration: const InputDecoration(
                        labelText: 'Forme juridique',
                        prefixIcon: Icon(Icons.gavel),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _capitalController,
                      decoration: const InputDecoration(
                        labelText: 'Capital',
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildDynamicList(
                label: 'Téléphone',
                icon: Icons.phone,
                items: _phones,
                onAdd: _addPhone,
                onRemove: _removePhone,
                onUpdate: _updatePhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _faxController,
                decoration: const InputDecoration(
                  labelText: 'Fax',
                  prefixIcon: Icon(Icons.print),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildDynamicList(
                label: 'Email',
                icon: Icons.email,
                items: _emails,
                onAdd: _addEmail,
                onRemove: _removeEmail,
                onUpdate: _updateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicList({
    required String label,
    required IconData icon,
    required List<String> items,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required void Function(int, String) onUpdate,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '$label${items.isEmpty ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAdd,
              tooltip: 'Ajouter $label',
              iconSize: 20,
            ),
          ],
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'Aucun $label',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(width: 28),
                Expanded(
                  child: TextFormField(
                    initialValue: entry.value,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: keyboardType,
                    onChanged: (value) => onUpdate(index, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => onRemove(index),
                  iconSize: 20,
                  color: Colors.red[400],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _handleDelete() async {
    Logger.ui('CustomerFormScreen', 'DELETE_ATTEMPT', widget.customerId!);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le client'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce client ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Logger.ui('CustomerFormScreen', 'DELETE_CONFIRMED', widget.customerId!);
      final repo = ref.read(customerRepositoryProvider);
      await repo.delete(widget.customerId!);
      if (mounted) {
        Logger.ui('CustomerFormScreen', 'DELETE_SUCCESS');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client supprimé'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    }
  }
}
