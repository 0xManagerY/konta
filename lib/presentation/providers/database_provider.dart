import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/domain/services/log_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final log = LogService();
  log.debug(LogTags.provider, 'databaseProvider - initializing');
  final db = getDatabase();
  log.info(LogTags.provider, 'databaseProvider - initialized');
  return db;
});
