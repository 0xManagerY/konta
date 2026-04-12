import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class CustomerRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  CustomerRepository(this._db, this._syncQueue);

  Future<List<Customer>> getAll(String userId) async {
    Logger.method('CustomerRepository', 'getAll', {'userId': userId});
    return (_db.select(_db.customers)
          ..where((c) => c.userId.equals(userId))
          ..orderBy([
            (c) =>
                OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<Customer?> getById(String id) async {
    Logger.method('CustomerRepository', 'getById', {'id': id});
    return (_db.select(
      _db.customers,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> insert(Customer customer) async {
    Logger.method('CustomerRepository', 'insert', {
      'id': customer.id,
      'name': customer.name,
    });
    Logger.db('INSERT', 'customers', {
      'id': customer.id,
      'name': customer.name,
    });
    await _db.into(_db.customers).insert(customer);
    await _syncQueue.queueInsert('customers', customer.id);
    Logger.success('Customer inserted', tag: 'REPO');
  }

  Future<void> update(Customer customer) async {
    Logger.method('CustomerRepository', 'update', {'id': customer.id});
    Logger.db('UPDATE', 'customers', {
      'id': customer.id,
      'name': customer.name,
    });
    await (_db.update(
      _db.customers,
    )..where((c) => c.id.equals(customer.id))).write(
      CustomersCompanion(
        name: Value(customer.name),
        ice: Value(customer.ice),
        rc: Value(customer.rc),
        ifNumber: Value(customer.ifNumber),
        patente: Value(customer.patente),
        cnss: Value(customer.cnss),
        legalForm: Value(customer.legalForm),
        capital: Value(customer.capital),
        status: Value(customer.status),
        address: Value(customer.address),
        phones: Value(customer.phones),
        fax: Value(customer.fax),
        emails: Value(customer.emails),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
    await _syncQueue.queueUpdate('customers', customer.id);
    Logger.success('Customer updated', tag: 'REPO');
  }

  Future<void> delete(String id) async {
    Logger.method('CustomerRepository', 'delete', {'id': id});
    Logger.db('DELETE', 'customers', {'id': id});
    await _syncQueue.queueDelete('customers', id);
    await (_db.delete(_db.customers)..where((c) => c.id.equals(id))).go();
    Logger.success('Customer deleted', tag: 'REPO');
  }

  Future<List<Customer>> search(String userId, String query) async {
    Logger.method('CustomerRepository', 'search', {
      'userId': userId,
      'query': query,
    });
    final searchPattern = '%$query%';
    return (_db.select(_db.customers)
          ..where(
            (c) =>
                c.userId.equals(userId) &
                (c.name.like(searchPattern) |
                    c.ice.like(searchPattern) |
                    c.phones.like(searchPattern)),
          )
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .get();
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    Logger.debug('Generated ID: $id', tag: 'REPO');
    return id;
  }
}
