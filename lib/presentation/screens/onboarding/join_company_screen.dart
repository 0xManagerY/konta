import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/repositories/company_invite_repository.dart';
import 'package:konta/data/repositories/company_user_repository.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:uuid/uuid.dart';

class JoinCompanyScreen extends ConsumerStatefulWidget {
  const JoinCompanyScreen({super.key});

  @override
  ConsumerState<JoinCompanyScreen> createState() => _JoinCompanyScreenState();
}

class _JoinCompanyScreenState extends ConsumerState<JoinCompanyScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Logger.ui('JoinCompanyScreen', 'INIT');
    for (int i = 0; i < 6; i++) {
      _codeControllers[i].addListener(() => _onCodeChanged(i));
    }
  }

  @override
  void dispose() {
    Logger.ui('JoinCompanyScreen', 'DISPOSE');
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(int index) {
    final controller = _codeControllers[index];
    if (controller.text.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (mounted) setState(() {});
  }

  String get _code {
    return _codeControllers.map((c) => c.text.toUpperCase()).join();
  }

  bool get _isCodeComplete {
    return _codeControllers.every((c) => c.text.isNotEmpty);
  }

  Future<void> _handleJoin() async {
    Logger.ui('JoinCompanyScreen', 'HANDLE_JOIN_START');

    if (!_isCodeComplete) {
      setState(
        () => _errorMessage = 'Veuillez entrer les 6 caractères du code',
      );
      return;
    }

    final code = _code;
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) {
      setState(
        () => _errorMessage =
            'Le code doit contenir 6 caractères alphanumériques',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final syncQueue = ref.read(syncQueueHelperProvider);
      final inviteRepo = CompanyInviteRepository(db, syncQueue);
      final companyUserRepo = CompanyUserRepository(db, syncQueue);

      final invite = await inviteRepo.validateCode(code);
      if (invite == null) {
        Logger.ui('JoinCompanyScreen', 'INVALID_CODE');
        setState(() => _errorMessage = 'Code invalide, expiré ou déjà utilisé');
        return;
      }

      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        Logger.error('USER_ID_IS_NULL', tag: 'JOIN_COMPANY');
        throw Exception('Utilisateur non connecté');
      }

      final inviteCompanyId = invite.companyId;
      final existingUsers =
          await (db.select(db.companyUsers)..where(
                (cu) =>
                    cu.companyId.equals(inviteCompanyId) &
                    cu.userId.equals(userId),
              ))
              .get();
      if (existingUsers.isNotEmpty) {
        Logger.ui('JoinCompanyScreen', 'ALREADY_MEMBER');
        setState(
          () => _errorMessage = 'Vous êtes déjà membre de cette entreprise',
        );
        setState(() => _isLoading = false);
        return;
      }

      final now = DateTime.now();
      final companyUser = CompanyUser(
        id: const Uuid().v4(),
        companyId: invite.companyId,
        userId: userId,
        role: invite.role,
        createdAt: now,
      );

      await companyUserRepo.insert(companyUser);
      await inviteRepo.useCode(code);

      Logger.ui('JoinCompanyScreen', 'JOIN_SUCCESS');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vous avez rejoint l\'entreprise avec succès'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
        context.go('/');
      }
    } catch (e, st) {
      Logger.error(
        'JOIN_COMPANY_ERROR',
        tag: 'JOIN_COMPANY',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() => _errorMessage = 'Erreur: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre une entreprise'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Entrez le code d\'invitation reçu de votre entreprise',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 1,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]'),
                          ),
                          UpperCaseTextFormatter(),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _codeControllers[index].text = value.toUpperCase();
                            _codeControllers[index].selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: 1),
                                );
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              const Text(
                '(6 caractères)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading || !_isCodeComplete ? null : _handleJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rejoindre l\'entreprise',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vous n\'avez pas de code? Demandez à votre entreprise',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre entreprise peut vous inviter depuis les paramètres Membre de l\'équipe.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
