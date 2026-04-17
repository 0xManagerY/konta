import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final _profileProvider = StreamProvider<UserProfile?>((ref) {
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) return Stream.value(null);
  return (db.select(
    db.userProfiles,
  )..where((p) => p.id.equals(userId))).watchSingleOrNull();
});

final _companyProvider = StreamProvider.family<Company?, String>((
  ref,
  companyId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.companies,
  )..where((c) => c.id.equals(companyId))).watchSingleOrNull();
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _iceController = TextEditingController();
  final _ifController = TextEditingController();
  final _rcController = TextEditingController();
  final _cnssController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _legalStatusController = TextEditingController();
  bool _isAutoEntrepreneur = false;
  bool _isLoading = false;
  bool _isEditing = false;

  static const _legalStatuses = [
    'Auto-entrepreneur',
    'SARL',
    'EURL',
    'SNC',
    'SA',
    'SAS',
    'Personne physique',
  ];

  @override
  void dispose() {
    Logger.ui('ProfileScreen', 'DISPOSE');
    _companyNameController.dispose();
    _iceController.dispose();
    _ifController.dispose();
    _rcController.dispose();
    _cnssController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _legalStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.ui('ProfileScreen', 'BUILD');
    final profileAsync = ref.watch(_profileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profil entreprise')),
            body: const Center(child: Text('Profil non trouvé')),
          );
        }
        final companyAsync = ref.watch(
          _companyProvider(profile.defaultCompanyId ?? ''),
        );
        return companyAsync.when(
          data: (company) => _buildScaffold(profile, company),
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Profil entreprise')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Profil entreprise')),
            body: Center(child: Text('Erreur: $error')),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Profil entreprise')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Profil entreprise')),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildScaffold(UserProfile profile, Company? company) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil entreprise'),
        actions: [
          if (!_isEditing && company != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Logger.ui('ProfileScreen', 'EDIT_BUTTON_TAP');
                _companyNameController.text = company.name;
                _iceController.text = company.ice ?? '';
                _ifController.text = company.ifNumber ?? '';
                _rcController.text = company.rc ?? '';
                _cnssController.text = company.cnss ?? '';
                _addressController.text = company.address ?? '';
                _phoneController.text = company.phone ?? '';
                _legalStatusController.text = company.legalStatus;
                _isAutoEntrepreneur = company.isAutoEntrepreneur;
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: _buildContent(profile, company),
    );
  }

  Widget _buildContent(UserProfile profile, Company? company) {
    if (!_isEditing) {
      return _buildViewMode(profile, company);
    }
    return _buildEditMode(profile, company);
  }

  Widget _buildViewMode(UserProfile profile, Company? company) {
    final companyName = company?.name ?? '';
    final legalStatus = company?.legalStatus ?? '';
    final ice = company?.ice;
    final ifNumber = company?.ifNumber;
    final rc = company?.rc;
    final cnss = company?.cnss;
    final address = company?.address;
    final phone = company?.phone;
    final logoUrl = company?.logoUrl;
    final isAutoEntrepreneur = company?.isAutoEntrepreneur ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: 0.1),
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            logoUrl,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.business,
                              size: 48,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.business,
                          size: 48,
                          color: Color(0xFF2563EB),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  companyName.isNotEmpty
                      ? companyName
                      : 'Entreprise non configurée',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (isAutoEntrepreneur)
                  Chip(
                    label: const Text('Auto-entrepreneur'),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(color: Colors.green.shade800),
                  ),
              ],
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
                    'Informations légales',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile('Statut juridique', legalStatus),
                  if (ice != null && ice.isNotEmpty) _buildInfoTile('ICE', ice),
                  if (ifNumber != null && ifNumber.isNotEmpty)
                    _buildInfoTile('Identifiant fiscal', ifNumber),
                  if (rc != null && rc.isNotEmpty) _buildInfoTile('RC', rc),
                  if (cnss != null && cnss.isNotEmpty)
                    _buildInfoTile('CNSS', cnss),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (address != null && address.isNotEmpty)
                    _buildInfoTile('Adresse', address, icon: Icons.location_on),
                  if (phone != null && phone.isNotEmpty)
                    _buildInfoTile('Téléphone', phone, icon: Icons.phone),
                  _buildInfoTile('Email', profile.email, icon: Icons.email),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compte',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    'Membre depuis',
                    DateFormat('dd/MM/yyyy').format(profile.createdAt),
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
          ],
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
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(UserProfile profile, Company? company) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(
                    0xFF2563EB,
                  ).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.business,
                    size: 48,
                    color: Color(0xFF2563EB),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'entreprise',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _legalStatusController.text.isNotEmpty
                ? _legalStatusController.text
                : 'SARL',
            decoration: const InputDecoration(
              labelText: 'Statut juridique',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.gavel),
            ),
            items: _legalStatuses.map((status) {
              return DropdownMenuItem(value: status, child: Text(status));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _legalStatusController.text = value;
                  _isAutoEntrepreneur = value == 'Auto-entrepreneur';
                });
              }
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto-entrepreneur'),
            subtitle: const Text('Régime fiscal simplifié'),
            value: _isAutoEntrepreneur,
            onChanged: (value) {
              setState(() {
                _isAutoEntrepreneur = value;
                if (value) {
                  _legalStatusController.text = 'Auto-entrepreneur';
                }
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _iceController,
            decoration: const InputDecoration(
              labelText: 'ICE',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
              helperText: 'Identifiant Commun de l\'Entreprise',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ifController,
            decoration: const InputDecoration(
              labelText: 'Identifiant fiscal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.receipt),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rcController,
            decoration: const InputDecoration(
              labelText: 'RC (Registre du Commerce)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.book),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cnssController,
            decoration: const InputDecoration(
              labelText: 'CNSS',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.health_and_safety),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _isEditing = false),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading
                      ? null
                      : () => _saveProfile(profile, company),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickLogo() async {
    Logger.ui('ProfileScreen', 'PICK_LOGO');
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logo sélectionné')));
    }
  }

  Future<void> _saveProfile(UserProfile profile, Company? company) async {
    Logger.ui(
      'ProfileScreen',
      'SAVE_PROFILE',
      'company: ${_companyNameController.text}',
    );
    if (!_formKey.currentState!.validate()) return;
    if (company == null) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);

      await (db.update(
        db.companies,
      )..where((c) => c.id.equals(company.id))).write(
        CompaniesCompanion(
          name: Value(_companyNameController.text.trim()),
          legalStatus: Value(_legalStatusController.text.trim()),
          ice: Value(
            _iceController.text.trim().isNotEmpty
                ? _iceController.text.trim()
                : null,
          ),
          ifNumber: Value(
            _ifController.text.trim().isNotEmpty
                ? _ifController.text.trim()
                : null,
          ),
          rc: Value(
            _rcController.text.trim().isNotEmpty
                ? _rcController.text.trim()
                : null,
          ),
          cnss: Value(
            _cnssController.text.trim().isNotEmpty
                ? _cnssController.text.trim()
                : null,
          ),
          address: Value(
            _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
          ),
          phone: Value(
            _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
          ),
          isAutoEntrepreneur: Value(_isAutoEntrepreneur),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
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
