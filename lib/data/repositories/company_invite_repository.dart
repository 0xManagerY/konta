import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class CompanyInviteRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  CompanyInviteRepository(this._db, this._syncQueue);

  Future<List<CompanyInvite>> getByCompany(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getByCompany - fetching invites',
      data: {'companyId': companyId},
    );
    try {
      final result =
          await (_db.select(_db.companyInvites)
                ..where((ci) => ci.companyId.equals(companyId))
                ..orderBy([(ci) => OrderingTerm.desc(ci.createdAt)]))
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

  Future<CompanyInvite?> getByCode(String code) async {
    _log.debug(
      LogTags.repo,
      'getByCode - fetching invite',
      data: {'code': code},
    );
    try {
      final result = await (_db.select(
        _db.companyInvites,
      )..where((ci) => ci.code.equals(code))).getSingleOrNull();
      _log.info(
        LogTags.repo,
        'getByCode - completed',
        data: {'found': result != null},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByCode - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<CompanyInvite?> validateCode(String code) async {
    _log.debug(LogTags.repo, 'validateCode - validating', data: {'code': code});
    try {
      final invite = await getByCode(code);
      if (invite == null) {
        _log.info(LogTags.repo, 'validateCode - not found');
        return null;
      }
      if (!invite.isActive) {
        _log.info(LogTags.repo, 'validateCode - inactive');
        return null;
      }
      if (invite.expiresAt != null &&
          invite.expiresAt!.isBefore(DateTime.now())) {
        _log.info(LogTags.repo, 'validateCode - expired');
        return null;
      }
      if (invite.maxUses != null && invite.usesCount >= invite.maxUses!) {
        _log.info(LogTags.repo, 'validateCode - max uses reached');
        return null;
      }
      _log.info(LogTags.repo, 'validateCode - valid');
      return invite;
    } catch (e, st) {
      _log.error(LogTags.repo, 'validateCode - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<CompanyInvite> create({
    required String companyId,
    required String createdBy,
    required UserRole role,
    int? maxUses,
    DateTime? expiresAt,
  }) async {
    _log.debug(
      LogTags.repo,
      'create - starting',
      data: {
        'companyId': companyId,
        'createdBy': createdBy,
        'role': role.name,
        'maxUses': maxUses,
        'expiresAt': expiresAt?.toIso8601String(),
      },
    );
    try {
      final id = const Uuid().v4();
      final code = const Uuid().v4().substring(0, 6).toUpperCase();
      final now = DateTime.now();

      final invite = CompanyInvite(
        id: id,
        companyId: companyId,
        code: code,
        createdBy: createdBy,
        role: role,
        maxUses: maxUses,
        usesCount: 0,
        expiresAt: expiresAt,
        createdAt: now,
        isActive: true,
      );

      await _db.into(_db.companyInvites).insert(invite);
      await _syncQueue.queueInsert('company_invites', id);
      _log.info(
        LogTags.repo,
        'create - completed',
        data: {'id': id, 'code': code},
      );
      return invite;
    } catch (e, st) {
      _log.error(LogTags.repo, 'create - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> useCode(String code) async {
    _log.debug(LogTags.repo, 'useCode - starting', data: {'code': code});
    try {
      final invite = await getByCode(code);
      if (invite != null) {
        await (_db.update(
          _db.companyInvites,
        )..where((ci) => ci.code.equals(code))).write(
          CompanyInvitesCompanion(usesCount: Value(invite.usesCount + 1)),
        );
        await _syncQueue.queueUpdate('company_invites', invite.id);
      }
      _log.info(LogTags.repo, 'useCode - completed');
    } catch (e, st) {
      _log.error(LogTags.repo, 'useCode - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> deactivate(String id) async {
    _log.debug(LogTags.repo, 'deactivate - starting', data: {'id': id});
    try {
      await (_db.update(_db.companyInvites)..where((ci) => ci.id.equals(id)))
          .write(const CompanyInvitesCompanion(isActive: Value(false)));
      await _syncQueue.queueUpdate('company_invites', id);
      _log.info(LogTags.repo, 'deactivate - completed', data: {'id': id});
    } catch (e, st) {
      _log.error(LogTags.repo, 'deactivate - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('company_invites', id);
      await (_db.delete(
        _db.companyInvites,
      )..where((ci) => ci.id.equals(id))).go();
      _log.info(LogTags.repo, 'delete - completed', data: {'id': id});
    } catch (e, st) {
      _log.error(LogTags.repo, 'delete - failed', error: e, stack: st);
      rethrow;
    }
  }
}
