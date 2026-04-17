import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class RolePermissionRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  RolePermissionRepository(this._db, this._syncQueue);

  static const viewAllData = 'view_all_data';
  static const createInvoice = 'create_invoice';
  static const editInvoice = 'edit_invoice';
  static const deleteInvoice = 'delete_invoice';
  static const createQuote = 'create_quote';
  static const editQuote = 'edit_quote';
  static const deleteQuote = 'delete_quote';
  static const createCreditNote = 'create_credit_note';
  static const manageContacts = 'manage_contacts';
  static const manageItems = 'manage_items';
  static const manageExpenses = 'manage_expenses';
  static const managePayments = 'manage_payments';
  static const manageTaxes = 'manage_taxes';
  static const manageCompany = 'manage_company';
  static const manageRoles = 'manage_roles';
  static const exportData = 'export_data';
  static const viewAuditLog = 'view_audit_log';

  static Map<String, bool> getDefaultPermissions(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return {for (var k in allPermissions) k: true};
      case UserRole.manager:
        return {
          viewAllData: true,
          createInvoice: true,
          editInvoice: true,
          deleteInvoice: false,
          createQuote: true,
          editQuote: true,
          deleteQuote: false,
          createCreditNote: true,
          manageContacts: true,
          manageItems: true,
          manageExpenses: true,
          managePayments: true,
          manageTaxes: false,
          manageCompany: false,
          manageRoles: false,
          exportData: true,
          viewAuditLog: false,
        };
      case UserRole.accountant:
        return {
          viewAllData: true,
          createInvoice: false,
          editInvoice: false,
          deleteInvoice: false,
          createQuote: false,
          editQuote: false,
          deleteQuote: false,
          createCreditNote: false,
          manageContacts: false,
          manageItems: false,
          manageExpenses: false,
          managePayments: false,
          manageTaxes: false,
          manageCompany: false,
          manageRoles: false,
          exportData: true,
          viewAuditLog: false,
        };
      case UserRole.viewer:
        return {
          viewAllData: true,
          createInvoice: false,
          editInvoice: false,
          deleteInvoice: false,
          createQuote: false,
          editQuote: false,
          deleteQuote: false,
          createCreditNote: false,
          manageContacts: false,
          manageItems: false,
          manageExpenses: false,
          managePayments: false,
          manageTaxes: false,
          manageCompany: false,
          manageRoles: false,
          exportData: false,
          viewAuditLog: false,
        };
    }
  }

  static List<String> get allPermissions => [
    viewAllData,
    createInvoice,
    editInvoice,
    deleteInvoice,
    createQuote,
    editQuote,
    deleteQuote,
    createCreditNote,
    manageContacts,
    manageItems,
    manageExpenses,
    managePayments,
    manageTaxes,
    manageCompany,
    manageRoles,
    exportData,
    viewAuditLog,
  ];

  Future<List<RolePermission>> getByCompany(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getByCompany - fetching role permissions',
      data: {'companyId': companyId},
    );
    try {
      final result =
          await (_db.select(_db.rolePermissions)
                ..where((rp) => rp.companyId.equals(companyId))
                ..orderBy([(rp) => OrderingTerm.asc(rp.createdAt)]))
              .get();
      _log.info(
        LogTags.repo,
        'getByCompany - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByCompany - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<RolePermission>> getByRole(
    String companyId,
    UserRole roleType,
  ) async {
    _log.debug(
      LogTags.repo,
      'getByRole - fetching role permissions',
      data: {'companyId': companyId, 'roleType': roleType.name},
    );
    try {
      final result =
          await (_db.select(_db.rolePermissions)
                ..where(
                  (rp) =>
                      rp.companyId.equals(companyId) &
                      rp.roleType.equals(roleType.name),
                )
                ..orderBy([(rp) => OrderingTerm.asc(rp.createdAt)]))
              .get();
      _log.info(
        LogTags.repo,
        'getByRole - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByRole - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<bool> hasPermission(
    String companyId,
    UserRole role,
    String permissionKey,
  ) async {
    _log.debug(
      LogTags.repo,
      'hasPermission - checking permission',
      data: {
        'companyId': companyId,
        'role': role.name,
        'permissionKey': permissionKey,
      },
    );
    try {
      final result =
          await (_db.select(_db.rolePermissions)..where(
                (rp) =>
                    rp.companyId.equals(companyId) &
                    rp.roleType.equals(role.name) &
                    rp.permissionKey.equals(permissionKey),
              ))
              .getSingleOrNull();
      final hasPermission = result?.isEnabled ?? false;
      _log.info(
        LogTags.repo,
        'hasPermission - completed',
        data: {'hasPermission': hasPermission},
      );
      return hasPermission;
    } catch (e, st) {
      _log.error(LogTags.repo, 'hasPermission - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> updatePermission(
    String companyId,
    UserRole role,
    String permissionKey,
    bool enabled,
  ) async {
    _log.debug(
      LogTags.repo,
      'updatePermission - starting',
      data: {
        'companyId': companyId,
        'role': role.name,
        'permissionKey': permissionKey,
        'enabled': enabled,
      },
    );
    try {
      final existing =
          await (_db.select(_db.rolePermissions)..where(
                (rp) =>
                    rp.companyId.equals(companyId) &
                    rp.roleType.equals(role.name) &
                    rp.permissionKey.equals(permissionKey),
              ))
              .getSingleOrNull();

      if (existing != null) {
        await (_db.update(_db.rolePermissions)
              ..where((rp) => rp.id.equals(existing.id)))
            .write(RolePermissionsCompanion(isEnabled: Value(enabled)));
        await _syncQueue.queueUpdate('role_permissions', existing.id);
        _log.info(
          LogTags.repo,
          'updatePermission - completed',
          data: {'id': existing.id},
        );
      } else {
        final id = const Uuid().v4();
        final now = DateTime.now();
        await _db
            .into(_db.rolePermissions)
            .insert(
              RolePermission(
                id: id,
                companyId: companyId,
                roleType: role,
                permissionKey: permissionKey,
                isEnabled: enabled,
                createdAt: now,
              ),
            );
        await _syncQueue.queueInsert('role_permissions', id);
        _log.info(
          LogTags.repo,
          'updatePermission - completed',
          data: {'id': id},
        );
      }
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'updatePermission - failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<void> initializeDefaults(String companyId) async {
    _log.debug(
      LogTags.repo,
      'initializeDefaults - starting',
      data: {'companyId': companyId},
    );
    try {
      final now = DateTime.now();
      for (final role in UserRole.values) {
        final permissions = getDefaultPermissions(role);
        for (final entry in permissions.entries) {
          final id = const Uuid().v4();
          await _db
              .into(_db.rolePermissions)
              .insert(
                RolePermission(
                  id: id,
                  companyId: companyId,
                  roleType: role,
                  permissionKey: entry.key,
                  isEnabled: entry.value,
                  createdAt: now,
                ),
              );
          await _syncQueue.queueInsert('role_permissions', id);
        }
      }
      _log.info(LogTags.repo, 'initializeDefaults - completed');
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'initializeDefaults - failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<void> resetToDefaults(String companyId) async {
    _log.debug(
      LogTags.repo,
      'resetToDefaults - starting',
      data: {'companyId': companyId},
    );
    try {
      await (_db.delete(
        _db.rolePermissions,
      )..where((rp) => rp.companyId.equals(companyId))).go();
      _log.info(LogTags.repo, 'resetToDefaults - deleted existing permissions');
      await initializeDefaults(companyId);
      _log.info(LogTags.repo, 'resetToDefaults - completed');
    } catch (e, st) {
      _log.error(LogTags.repo, 'resetToDefaults - failed', error: e, stack: st);
      rethrow;
    }
  }
}
