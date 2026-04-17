import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/data/repositories/role_permission_repository.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final rolePermissionRepositoryProvider = Provider<RolePermissionRepository>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return RolePermissionRepository(db, syncQueue);
});

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  List<RolePermission> _managerPerms = [];
  List<RolePermission> _accountantPerms = [];
  List<RolePermission> _viewerPerms = [];
  String? _companyId;
  bool _isLoading = true;
  String? _error;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccessAndLoad();
    });
  }

  Future<void> _checkAccessAndLoad() async {
    Logger.ui('PermissionsScreen', 'CHECK_ACCESS_START');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final repo = ref.read(rolePermissionRepositoryProvider);

      final userCompanyIds = await db.select(db.companyUsers).get();
      if (userCompanyIds.isEmpty) {
        setState(() {
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }

      final companyIds = userCompanyIds.map((cu) => cu.companyId).toList();
      final companies = await (db.select(
        db.companies,
      )..where((c) => c.id.isIn(companyIds))).get();

      if (companies.isEmpty) {
        setState(() {
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }

      final company = companies.first;
      final members = await (db.select(
        db.companyUsers,
      )..where((cu) => cu.companyId.equals(company.id))).get();

      if (members.isEmpty) {
        setState(() {
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }

      final permissions = await repo.getByCompany(company.id);

      setState(() {
        _companyId = company.id;
        _managerPerms = permissions
            .where((p) => p.roleType == UserRole.manager)
            .toList();
        _accountantPerms = permissions
            .where((p) => p.roleType == UserRole.accountant)
            .toList();
        _viewerPerms = permissions
            .where((p) => p.roleType == UserRole.viewer)
            .toList();
        _hasAccess = true;
        _isLoading = false;
      });

      Logger.ui(
        'PermissionsScreen',
        'LOAD_COMPLETE permissions=${permissions.length}',
      );
    } catch (e, st) {
      Logger.error(
        'LOAD_FAILED',
        tag: 'PermissionsScreen',
        error: e,
        stackTrace: st,
      );
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPermissions() async {
    if (_companyId == null) return;

    Logger.ui('PermissionsScreen', 'LOAD_PERMISSIONS_START');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(rolePermissionRepositoryProvider);
      final permissions = await repo.getByCompany(_companyId!);

      setState(() {
        _managerPerms = permissions
            .where((p) => p.roleType == UserRole.manager)
            .toList();
        _accountantPerms = permissions
            .where((p) => p.roleType == UserRole.accountant)
            .toList();
        _viewerPerms = permissions
            .where((p) => p.roleType == UserRole.viewer)
            .toList();
        _isLoading = false;
      });

      Logger.ui('PermissionsScreen', 'LOAD_PERMISSIONS_COMPLETE');
    } catch (e, st) {
      Logger.error(
        'LOAD_PERMISSIONS_FAILED',
        tag: 'PermissionsScreen',
        error: e,
        stackTrace: st,
      );
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePermission(
    String permissionKey,
    bool value,
    UserRole role,
  ) async {
    if (_companyId == null) return;

    Logger.ui(
      'PermissionsScreen',
      'TOGGLE_PERMISSION_START',
      'permissionKey: $permissionKey, value: $value, role: ${role.name}',
    );

    try {
      final repo = ref.read(rolePermissionRepositoryProvider);
      await repo.updatePermission(_companyId!, role, permissionKey, value);

      setState(() {
        switch (role) {
          case UserRole.manager:
            _managerPerms = _managerPerms.map((p) {
              if (p.permissionKey == permissionKey) {
                return RolePermission(
                  id: p.id,
                  companyId: p.companyId,
                  roleType: p.roleType,
                  permissionKey: p.permissionKey,
                  isEnabled: value,
                  createdAt: p.createdAt,
                );
              }
              return p;
            }).toList();
            break;
          case UserRole.accountant:
            _accountantPerms = _accountantPerms.map((p) {
              if (p.permissionKey == permissionKey) {
                return RolePermission(
                  id: p.id,
                  companyId: p.companyId,
                  roleType: p.roleType,
                  permissionKey: p.permissionKey,
                  isEnabled: value,
                  createdAt: p.createdAt,
                );
              }
              return p;
            }).toList();
            break;
          case UserRole.viewer:
            _viewerPerms = _viewerPerms.map((p) {
              if (p.permissionKey == permissionKey) {
                return RolePermission(
                  id: p.id,
                  companyId: p.companyId,
                  roleType: p.roleType,
                  permissionKey: p.permissionKey,
                  isEnabled: value,
                  createdAt: p.createdAt,
                );
              }
              return p;
            }).toList();
            break;
          default:
            break;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission mise à jour'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Logger.error(
        'TOGGLE_PERMISSION_FAILED',
        tag: 'PermissionsScreen',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  bool _getPermissionValue(List<RolePermission> perms, String key) {
    final perm = perms.cast<RolePermission?>().firstWhere(
      (p) => p?.permissionKey == key,
      orElse: () => null,
    );
    return perm?.isEnabled ?? false;
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

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Icons.star;
      case UserRole.manager:
        return Icons.person;
      case UserRole.accountant:
        return Icons.calculate;
      case UserRole.viewer:
        return Icons.visibility;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions des rôles'),
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

    if (!_hasAccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Accès restreint',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Vous devez avoir des membres dans votre équipe et les permissions nécessaires pour accéder à cette page.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Retour'),
            ),
          ],
        ),
      );
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
              onPressed: _loadPermissions,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPermissions,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildRoleCard(
            role: UserRole.manager,
            permissions: _managerPerms,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: UserRole.accountant,
            permissions: _accountantPerms,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: UserRole.viewer,
            permissions: _viewerPerms,
            color: Colors.grey,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.2),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF2563EB)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Configurez les permissions pour chaque rôle. Les modifications sont appliquées immédiatement.',
              style: TextStyle(color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required List<RolePermission> permissions,
    required Color color,
  }) {
    final roleLabel = _getRoleLabel(role);
    final roleIcon = _getRoleIcon(role);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(roleIcon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  roleLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPermissionSection(
                  title: 'Documents',
                  color: color,
                  permissions: [
                    _PermissionItem(
                      'Créer des factures',
                      RolePermissionRepository.createInvoice,
                    ),
                    _PermissionItem(
                      'Modifier des factures',
                      RolePermissionRepository.editInvoice,
                    ),
                    _PermissionItem(
                      'Supprimer des factures',
                      RolePermissionRepository.deleteInvoice,
                    ),
                    _PermissionItem(
                      'Créer des devis',
                      RolePermissionRepository.createQuote,
                    ),
                    _PermissionItem(
                      'Modifier des devis',
                      RolePermissionRepository.editQuote,
                    ),
                    _PermissionItem(
                      'Supprimer des devis',
                      RolePermissionRepository.deleteQuote,
                    ),
                    _PermissionItem(
                      'Créer des avoirs',
                      RolePermissionRepository.createCreditNote,
                    ),
                  ],
                  role: role,
                  permissionsList: permissions,
                ),
                const SizedBox(height: 16),
                _buildPermissionSection(
                  title: 'Contacts & Articles',
                  color: color,
                  permissions: [
                    _PermissionItem(
                      'Gérer les contacts',
                      RolePermissionRepository.manageContacts,
                    ),
                    _PermissionItem(
                      'Gérer les articles',
                      RolePermissionRepository.manageItems,
                    ),
                  ],
                  role: role,
                  permissionsList: permissions,
                ),
                const SizedBox(height: 16),
                _buildPermissionSection(
                  title: 'Dépenses & Paiements',
                  color: color,
                  permissions: [
                    _PermissionItem(
                      'Gérer les dépenses',
                      RolePermissionRepository.manageExpenses,
                    ),
                    _PermissionItem(
                      'Gérer les paiements',
                      RolePermissionRepository.managePayments,
                    ),
                  ],
                  role: role,
                  permissionsList: permissions,
                ),
                const SizedBox(height: 16),
                _buildPermissionSection(
                  title: 'Données',
                  color: color,
                  permissions: [
                    _PermissionItem(
                      'Exporter les données',
                      RolePermissionRepository.exportData,
                    ),
                    _PermissionItem(
                      'Voir le journal d\'audit',
                      RolePermissionRepository.viewAuditLog,
                    ),
                    _PermissionItem(
                      'Gérer les taxes',
                      RolePermissionRepository.manageTaxes,
                    ),
                    _PermissionItem(
                      'Gérer l\'entreprise',
                      RolePermissionRepository.manageCompany,
                    ),
                    _PermissionItem(
                      'Gérer les rôles',
                      RolePermissionRepository.manageRoles,
                    ),
                  ],
                  role: role,
                  permissionsList: permissions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSection({
    required String title,
    required Color color,
    required List<_PermissionItem> permissions,
    required UserRole role,
    required List<RolePermission> permissionsList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...permissions.map(
          (perm) => _buildToggleRow(
            perm.label,
            perm.key,
            role,
            permissionsList,
            color,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String label,
    String permissionKey,
    UserRole role,
    List<RolePermission> permissions,
    Color accentColor,
  ) {
    final isEnabled = _getPermissionValue(permissions, permissionKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => _togglePermission(permissionKey, value, role),
            activeThumbColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _PermissionItem {
  final String label;
  final String key;

  _PermissionItem(this.label, this.key);
}
