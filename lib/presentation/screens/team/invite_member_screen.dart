import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/repositories/company_invite_repository.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final _companyInviteRepoProvider = Provider<CompanyInviteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncQueueHelper = ref.watch(syncQueueHelperProvider);
  return CompanyInviteRepository(db, syncQueueHelper);
});

class InviteMemberScreen extends ConsumerStatefulWidget {
  const InviteMemberScreen({super.key});

  @override
  ConsumerState<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends ConsumerState<InviteMemberScreen> {
  UserRole _selectedRole = UserRole.manager;
  String? _generatedCode;
  CompanyInvite? _invite;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _createInvite();
  }

  Future<void> _createInvite() async {
    Logger.ui('InviteMemberScreen', 'CREATE_INVITE_START');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final db = ref.read(databaseProvider);

      final userCompanyIds = await (db.select(
        db.companyUsers,
      )..where((cu) => cu.userId.equals(userId))).get();
      final ids = userCompanyIds.map((cu) => cu.companyId).toList();
      if (ids.isEmpty) {
        throw Exception('Aucune entreprise trouvée');
      }

      final companies = await (db.select(
        db.companies,
      )..where((c) => c.id.isIn(ids))).get();
      if (companies.isEmpty) {
        throw Exception('Aucune entreprise trouvée');
      }

      final company = companies.first;
      final inviteRepo = ref.read(_companyInviteRepoProvider);

      final expiresAt = DateTime.now().add(const Duration(days: 7));
      final invite = await inviteRepo.create(
        companyId: company.id,
        createdBy: userId,
        role: _selectedRole,
        expiresAt: expiresAt,
      );

      setState(() {
        _invite = invite;
        _generatedCode = invite.code;
        _isLoading = false;
      });
      Logger.ui(
        'InviteMemberScreen',
        'CREATE_INVITE_COMPLETE code=$_generatedCode',
      );
    } catch (e, st) {
      Logger.error(
        'CREATE_INVITE_FAILED',
        tag: 'InviteMemberScreen',
        error: e,
        stackTrace: st,
      );
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _getRoleExplanation(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Accès complet à l\'entreprise';
      case UserRole.manager:
        return 'Peut créer et modifier documents, contacts, produits';
      case UserRole.accountant:
        return 'Accès en lecture + export de données';
      case UserRole.viewer:
        return 'Accès en lecture seule';
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Propriétaire';
      case UserRole.manager:
        return 'Gestionnaire';
      case UserRole.accountant:
        return 'Comptable';
      case UserRole.viewer:
        return 'Consultation';
    }
  }

  Future<void> _copyCode() async {
    if (_generatedCode == null) return;
    await Clipboard.setData(ClipboardData(text: _generatedCode!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copié dans le presse-papiers'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _shareCode() async {
    if (_generatedCode == null) return;
    final message =
        'Rejoignez mon entreprise sur Konta!\n\nCode d\'invitation: $_generatedCode\n\nCe code expire dans 7 jours.';
    await Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inviter un membre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Erreur', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createInvite,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final expiryDate = _invite?.expiresAt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sélectionner le rôle',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: [UserRole.manager, UserRole.accountant, UserRole.viewer].map(
              (role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(_getRoleLabel(role)),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedRole = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF6B7280)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getRoleExplanation(_selectedRole),
                    style: const TextStyle(color: Color(0xFF374151)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Code d\'invitation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _generatedCode ?? '------',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _copyCode,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copier'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _shareCode,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Partager'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (expiryDate != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ce code expire le ${dateFormat.format(expiryDate)}',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Terminé'),
            ),
          ),
        ],
      ),
    );
  }
}
