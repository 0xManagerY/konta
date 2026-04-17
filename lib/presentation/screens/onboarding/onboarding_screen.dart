import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/presentation/providers/auth_provider.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/presentation/providers/sync_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _companyFormKey = GlobalKey<FormState>();
  final _identifiersFormKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _iceController = TextEditingController();
  final _ifController = TextEditingController();
  final _rcController = TextEditingController();
  final _cnssController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedLegalStatus = 'SARL';
  bool _isAutoEntrepreneur = false;
  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _legalStatuses = ['SARL', 'SARL-AU', 'AE', 'SNC'];

  @override
  void initState() {
    super.initState();
    Logger.ui('OnboardingScreen', 'INIT');
  }

  @override
  void dispose() {
    Logger.ui('OnboardingScreen', 'DISPOSE');
    _companyNameController.dispose();
    _iceController.dispose();
    _ifController.dispose();
    _rcController.dispose();
    _cnssController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    Logger.ui('OnboardingScreen', 'VALIDATE_STEP_$_currentStep');

    if (_currentStep == 0) {
      final valid = _companyFormKey.currentState!.validate();
      Logger.ui('OnboardingScreen', 'STEP_0_VALID: $valid');
      return valid;
    }
    if (_currentStep == 2) {
      final valid = _identifiersFormKey.currentState!.validate();
      Logger.ui('OnboardingScreen', 'STEP_2_VALID: $valid');
      return valid;
    }
    return true;
  }

  Future<void> _handleComplete() async {
    Logger.ui('OnboardingScreen', 'HANDLE_COMPLETE_START');

    Logger.ui('OnboardingScreen', 'COMPANY: ${_companyNameController.text}');
    Logger.ui('OnboardingScreen', 'ICE: ${_iceController.text}');
    Logger.ui('OnboardingScreen', 'LEGAL_STATUS: $_selectedLegalStatus');

    final isValid = _identifiersFormKey.currentState?.validate() ?? false;
    Logger.ui('OnboardingScreen', 'FORM_VALID: $isValid');

    if (!isValid) {
      Logger.ui('OnboardingScreen', 'VALIDATION_FAILED - STOPPING');
      return;
    }

    setState(() => _isLoading = true);
    Logger.ui('OnboardingScreen', 'LOADING_STARTED');

    try {
      final repo = ref.read(profileRepoProvider);
      final syncController = ref.read(syncControllerProvider);
      final userId = SupabaseService.currentUserId;
      final userEmail = SupabaseService.auth.currentUser?.email ?? '';

      Logger.ui('OnboardingScreen', 'USER_ID: $userId');
      Logger.ui('OnboardingScreen', 'USER_EMAIL: $userEmail');

      if (userId == null) {
        Logger.error('USER_ID_IS_NULL', tag: 'ONBOARDING');
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final companyId = const Uuid().v4();
      final company = Company(
        id: companyId,
        name: _companyNameController.text.trim(),
        legalStatus: _selectedLegalStatus,
        ice: _iceController.text.trim().isNotEmpty
            ? _iceController.text.trim()
            : null,
        ifNumber: _ifController.text.trim().isNotEmpty
            ? _ifController.text.trim()
            : null,
        rc: _rcController.text.trim().isNotEmpty
            ? _rcController.text.trim()
            : null,
        cnss: _cnssController.text.trim().isNotEmpty
            ? _cnssController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        isAutoEntrepreneur: _isAutoEntrepreneur,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      final profile = UserProfile(
        id: userId,
        email: userEmail,
        defaultCompanyId: companyId,
        createdAt: now,
        updatedAt: now,
      );

      Logger.ui('OnboardingScreen', 'PROFILE_CREATED');
      Logger.ui('OnboardingScreen', ' companyName: ${company.name}');
      Logger.ui('OnboardingScreen', ' legalStatus: ${company.legalStatus}');
      Logger.ui('OnboardingScreen', ' ice: ${company.ice}');

      Logger.ui('OnboardingScreen', 'CALLING UPSERT_PROFILE');
      try {
        final db = ref.read(databaseProvider);
        await (db.into(db.companies).insertOnConflictUpdate(company));
        await repo.upsertProfile(profile);
      } catch (e, st) {
        Logger.error(
          'UPSERT_FAILED',
          tag: 'ONBOARDING',
          error: e,
          stackTrace: st,
        );
        rethrow;
      }
      Logger.ui('OnboardingScreen', 'PROFILE_UPSERTED_OK');

      Logger.ui('OnboardingScreen', 'CALLING SYNC_ALL');
      await syncController.syncNow();
      Logger.ui('OnboardingScreen', 'SYNC_COMPLETE_OK');

      if (mounted) {
        Logger.ui('OnboardingScreen', 'INVALIDATING PROVIDER');
        ref.invalidate(needsOnboardingProvider);
        Logger.ui('OnboardingScreen', 'NAVIGATING_TO_HOME');
        context.go('/');
      }
    } catch (e, st) {
      Logger.error(
        'ONBOARDING_ERROR',
        tag: 'ONBOARDING',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      Logger.ui('OnboardingScreen', 'FINALLY_BLOCK');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            Logger.ui(
              'OnboardingScreen',
              'ON_STEP_CONTINUE currentStep=$_currentStep',
            );
            if (_currentStep < 2) {
              if (_validateCurrentStep()) {
                setState(() => _currentStep++);
              }
            } else {
              Logger.ui('OnboardingScreen', 'STEP_2_CALLING_HANDLE_COMPLETE');
              _handleComplete();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_currentStep == 2 ? 'Terminer' : 'Suivant'),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Retour'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Entreprise'),
              content: _buildCompanyStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Statut'),
              content: _buildLegalStatusStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Identifiants'),
              content: _buildIdentifiersStep(),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyStep() {
    return Form(
      key: _companyFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'entreprise *',
              prefixIcon: Icon(Icons.business),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Le nom de l\'entreprise est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalStatusStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statut juridique',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RadioGroup<String>(
          groupValue: _selectedLegalStatus,
          onChanged: (v) {
            setState(() {
              _selectedLegalStatus = v!;
              _isAutoEntrepreneur = v == 'AE';
            });
          },
          child: Column(
            children: _legalStatuses
                .map(
                  (status) => ListTile(
                    leading: Radio<String>(value: status),
                    title: Text(_getLegalStatusLabel(status)),
                    onTap: () {
                      setState(() {
                        _selectedLegalStatus = status;
                        _isAutoEntrepreneur = status == 'AE';
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ),
        if (_isAutoEntrepreneur)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'TVA au taux de 1% (Article 91 du CGI)',
                    style: TextStyle(color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIdentifiersStep() {
    return Form(
      key: _identifiersFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _iceController,
            decoration: const InputDecoration(
              labelText: 'ICE (15 chiffres) *',
              prefixIcon: Icon(Icons.badge),
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            maxLength: 15,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => null,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'L\'ICE est requis';
              }
              if (v.trim().length != 15) {
                return 'L\'ICE doit contenir exactement 15 chiffres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ifController,
            decoration: const InputDecoration(
              labelText: 'Identifiant Fiscal (IF)',
              prefixIcon: Icon(Icons.receipt_long),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rcController,
            decoration: const InputDecoration(
              labelText: 'Registre de Commerce (RC)',
              prefixIcon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cnssController,
            decoration: const InputDecoration(
              labelText: 'CNSS',
              prefixIcon: Icon(Icons.health_and_safety),
            ),
          ),
        ],
      ),
    );
  }

  String _getLegalStatusLabel(String status) {
    switch (status) {
      case 'SARL':
        return 'SARL - Société à Responsabilité Limitée';
      case 'SARL-AU':
        return 'SARL-AU - Société à Responsabilité Limitée Unipersonnelle';
      case 'AE':
        return 'Auto-Entrepreneur';
      case 'SNC':
        return 'SNC - Société en Nom Collectif';
      default:
        return status;
    }
  }
}
