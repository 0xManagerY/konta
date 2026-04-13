import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/repositories/profile_repository.dart';
import 'package:konta/presentation/providers/database_provider.dart';

final _profileProvider = StreamProvider<Profile?>((ref) {
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) return Stream.value(null);
  return (db.select(
    db.profiles,
  )..where((p) => p.id.equals(userId))).watchSingleOrNull();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil entreprise'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Logger.ui('ProfileScreen', 'EDIT_BUTTON_TAP');
                final profile = profileAsync.valueOrNull;
                if (profile != null) {
                  _companyNameController.text = profile.companyName;
                  _iceController.text = profile.ice ?? '';
                  _ifController.text = profile.ifNumber ?? '';
                  _rcController.text = profile.rc ?? '';
                  _cnssController.text = profile.cnss ?? '';
                  _addressController.text = profile.address ?? '';
                  _phoneController.text = profile.phone ?? '';
                  _legalStatusController.text = profile.legalStatus;
                  _isAutoEntrepreneur = profile.isAutoEntrepreneur;
                }
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profil non trouvé'));
          }
          return _buildContent(profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildContent(Profile profile) {
    if (!_isEditing) {
      return _buildViewMode(profile);
    }
    return _buildEditMode(profile);
  }

  Widget _buildViewMode(Profile profile) {
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
                  child: profile.logoUrl != null && profile.logoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            profile.logoUrl!,
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
                  profile.companyName.isNotEmpty
                      ? profile.companyName
                      : 'Entreprise non configurée',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (profile.isAutoEntrepreneur)
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
                  _buildInfoTile('Statut juridique', profile.legalStatus),
                  if (profile.ice != null && profile.ice!.isNotEmpty)
                    _buildInfoTile('ICE', profile.ice!),
                  if (profile.ifNumber != null && profile.ifNumber!.isNotEmpty)
                    _buildInfoTile('Identifiant fiscal', profile.ifNumber!),
                  if (profile.rc != null && profile.rc!.isNotEmpty)
                    _buildInfoTile('RC', profile.rc!),
                  if (profile.cnss != null && profile.cnss!.isNotEmpty)
                    _buildInfoTile('CNSS', profile.cnss!),
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
                  if (profile.address != null && profile.address!.isNotEmpty)
                    _buildInfoTile(
                      'Adresse',
                      profile.address!,
                      icon: Icons.location_on,
                    ),
                  if (profile.phone != null && profile.phone!.isNotEmpty)
                    _buildInfoTile(
                      'Téléphone',
                      profile.phone!,
                      icon: Icons.phone,
                    ),
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

  Widget _buildEditMode(Profile profile) {
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
            value: _legalStatusController.text.isNotEmpty
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
                  onPressed: _isLoading ? null : () => _saveProfile(profile),
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
    if (image != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logo sélectionné')));
    }
  }

  Future<void> _saveProfile(Profile profile) async {
    Logger.ui(
      'ProfileScreen',
      'SAVE_PROFILE',
      'company: ${_companyNameController.text}',
    );
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final repo = ProfileRepository(db);

      final updatedProfile = Profile(
        id: profile.id,
        email: profile.email,
        companyName: _companyNameController.text,
        legalStatus: _legalStatusController.text,
        ice: _iceController.text.isNotEmpty ? _iceController.text : null,
        ifNumber: _ifController.text.isNotEmpty ? _ifController.text : null,
        rc: _rcController.text.isNotEmpty ? _rcController.text : null,
        cnss: _cnssController.text.isNotEmpty ? _cnssController.text : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        logoUrl: profile.logoUrl,
        isAutoEntrepreneur: _isAutoEntrepreneur,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await repo.updateProfile(updatedProfile);

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
