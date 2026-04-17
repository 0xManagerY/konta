import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class CompanyUserRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  CompanyUserRepository(this._db, this._syncQueue);

  Future<List<CompanyUser>> getByCompany(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getByCompany - fetching company users',
      data: {'companyId': companyId},
    );
    try {
      final result =
          await (_db.select(_db.companyUsers)
                ..where((cu) => cu.companyId.equals(companyId))
                ..orderBy([(cu) => OrderingTerm.asc(cu.createdAt)]))
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

  Future<List<CompanyUser>> getByUser(String userId) async {
    _log.debug(
      LogTags.repo,
      'getByUser - fetching user memberships',
      data: {'userId': userId},
    );
    try {
      final result = await (_db.select(
        _db.companyUsers,
      )..where((cu) => cu.userId.equals(userId))).get();
      _log.info(
        LogTags.repo,
        'getByUser - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByUser - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<CompanyUser?> getUserRole(String companyId, String userId) async {
    _log.debug(
      LogTags.repo,
      'getUserRole - fetching role',
      data: {'companyId': companyId, 'userId': userId},
    );
    try {
      final result = await _db.getUserRole(companyId, userId);
      _log.info(
        LogTags.repo,
        'getUserRole - completed',
        data: {'found': result != null},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getUserRole - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<bool> userHasRole(
    String companyId,
    String userId,
    List<UserRole> roles,
  ) async {
    return _db.userHasRole(companyId, userId, roles);
  }

  Future<bool> isOwner(String companyId, String userId) =>
      userHasRole(companyId, userId, [UserRole.owner]);

  Future<bool> isManager(String companyId, String userId) =>
      userHasRole(companyId, userId, [UserRole.owner, UserRole.manager]);

  Future<bool> isAccountant(String companyId, String userId) => userHasRole(
    companyId,
    userId,
    [UserRole.owner, UserRole.manager, UserRole.accountant],
  );

  Future<bool> canEdit(String companyId, String userId) =>
      isManager(companyId, userId);

  Future<bool> canDelete(String companyId, String userId) =>
      isOwner(companyId, userId);

  Future<bool> canExport(String companyId, String userId) =>
      isAccountant(companyId, userId);

  Future<void> insert(CompanyUser companyUser) async {
    _log.debug(
      LogTags.repo,
      'insert - starting',
      data: {
        'id': companyUser.id,
        'companyId': companyUser.companyId,
        'userId': companyUser.userId,
        'role': companyUser.role.name,
      },
    );
    try {
      await _db.into(_db.companyUsers).insert(companyUser);
      await _syncQueue.queueInsert('company_users', companyUser.id);
      _log.info(
        LogTags.repo,
        'insert - completed',
        data: {'id': companyUser.id},
      );
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'insert - failed',
        error: e,
        stack: st,
        data: {'id': companyUser.id},
      );
      rethrow;
    }
  }

  Future<void> updateRole(String id, UserRole newRole) async {
    _log.debug(
      LogTags.repo,
      'updateRole - starting',
      data: {'id': id, 'newRole': newRole.name},
    );
    try {
      final currentUser = await (_db.select(
        _db.companyUsers,
      )..where((cu) => cu.id.equals(id))).getSingleOrNull();
      if (currentUser != null &&
          currentUser.role == UserRole.owner &&
          newRole != UserRole.owner) {
        final owners =
            await (_db.select(_db.companyUsers)..where(
                  (cu) =>
                      cu.companyId.equals(currentUser.companyId) &
                      cu.role.equalsValue(UserRole.owner),
                ))
                .get();
        if (owners.length <= 1) {
          throw Exception('Impossible de rétrograder le dernier propriétaire');
        }
      }
      await (_db.update(_db.companyUsers)..where((cu) => cu.id.equals(id)))
          .write(CompanyUsersCompanion(role: Value(newRole)));
      await _syncQueue.queueUpdate('company_users', id);
      _log.info(LogTags.repo, 'updateRole - completed', data: {'id': id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'updateRole - failed',
        error: e,
        stack: st,
        data: {'id': id},
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('company_users', id);
      await (_db.delete(
        _db.companyUsers,
      )..where((cu) => cu.id.equals(id))).go();
      _log.info(LogTags.repo, 'delete - completed', data: {'id': id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'delete - failed',
        error: e,
        stack: st,
        data: {'id': id},
      );
      rethrow;
    }
  }

  Future<void> removeUserFromCompany(String companyId, String userId) async {
    _log.debug(
      LogTags.repo,
      'removeUserFromCompany - starting',
      data: {'companyId': companyId, 'userId': userId},
    );
    try {
      final companyUser = await getUserRole(companyId, userId);
      if (companyUser != null) {
        if (companyUser.role == UserRole.owner) {
          final owners =
              await (_db.select(_db.companyUsers)..where(
                    (cu) =>
                        cu.companyId.equals(companyId) &
                        cu.role.equalsValue(UserRole.owner),
                  ))
                  .get();
          if (owners.length <= 1) {
            throw Exception('Impossible de supprimer le dernier propriétaire');
          }
        }
        await delete(companyUser.id);
      }
      _log.info(LogTags.repo, 'removeUserFromCompany - completed');
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'removeUserFromCompany - failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    _log.debug(LogTags.repo, 'generateId - generated', data: {'id': id});
    return id;
  }

  Future<CompanyUser> inviteUser({
    required String companyId,
    required String userId,
    required UserRole role,
  }) async {
    _log.debug(
      LogTags.repo,
      'inviteUser - starting',
      data: {'companyId': companyId, 'userId': userId, 'role': role.name},
    );
    try {
      final id = await generateId();
      final now = DateTime.now();

      final companyUser = CompanyUser(
        id: id,
        companyId: companyId,
        userId: userId,
        role: role,
        createdAt: now,
      );

      await insert(companyUser);
      _log.info(LogTags.repo, 'inviteUser - completed', data: {'id': id});
      return companyUser;
    } catch (e, st) {
      _log.error(LogTags.repo, 'inviteUser - failed', error: e, stack: st);
      rethrow;
    }
  }
}
