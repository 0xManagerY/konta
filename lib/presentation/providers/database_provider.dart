import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  Logger.method('Provider', 'databaseProvider', {'init': true});
  final db = getDatabase();
  Logger.success('Database instance created', tag: 'DATABASE_PROVIDER');
  return db;
});
