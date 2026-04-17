import 'package:drift/drift.dart';

enum UserRole { owner, manager, accountant, viewer }

enum ContactType { customer, supplier, both }

enum DocumentType { invoice, quote, creditNote }

enum DocumentStatus { draft, sent, paid, overdue, cancelled }

@DataClassName('UserProfile')
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get defaultCompanyId =>
      text().named('default_company_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Company')
class Companies extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get legalStatus => text().named('legal_status')();
  TextColumn get ice => text().nullable()();
  TextColumn get ifNumber => text().named('if_number').nullable()();
  TextColumn get rc => text().nullable()();
  TextColumn get cnss => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get logoUrl => text().named('logo_url').nullable()();
  BoolColumn get isAutoEntrepreneur => boolean()
      .named('is_auto_entrepreneur')
      .withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompanyUser')
class CompanyUsers extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get userId => text().named('user_id')();
  TextColumn get role => textEnum<UserRole>()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Contact')
class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get name => text()();
  TextColumn get contactType =>
      text().named('contact_type').withDefault(const Constant('customer'))();
  TextColumn get ice => text().nullable()();
  TextColumn get rc => text().nullable()();
  TextColumn get ifNumber => text().named('if_number').nullable()();
  TextColumn get patente => text().nullable()();
  TextColumn get cnss => text().nullable()();
  TextColumn get legalForm => text().named('legal_form').nullable()();
  TextColumn get capital => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phones => text().named('phones').nullable()();
  TextColumn get fax => text().nullable()();
  TextColumn get emails => text().named('emails').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Tax')
class Taxes extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get name => text()();
  RealColumn get rate => real()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Item')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get defaultUnitPrice =>
      real().named('default_unit_price').withDefault(const Constant(0))();
  TextColumn get defaultTaxId => text().named('default_tax_id').nullable()();
  TextColumn get category => text().nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Document')
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get contactId => text().named('contact_id')();
  TextColumn get type => textEnum<DocumentType>()();
  TextColumn get number => text()();
  TextColumn get status => textEnum<DocumentStatus>()();
  DateTimeColumn get issueDate => dateTime().named('issue_date')();
  DateTimeColumn get dueDate => dateTime().named('due_date').nullable()();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get tvaAmount =>
      real().named('tva_amount').withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get parentDocumentId =>
      text().named('parent_document_id').nullable()();
  TextColumn get parentDocumentType =>
      text().named('parent_document_type').nullable()();
  TextColumn get refundReason => text().named('refund_reason').nullable()();
  BoolColumn get isConverted =>
      boolean().named('is_converted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DocumentLine')
class DocumentLines extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text().named('document_id')();
  TextColumn get itemId => text().named('item_id').nullable()();
  TextColumn get description => text()();
  RealColumn get quantity => real().withDefault(const Constant(1))();
  RealColumn get unitPrice => real().named('unit_price')();
  TextColumn get taxId => text().named('tax_id').nullable()();
  RealColumn get tvaRate =>
      real().named('tva_rate').withDefault(const Constant(0))();
  RealColumn get total => real()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Expense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  RealColumn get tvaAmount =>
      real().named('tva_amount').withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get receiptUrl => text().named('receipt_url').nullable()();
  TextColumn get receiptLocalPath =>
      text().named('receipt_local_path').nullable()();
  BoolColumn get isDeductible =>
      boolean().named('is_deductible').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Payment')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get documentId => text().named('document_id')();
  RealColumn get amount => real()();
  TextColumn get method => text()();
  DateTimeColumn get paymentDate => dateTime().named('payment_date')();
  DateTimeColumn get checkDueDate =>
      dateTime().named('check_due_date').nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OwnerSalary')
class OwnerSalaries extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get userId => text().named('user_id')();
  RealColumn get amount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  DateTimeColumn get paymentDate =>
      dateTime().named('payment_date').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AdminSetting')
class AdminSettings extends Table {
  TextColumn get id => text()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AuditLog')
class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id').nullable()();
  TextColumn get userId => text().named('user_id').nullable()();
  TextColumn get action => text()();
  TextColumn get tblName => text().named('table_name')();
  TextColumn get recordId => text().named('record_id').nullable()();
  TextColumn get oldData => text().named('old_data').nullable()();
  TextColumn get newData => text().named('new_data').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RolePermission')
class RolePermissions extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get roleType => textEnum<UserRole>()();
  TextColumn get permissionKey => text().named('permission_key')();
  BoolColumn get isEnabled =>
      boolean().named('is_enabled').withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompanyInvite')
class CompanyInvites extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id')();
  TextColumn get code => text()();
  TextColumn get createdBy => text().named('created_by')();
  TextColumn get role => textEnum<UserRole>()();
  IntColumn get maxUses => integer().named('max_uses').nullable()();
  IntColumn get usesCount =>
      integer().named('uses_count').withDefault(const Constant(0))();
  DateTimeColumn get expiresAt => dateTime().named('expires_at').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

enum HeaderStyle { logoLeft, logoCenter, logoRight, noLogo }

@DataClassName('InvoiceTemplate')
class InvoiceTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().named('company_id').nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get headerStyle => textEnum<HeaderStyle>()();
  TextColumn get primaryColor => text().named('primary_color')();
  BoolColumn get showCustomerIce =>
      boolean().named('show_customer_ice').withDefault(const Constant(true))();
  BoolColumn get showPaymentTerms =>
      boolean().named('show_payment_terms').withDefault(const Constant(true))();
  BoolColumn get showProductSkus =>
      boolean().named('show_product_skus').withDefault(const Constant(false))();
  TextColumn get footerText => text().named('footer_text').nullable()();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncQueueItem')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tblName => text().named('table_name')();
  TextColumn get operation => text()();
  TextColumn get recordId => text().named('record_id')();
  TextColumn get data => text().nullable()();
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
}
