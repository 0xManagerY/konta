import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
