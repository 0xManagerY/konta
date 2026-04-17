import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

class TeamMembersScreen extends ConsumerStatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  ConsumerState<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends ConsumerState<TeamMembersScreen> {
  List<CompanyUser> _members = [];
  Map<String, String> _userEmails = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    Logger.ui('TeamMembersScreen', 'LOAD_DATA_START');
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
      final members =
          await (db.select(db.companyUsers)
                ..where((cu) => cu.companyId.equals(company.id))
                ..orderBy([(cu) => OrderingTerm.asc(cu.createdAt)]))
              .get();

      final allProfiles = await db.select(db.userProfiles).get();
      final profilesById = {for (var p in allProfiles) p.id: p};

      final emails = <String, String>{};
      for (final member in members) {
        final profileData = profilesById[member.userId];
        emails[member.userId] = profileData?.email ?? 'Email inconnu';
      }

      setState(() {
        _members = members;
        _userEmails = emails;
        _isLoading = false;
      });
      Logger.ui(
        'TeamMembersScreen',
        'LOAD_DATA_COMPLETE members=${_members.length}',
      );
    } catch (e, st) {
      Logger.error(
        'LOAD_DATA_FAILED',
        tag: 'TeamMembersScreen',
        error: e,
        stackTrace: st,
      );
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const Color(0xFF2563EB);
      case UserRole.manager:
        return const Color(0xFF10B981);
      case UserRole.accountant:
        return const Color(0xFFF59E0B);
      case UserRole.viewer:
        return Colors.grey;
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

  Future<bool?> _showRemoveConfirmation(BuildContext context, String email) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le membre'),
        content: Text('Voulez-vous vraiment supprimer $email de l\'équipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMember(CompanyUser member) async {
    Logger.ui('TeamMembersScreen', 'REMOVE_MEMBER', 'userId=${member.userId}');
    try {
      final db = ref.read(databaseProvider);
      await db.removeUserFromCompany(member.companyId, member.userId);
      await _loadData();
      Logger.info('Membre supprimé', tag: 'TeamMembersScreen');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Membre supprimé')));
      }
    } catch (e, st) {
      Logger.error(
        'REMOVE_MEMBER_FAILED',
        tag: 'TeamMembersScreen',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Équipe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_members.length > 1)
            IconButton(
              icon: const Icon(Icons.security),
              tooltip: 'Permissions',
              onPressed: () => context.push('/team/permissions'),
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: !_isLoading && _error == null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/team/invite'),
              icon: const Icon(Icons.person_add),
              label: const Text('Inviter un membre'),
            )
          : null,
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
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun membre dans l\'équipe',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Invitez des collaborateurs pour travailler ensemble',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/team/invite'),
              icon: const Icon(Icons.person_add),
              label: const Text('Inviter un membre'),
            ),
          ],
        ),
      );
    }

    final currentUserId = SupabaseService.currentUserId;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _members.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final member = _members[index];
          final email = _userEmails[member.userId] ?? 'Email inconnu';
          final isCurrentUser = member.userId == currentUserId;
          final roleColor = _getRoleColor(member.role);
          final roleLabel = _getRoleLabel(member.role);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: roleColor.withValues(alpha: 0.2),
              child: Icon(Icons.person, color: roleColor),
            ),
            title: Row(
              children: [
                Flexible(child: Text(email, overflow: TextOverflow.ellipsis)),
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '(Vous)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              'Membre depuis le ${dateFormat.format(member.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: member.role == UserRole.owner
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      roleLabel,
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
                : PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) async {
                      if (value == 'remove') {
                        final confirm = await _showRemoveConfirmation(
                          context,
                          email,
                        );
                        if (confirm == true) {
                          await _removeMember(member);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
