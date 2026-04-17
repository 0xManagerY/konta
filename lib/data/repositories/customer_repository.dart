import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class CustomerRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  CustomerRepository(this._db, this._syncQueue);

  Future<List<Contact>> getAll(String companyId) async {
    Logger.method('CustomerRepository', 'getAll', {'companyId': companyId});
    return (_db.select(_db.contacts)
          ..where((c) => c.companyId.equals(companyId))
          ..orderBy([
            (c) =>
                OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<Contact?> getById(String id) async {
    Logger.method('CustomerRepository', 'getById', {'id': id});
    return (_db.select(
      _db.contacts,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> insert(Contact customer) async {
    Logger.method('CustomerRepository', 'insert', {
      'id': customer.id,
      'name': customer.name,
    });
    Logger.db('INSERT', 'customers', {
      'id': customer.id,
      'name': customer.name,
    });
    await _db.into(_db.contacts).insert(customer);
    await _syncQueue.queueInsert('customers', customer.id);
    Logger.success('Customer inserted', tag: 'REPO');
  }

  Future<void> update(Contact customer) async {
    Logger.method('CustomerRepository', 'update', {'id': customer.id});
    Logger.db('UPDATE', 'customers', {
      'id': customer.id,
      'name': customer.name,
    });
    await (_db.update(
      _db.contacts,
    )..where((c) => c.id.equals(customer.id))).write(
      ContactsCompanion(
        name: Value(customer.name),
        ice: Value(customer.ice),
        rc: Value(customer.rc),
        ifNumber: Value(customer.ifNumber),
        patente: Value(customer.patente),
        cnss: Value(customer.cnss),
        legalForm: Value(customer.legalForm),
        capital: Value(customer.capital),
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
    await (_db.delete(_db.contacts)..where((c) => c.id.equals(id))).go();
    Logger.success('Customer deleted', tag: 'REPO');
  }

  Future<List<Contact>> search(String companyId, String query) async {
    Logger.method('CustomerRepository', 'search', {
      'companyId': companyId,
      'query': query,
    });
    final searchPattern = '%$query%';
    return (_db.select(_db.contacts)
          ..where(
            (c) =>
                c.companyId.equals(companyId) &
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
