import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';
import 'package:konta/data/repositories/tax_repository.dart';

class CompanyRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  CompanyRepository(this._db, this._syncQueue);

  Future<List<Company>> getAll() async {
    _log.debug(LogTags.repo, 'getAll - fetching companies');
    try {
      final result = _db.select(_db.companies).get();
      _log.info(LogTags.repo, 'getAll - completed');
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getAll - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<List<Company>> getByUserId(String userId) async {
    _log.debug(
      LogTags.repo,
      'getByUserId - fetching companies',
      data: {'userId': userId},
    );
    try {
      final result = await _db.getUserCompanies(userId);
      _log.info(
        LogTags.repo,
        'getByUserId - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getByUserId - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<Company?> getById(String id) async {
    _log.debug(LogTags.repo, 'getById - fetching company', data: {'id': id});
    try {
      final result = await _db.getCompanyById(id);
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

  Future<void> insert(Company company) async {
    _log.debug(LogTags.repo, 'insert - starting', data: {'id': company.id});
    try {
      await _db.into(_db.companies).insert(company);
      await _syncQueue.queueInsert('companies', company.id);
      _log.info(LogTags.repo, 'insert - completed', data: {'id': company.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'insert - failed',
        error: e,
        stack: st,
        data: {'id': company.id},
      );
      rethrow;
    }
  }

  Future<void> update(Company company) async {
    _log.debug(LogTags.repo, 'update - starting', data: {'id': company.id});
    try {
      await (_db.update(
        _db.companies,
      )..where((c) => c.id.equals(company.id))).write(
        CompaniesCompanion(
          name: Value(company.name),
          legalStatus: Value(company.legalStatus),
          ice: Value(company.ice),
          ifNumber: Value(company.ifNumber),
          rc: Value(company.rc),
          cnss: Value(company.cnss),
          address: Value(company.address),
          phone: Value(company.phone),
          logoUrl: Value(company.logoUrl),
          isAutoEntrepreneur: Value(company.isAutoEntrepreneur),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      await _syncQueue.queueUpdate('companies', company.id);
      _log.info(LogTags.repo, 'update - completed', data: {'id': company.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'update - failed',
        error: e,
        stack: st,
        data: {'id': company.id},
      );
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    try {
      await _syncQueue.queueDelete('companies', id);
      await (_db.delete(_db.companies)..where((c) => c.id.equals(id))).go();
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

  Future<String> generateId() async {
    return const Uuid().v4();
  }

  Future<Company> createWithOwner({
    required String name,
    required String legalStatus,
    required String userId,
    required String userEmail,
    String? ice,
    String? ifNumber,
    String? rc,
    String? cnss,
    String? address,
    String? phone,
    bool isAutoEntrepreneur = false,
  }) async {
    _log.debug(
      LogTags.repo,
      'createWithOwner - starting',
      data: {'name': name},
    );
    try {
      final companyId = await generateId();
      final now = DateTime.now();

      final company = Company(
        id: companyId,
        name: name,
        legalStatus: legalStatus,
        ice: ice,
        ifNumber: ifNumber,
        rc: rc,
        cnss: cnss,
        address: address,
        phone: phone,
        isAutoEntrepreneur: isAutoEntrepreneur,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
      );

      final companyUser = CompanyUser(
        id: const Uuid().v4(),
        companyId: companyId,
        userId: userId,
        role: UserRole.owner,
        createdAt: now,
      );

      await _db.transaction(() async {
        await _db.into(_db.companies).insert(company);
        await _db.into(_db.companyUsers).insert(companyUser);

        var userProfile = await (_db.select(
          _db.userProfiles,
        )..where((u) => u.id.equals(userId))).getSingleOrNull();

        if (userProfile != null) {
          await (_db.update(
            _db.userProfiles,
          )..where((u) => u.id.equals(userId))).write(
            UserProfilesCompanion(
              defaultCompanyId: Value(companyId),
              updatedAt: Value(now),
            ),
          );
        } else {
          await _db
              .into(_db.userProfiles)
              .insert(
                UserProfile(
                  id: userId,
                  email: userEmail,
                  defaultCompanyId: companyId,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }
      });

      final taxRepo = TaxRepository(_db, _syncQueue);
      await taxRepo.createDefaults(companyId);

      await _db
          .into(_db.invoiceTemplates)
          .insert(
            InvoiceTemplate(
              id: 'classic',
              companyId: companyId,
              name: 'Classique',
              description: 'Logo à gauche, tableau propre',
              headerStyle: HeaderStyle.logoLeft,
              primaryColor: '#1976D2',
              showCustomerIce: true,
              showPaymentTerms: true,
              showProductSkus: false,
              isDefault: true,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db
          .into(_db.invoiceTemplates)
          .insert(
            InvoiceTemplate(
              id: 'minimal',
              companyId: companyId,
              name: 'Minimaliste',
              description: 'Texte uniquement, sans logo',
              headerStyle: HeaderStyle.noLogo,
              primaryColor: '#424242',
              showCustomerIce: false,
              showPaymentTerms: false,
              showProductSkus: false,
              isDefault: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db
          .into(_db.invoiceTemplates)
          .insert(
            InvoiceTemplate(
              id: 'detailed',
              companyId: companyId,
              name: 'Détaillé',
              description: 'Logo à droite, affiche les SKUs',
              headerStyle: HeaderStyle.logoRight,
              primaryColor: '#388E3C',
              showCustomerIce: true,
              showPaymentTerms: true,
              showProductSkus: true,
              isDefault: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _syncQueue.queueInsert('companies', companyId);
      await _syncQueue.queueInsert('company_users', companyUser.id);

      _log.info(
        LogTags.repo,
        'createWithOwner - completed',
        data: {'id': companyId},
      );
      return company;
    } catch (e, st) {
      _log.error(LogTags.repo, 'createWithOwner - failed', error: e, stack: st);
      rethrow;
    }
  }
}
