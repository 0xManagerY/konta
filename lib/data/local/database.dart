import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/tables.dart';

part 'database.g.dart';

AppDatabase? _database;

AppDatabase getDatabase() {
  _database ??= AppDatabase._internal();
  return _database!;
}

@DriftDatabase(
  tables: [
    UserProfiles,
    Companies,
    CompanyUsers,
    Contacts,
    Taxes,
    Items,
    Documents,
    DocumentLines,
    Expenses,
    Payments,
    OwnerSalaries,
    AdminSettings,
    AuditLogs,
    SyncQueue,
    RolePermissions,
    CompanyInvites,
    InvoiceTemplates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 9) {
          await _migrateToV9(m);
        }
        if (from < 10) {
          await _migrateToV10(m);
        }
      },
    );
  }

  Future<void> _createIndexes(Migrator m) async {
    await m.createIndex(
      Index(
        'idx_companies_id',
        'CREATE INDEX idx_companies_id ON companies (id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_company_users_company_id',
        'CREATE INDEX idx_company_users_company_id ON company_users (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_company_users_user_id',
        'CREATE INDEX idx_company_users_user_id ON company_users (user_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_contacts_company_id',
        'CREATE INDEX idx_contacts_company_id ON contacts (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_taxes_company_id',
        'CREATE INDEX idx_taxes_company_id ON taxes (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_items_company_id',
        'CREATE INDEX idx_items_company_id ON items (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_documents_company_id',
        'CREATE INDEX idx_documents_company_id ON documents (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_document_lines_document_id',
        'CREATE INDEX idx_document_lines_document_id ON document_lines (document_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_expenses_company_id',
        'CREATE INDEX idx_expenses_company_id ON expenses (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_payments_company_id',
        'CREATE INDEX idx_payments_company_id ON payments (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_sync_queue_created',
        'CREATE INDEX idx_sync_queue_created ON sync_queue (created_at)',
      ),
    );
  }

  Future<void> _migrateToV9(Migrator m) async {
    await m.createTable(companies);
    await m.createTable(companyUsers);
    await m.createTable(taxes);
    await m.createTable(items);
    await m.createTable(documents);
    await m.createTable(documentLines);
    await m.createTable(ownerSalaries);
    await m.createTable(auditLogs);
    await _createIndexes(m);
  }

  Future<void> _migrateToV10(Migrator m) async {
    await m.createTable(rolePermissions);
    await m.createTable(companyInvites);
    await m.createTable(invoiceTemplates);
    await _createIndexesForV10(m);
  }

  Future<void> _createIndexesForV10(Migrator m) async {
    await m.createIndex(
      Index(
        'idx_role_permissions_company_id',
        'CREATE INDEX idx_role_permissions_company_id ON role_permissions (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_role_permissions_role_type',
        'CREATE INDEX idx_role_permissions_role_type ON role_permissions (role_type)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_company_invites_code',
        'CREATE INDEX idx_company_invites_code ON company_invites (code)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_company_invites_company_id',
        'CREATE INDEX idx_company_invites_company_id ON company_invites (company_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_invoice_templates_company_id',
        'CREATE INDEX idx_invoice_templates_company_id ON invoice_templates (company_id)',
      ),
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'konta_db');
}

extension CompanyHelpers on AppDatabase {
  Future<List<Company>> getAllCompanies() => select(companies).get();

  Future<Company?> getCompanyById(String id) =>
      (select(companies)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<Company>> getUserCompanies(String userId) async {
    final userCompanyIds = await (select(
      companyUsers,
    )..where((cu) => cu.userId.equals(userId))).get();
    final ids = userCompanyIds.map((cu) => cu.companyId).toList();
    if (ids.isEmpty) return [];
    return (select(companies)..where((c) => c.id.isIn(ids))).get();
  }

  Future<CompanyUser?> getUserRole(String companyId, String userId) =>
      (select(companyUsers)..where(
            (cu) => cu.companyId.equals(companyId) & cu.userId.equals(userId),
          ))
          .getSingleOrNull();

  Future<bool> userHasRole(
    String companyId,
    String userId,
    List<UserRole> roles,
  ) async {
    final userRole = await getUserRole(companyId, userId);
    if (userRole == null) return false;
    return roles.contains(userRole.role);
  }

  Future<void> removeUserFromCompany(String companyId, String userId) async {
    final companyUser = await getUserRole(companyId, userId);
    if (companyUser != null) {
      await (delete(
        companyUsers,
      )..where((cu) => cu.id.equals(companyUser.id))).go();
    }
  }
}

extension ContactHelpers on AppDatabase {
  Future<List<Contact>> getContactsByCompany(String companyId) =>
      (select(contacts)
            ..where((c) => c.companyId.equals(companyId))
            ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
          .get();

  Future<List<Contact>> getContactsByType(String companyId, ContactType type) =>
      (select(contacts)
            ..where(
              (c) =>
                  c.companyId.equals(companyId) &
                  c.contactType.equals(type.name),
            )
            ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
          .get();

  Future<Contact?> getContactById(String id) =>
      (select(contacts)..where((c) => c.id.equals(id))).getSingleOrNull();
}

extension TaxHelpers on AppDatabase {
  Future<List<Tax>> getTaxesByCompany(String companyId) =>
      (select(taxes)
            ..where(
              (t) => t.companyId.equals(companyId) & t.isActive.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.rate)]))
          .get();

  Future<Tax?> getTaxById(String id) =>
      (select(taxes)..where((t) => t.id.equals(id))).getSingleOrNull();
}

extension ItemHelpers on AppDatabase {
  Future<List<Item>> getItemsByCompany(String companyId) =>
      (select(items)
            ..where(
              (i) => i.companyId.equals(companyId) & i.isActive.equals(true),
            )
            ..orderBy([(i) => OrderingTerm.asc(i.name)]))
          .get();

  Future<List<Item>> getItemsByCategory(String companyId, String category) =>
      (select(items)
            ..where(
              (i) =>
                  i.companyId.equals(companyId) &
                  i.category.equals(category) &
                  i.isActive.equals(true),
            )
            ..orderBy([(i) => OrderingTerm.asc(i.name)]))
          .get();

  Future<Item?> getItemById(String id) =>
      (select(items)..where((i) => i.id.equals(id))).getSingleOrNull();
}

extension DocumentHelpers on AppDatabase {
  Future<List<Document>> getDocumentsByCompany(String companyId) =>
      (select(documents)
            ..where((d) => d.companyId.equals(companyId))
            ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
          .get();

  Future<List<Document>> getDocumentsByContact(String contactId) =>
      (select(documents)
            ..where((d) => d.contactId.equals(contactId))
            ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
          .get();

  Future<List<Document>> getDocumentsByType(
    String companyId,
    DocumentType type,
  ) =>
      (select(documents)
            ..where(
              (d) => d.companyId.equals(companyId) & d.type.equals(type.name),
            )
            ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
          .get();

  Future<Document?> getDocumentById(String id) =>
      (select(documents)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<List<DocumentLine>> getDocumentLines(String documentId) => (select(
    documentLines,
  )..where((dl) => dl.documentId.equals(documentId))).get();
}

extension ExpenseHelpers on AppDatabase {
  Future<List<Expense>> getExpensesByCompany(String companyId) =>
      (select(expenses)
            ..where((e) => e.companyId.equals(companyId))
            ..orderBy([(e) => OrderingTerm.desc(e.date)]))
          .get();

  Future<List<Expense>> getExpensesByMonth(
    String companyId,
    int year,
    int month,
  ) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return (select(expenses)
          ..where(
            (e) =>
                e.companyId.equals(companyId) &
                e.date.isBiggerOrEqualValue(start) &
                e.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.date)]))
        .get();
  }

  Future<double> getTotalExpensesByMonth(
    String companyId,
    int year,
    int month,
  ) async {
    final expList = await getExpensesByMonth(companyId, year, month);
    return expList.fold<double>(0.0, (sum, e) => sum + e.amount);
  }
}

extension PaymentHelpers on AppDatabase {
  Future<List<Payment>> getPaymentsByCompany(String companyId) =>
      (select(payments)
            ..where((p) => p.companyId.equals(companyId))
            ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
          .get();

  Future<List<Payment>> getPaymentsByDocument(String documentId) =>
      (select(payments)
            ..where((p) => p.documentId.equals(documentId))
            ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
          .get();

  Future<double> getTotalPaidForDocument(String documentId) async {
    final payList = await getPaymentsByDocument(documentId);
    return payList.fold<double>(0.0, (sum, p) => sum + p.amount);
  }

  Future<List<Payment>> getPendingChecks() {
    final now = DateTime.now();
    return (select(payments)
          ..where(
            (p) =>
                p.method.equals('check') &
                p.checkDueDate.isNotNull() &
                p.checkDueDate.isBiggerOrEqualValue(now),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.checkDueDate)]))
        .get();
  }

  Future<List<Payment>> getOverdueChecks() {
    final now = DateTime.now();
    return (select(payments)
          ..where(
            (p) =>
                p.method.equals('check') &
                p.checkDueDate.isNotNull() &
                p.checkDueDate.isSmallerThanValue(now),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.checkDueDate)]))
        .get();
  }
}

extension CompanyInviteHelpers on AppDatabase {
  Future<List<CompanyInvite>> getInvitesByCompany(String companyId) =>
      (select(companyInvites)
            ..where((i) => i.companyId.equals(companyId))
            ..where((i) => i.isActive.equals(true))
            ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
          .get();

  Future<CompanyInvite?> getInviteByCode(String code) => (select(
    companyInvites,
  )..where((i) => i.code.equals(code.toUpperCase()))).getSingleOrNull();

  Future<CompanyInvite?> getActiveInviteByCode(String code) =>
      (select(companyInvites)
            ..where((i) => i.code.equals(code.toUpperCase()))
            ..where((i) => i.isActive.equals(true)))
          .getSingleOrNull();
}

extension RolePermissionHelpers on AppDatabase {
  Future<List<RolePermission>> getPermissionsByCompany(String companyId) =>
      (select(
        rolePermissions,
      )..where((r) => r.companyId.equals(companyId))).get();

  Future<List<RolePermission>> getPermissionsByRole(
    String companyId,
    UserRole roleType,
  ) =>
      (select(rolePermissions)
            ..where((r) => r.companyId.equals(companyId))
            ..where((r) => r.roleType.equals(roleType.name)))
          .get();

  Future<bool> hasPermission(
    String companyId,
    UserRole role,
    String permissionKey,
  ) async {
    final result =
        await (select(rolePermissions)
              ..where((r) => r.companyId.equals(companyId))
              ..where((r) => r.roleType.equals(role.name))
              ..where((r) => r.permissionKey.equals(permissionKey)))
            .getSingleOrNull();
    return result?.isEnabled ?? false;
  }
}

extension InvoiceTemplateHelpers on AppDatabase {
  Future<List<InvoiceTemplate>> getTemplatesByCompany(String? companyId) =>
      (select(invoiceTemplates)
            ..where(
              (t) => companyId != null
                  ? (t.companyId.equals(companyId) | t.companyId.isNull())
                  : const Constant(true),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<List<InvoiceTemplate>> getDefaultTemplates() =>
      (select(invoiceTemplates)
            ..where((t) => t.companyId.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<InvoiceTemplate?> getTemplateById(String id) => (select(
    invoiceTemplates,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<InvoiceTemplate?> getCompanyDefaultTemplate(String companyId) =>
      (select(invoiceTemplates)
            ..where((t) => t.companyId.equals(companyId))
            ..where((t) => t.isDefault.equals(true)))
          .getSingleOrNull();
}
