import 'package:drift/drift.dart';

@DataClassName('Profile')
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get companyName => text().named('company_name')();
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

@DataClassName('Customer')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get name => text()();
  TextColumn get ice => text().nullable()();
  TextColumn get rc => text().nullable()();
  TextColumn get ifNumber => text().named('if_number').nullable()();
  TextColumn get patente => text().nullable()();
  TextColumn get cnss => text().nullable()();
  TextColumn get legalForm => text().named('legal_form').nullable()();
  TextColumn get capital => text().nullable()();
  TextColumn get status => text().nullable()();
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

@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Invoice')
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get customerId => text().named('customer_id')();
  TextColumn get type => text()();
  TextColumn get number => text()();
  TextColumn get status => text()();
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

@DataClassName('InvoiceItem')
class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().named('invoice_id')();
  TextColumn get productId => text().named('product_id').nullable()();
  TextColumn get productName => text().named('product_name').nullable()();
  TextColumn get description => text()();
  RealColumn get quantity => real().withDefault(const Constant(1))();
  RealColumn get unitPrice => real().named('unit_price')();
  RealColumn get tvaRate =>
      real().named('tva_rate').withDefault(const Constant(20))();
  RealColumn get total => real()();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Expense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
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
  TextColumn get invoiceId => text().named('invoice_id')();
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
