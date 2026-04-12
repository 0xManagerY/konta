import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Customers,
    Products,
    Invoices,
    InvoiceItems,
    Expenses,
    Payments,
    OwnerSalaries,
    AdminSettings,
    AuditLogs,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await _createIndexes(m);
        }
        if (from < 3) {
          await m.createTable(products);
        }
        if (from < 4) {
          await m.addColumn(customers, customers.rc);
          await m.addColumn(customers, customers.ifNumber);
          await m.addColumn(customers, customers.patente);
          await m.addColumn(customers, customers.cnss);
          await m.addColumn(customers, customers.legalForm);
          await m.addColumn(customers, customers.capital);
          await m.addColumn(customers, customers.status);
          await m.addColumn(customers, customers.fax);
          await m.addColumn(customers, customers.phones);
          await m.addColumn(customers, customers.emails);
        }
        if (from < 5) {
          await m.addColumn(products, products.description);
        }
        if (from < 6) {
          await m.addColumn(invoiceItems, invoiceItems.productName);
        }
      },
    );
  }

  Future<void> _createIndexes(Migrator m) async {
    await m.createIndex(
      Index(
        'idx_customers_user_id',
        'CREATE INDEX idx_customers_user_id ON customers (user_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_invoices_user_id',
        'CREATE INDEX idx_invoices_user_id ON invoices (user_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_invoices_customer_id',
        'CREATE INDEX idx_invoices_customer_id ON invoices (customer_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_invoice_items_invoice_id',
        'CREATE INDEX idx_invoice_items_invoice_id ON invoice_items (invoice_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_expenses_user_id',
        'CREATE INDEX idx_expenses_user_id ON expenses (user_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_payments_invoice_id',
        'CREATE INDEX idx_payments_invoice_id ON payments (invoice_id)',
      ),
    );
    await m.createIndex(
      Index(
        'idx_sync_queue_created',
        'CREATE INDEX idx_sync_queue_created ON sync_queue (created_at)',
      ),
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'konta_db');
}
