import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class ContactRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  ContactRepository(this._db, this._syncQueue);

  Future<List<Contact>> getAll(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getAll - fetching contacts',
      data: {'companyId': companyId},
    );
    try {
      final result = await _db.getContactsByCompany(companyId);
      _log.info(
        LogTags.repo,
        'getAll - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getAll - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<Contact>> getByType(String companyId, ContactType type) async {
    _log.debug(
      LogTags.repo,
      'getByType - fetching contacts',
      data: {'companyId': companyId, 'type': type.name},
    );
    try {
      final result = await _db.getContactsByType(companyId, type);
      _log.info(
        LogTags.repo,
        'getByType - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByType - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<Contact>> getCustomers(String companyId) =>
      getByType(companyId, ContactType.customer);

  Future<List<Contact>> getSuppliers(String companyId) =>
      getByType(companyId, ContactType.supplier);

  Future<List<Contact>> getBoth(String companyId) =>
      getByType(companyId, ContactType.both);

  Future<Contact?> getById(String id) async {
    _log.debug(LogTags.repo, 'getById - fetching contact', data: {'id': id});
    try {
      final result = await _db.getContactById(id);
      _log.info(
        LogTags.repo,
        'getById - completed',
        data: {'found': result != null},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getById - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> insert(Contact contact) async {
    _log.debug(
      LogTags.repo,
      'insert - starting',
      data: {'id': contact.id, 'name': contact.name},
    );
    try {
      await _db.into(_db.contacts).insert(contact);
      await _syncQueue.queueInsert('contacts', contact.id);
      _log.info(LogTags.repo, 'insert - completed', data: {'id': contact.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'insert - failed',
        error: e,
        stack: st,
        data: {'id': contact.id},
      );
      rethrow;
    }
  }

  Future<void> update(Contact contact) async {
    _log.debug(LogTags.repo, 'update - starting', data: {'id': contact.id});
    try {
      await (_db.update(
        _db.contacts,
      )..where((c) => c.id.equals(contact.id))).write(
        ContactsCompanion(
          name: Value(contact.name),
          contactType: Value(contact.contactType),
          ice: Value(contact.ice),
          rc: Value(contact.rc),
          ifNumber: Value(contact.ifNumber),
          patente: Value(contact.patente),
          cnss: Value(contact.cnss),
          legalForm: Value(contact.legalForm),
          capital: Value(contact.capital),
          address: Value(contact.address),
          phones: Value(contact.phones),
          fax: Value(contact.fax),
          emails: Value(contact.emails),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      await _syncQueue.queueUpdate('contacts', contact.id);
      _log.info(LogTags.repo, 'update - completed', data: {'id': contact.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'update - failed',
        error: e,
        stack: st,
        data: {'id': contact.id},
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('contacts', id);
      await (_db.delete(_db.contacts)..where((c) => c.id.equals(id))).go();
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

  Future<List<Contact>> search(String companyId, String query) async {
    _log.debug(
      LogTags.repo,
      'search - starting',
      data: {'companyId': companyId, 'query': query},
    );
    try {
      final searchPattern = '%$query%';
      final result =
          (_db.select(_db.contacts)
                ..where(
                  (c) =>
                      c.companyId.equals(companyId) &
                      (c.name.like(searchPattern) |
                          c.ice.like(searchPattern) |
                          c.phones.like(searchPattern)),
                )
                ..orderBy([(c) => OrderingTerm.asc(c.name)]))
              .get();
      _log.info(LogTags.repo, 'search - completed', data: {'query': query});
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'search - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    _log.debug(LogTags.repo, 'generateId - generated', data: {'id': id});
    return id;
  }

  Future<Contact> create({
    required String companyId,
    required String name,
    ContactType contactType = ContactType.customer,
    String? ice,
    String? rc,
    String? ifNumber,
    String? patente,
    String? cnss,
    String? legalForm,
    String? capital,
    String? address,
    String? phones,
    String? fax,
    String? emails,
  }) async {
    _log.debug(
      LogTags.repo,
      'create - starting',
      data: {'companyId': companyId, 'name': name},
    );
    try {
      final id = await generateId();
      final now = DateTime.now();

      final contact = Contact(
        id: id,
        companyId: companyId,
        name: name,
        contactType: contactType.name,
        ice: ice,
        rc: rc,
        ifNumber: ifNumber,
        patente: patente,
        cnss: cnss,
        legalForm: legalForm,
        capital: capital,
        address: address,
        phones: phones,
        fax: fax,
        emails: emails,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      await insert(contact);
      _log.info(
        LogTags.repo,
        'create - completed',
        data: {'id': id, 'name': name},
      );
      return contact;
    } catch (e, st) {
      _log.error(LogTags.repo, 'create - failed', error: e, stack: st);
      rethrow;
    }
  }
}
