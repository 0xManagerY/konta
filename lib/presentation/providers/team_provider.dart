import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/repositories/company_invite_repository.dart';
import 'package:konta/data/repositories/role_permission_repository.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/sync_provider.dart';
import 'package:konta/domain/services/log_service.dart';

final syncQueueHelperProvider = Provider<SyncQueueHelper>((ref) {
  final log = LogService();
  log.debug(LogTags.provider, 'syncQueueHelperProvider - initializing');
  final syncService = ref.watch(syncServiceProvider);
  final helper = SyncQueueHelper(syncService);
  log.info(LogTags.provider, 'syncQueueHelperProvider - initialized');
  return helper;
});
final companyInviteRepositoryProvider = Provider<CompanyInviteRepository>((
  ref,
) {
  final log = LogService();
  log.debug(LogTags.provider, 'companyInviteRepositoryProvider - initializing');
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  final repo = CompanyInviteRepository(db, syncQueue);
  log.info(LogTags.provider, 'companyInviteRepositoryProvider - initialized');
  return repo;
});
final rolePermissionRepositoryProvider = Provider<RolePermissionRepository>((
  ref,
) {
  final log = LogService();
  log.debug(
    LogTags.provider,
    'rolePermissionRepositoryProvider - initializing',
  );
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  final repo = RolePermissionRepository(db, syncQueue);
  log.info(LogTags.provider, 'rolePermissionRepositoryProvider - initialized');
  return repo;
});
