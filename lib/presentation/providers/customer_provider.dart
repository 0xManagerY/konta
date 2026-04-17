import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/customer_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/core/utils/logger.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  Logger.method('Provider', 'customerRepositoryProvider', {'init': true});
  final db = ref.watch(databaseProvider);
  final syncQueue = ref.watch(syncQueueHelperProvider);
  return CustomerRepository(db, syncQueue);
});

final customersProvider = StreamProvider<List<Contact>>((ref) {
  Logger.method('Provider', 'customersProvider', {'watch': true});
  final db = ref.watch(databaseProvider);
  final userId = SupabaseService.currentUserId;
  if (userId == null) {
    Logger.warning(
      'No user ID, returning empty customers stream',
      tag: 'CUSTOMER_PROVIDER',
    );
    return Stream.value([]);
  }

  Logger.debug(
    'Watching customers for user: $userId',
    tag: 'CUSTOMER_PROVIDER',
  );
  return (db.select(db.contacts)
        ..where((c) => c.companyId.equals(userId))
        ..orderBy([
          (c) => OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
});
