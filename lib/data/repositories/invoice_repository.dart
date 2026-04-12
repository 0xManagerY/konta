import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class InvoiceRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  InvoiceRepository(this._db, this._syncQueue);

  Future<List<Invoice>> getAll(String userId) async {
    Logger.method('InvoiceRepository', 'getAll', {'userId': userId});
    return (_db.select(_db.invoices)
          ..where((i) => i.userId.equals(userId))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<List<Invoice>> getByType(String userId, String type) async {
    Logger.method('InvoiceRepository', 'getByType', {
      'userId': userId,
      'type': type,
    });
    return (_db.select(_db.invoices)
          ..where((i) => i.userId.equals(userId) & i.type.equals(type))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<Invoice?> getById(String id) async {
    Logger.method('InvoiceRepository', 'getById', {'id': id});
    return (_db.select(
      _db.invoices,
    )..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  Future<List<Invoice>> getFacturesFromDevis(String devisId) async {
    Logger.method('InvoiceRepository', 'getFacturesFromDevis', {
      'devisId': devisId,
    });
    return (_db.select(_db.invoices)..where(
          (i) => i.parentDocumentId.equals(devisId) & i.type.equals('invoice'),
        ))
        .get();
  }

  Future<List<Invoice>> getAvoirsForDocument(String documentId) async {
    Logger.method('InvoiceRepository', 'getAvoirsForDocument', {
      'documentId': documentId,
    });
    return (_db.select(_db.invoices)..where(
          (i) => i.parentDocumentId.equals(documentId) & i.type.equals('avoir'),
        ))
        .get();
  }

  Future<List<InvoiceItem>> getItems(String invoiceId) async {
    Logger.method('InvoiceRepository', 'getItems', {'invoiceId': invoiceId});
    return (_db.select(
      _db.invoiceItems,
    )..where((i) => i.invoiceId.equals(invoiceId))).get();
  }

  Future<void> insertWithItems(Invoice invoice, List<InvoiceItem> items) async {
    Logger.method('InvoiceRepository', 'insertWithItems', {
      'id': invoice.id,
      'itemsCount': items.length,
    });
    Logger.db('INSERT', 'invoices', {
      'id': invoice.id,
      'number': invoice.number,
    });
    await _db.transaction(() async {
      await _db.into(_db.invoices).insert(invoice);
      for (final item in items) {
        Logger.db('INSERT', 'invoice_items', {
          'id': item.id,
          'invoiceId': invoice.id,
        });
        await _db.into(_db.invoiceItems).insert(item);
      }
    });
    await _syncQueue.queueInsert('invoices', invoice.id);
    Logger.success('Invoice with items inserted', tag: 'REPO');
  }

  Future<Invoice> createFactureFromDevis(
    Invoice devis, {
    List<InvoiceItem>? items,
  }) async {
    Logger.method('InvoiceRepository', 'createFactureFromDevis', {
      'devisId': devis.id,
    });
    final newId = await generateId();
    final newNumber = await generateNumber(devis.userId, 'invoice');

    final facture = Invoice(
      id: newId,
      userId: devis.userId,
      customerId: devis.customerId,
      type: 'invoice',
      number: newNumber,
      status: 'draft',
      issueDate: DateTime.now(),
      dueDate: devis.dueDate,
      subtotal: devis.subtotal,
      tvaAmount: devis.tvaAmount,
      total: devis.total,
      notes: devis.notes,
      parentDocumentId: devis.id,
      parentDocumentType: 'devis',
      isConverted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: 'pending',
    );

    final factureItems = items ?? await getItems(devis.id);
    final newItems = factureItems
        .map(
          (item) => InvoiceItem(
            id: const Uuid().v4(),
            invoiceId: newId,
            productId: item.productId,
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            tvaRate: item.tvaRate,
            total: item.total,
          ),
        )
        .toList();

    await insertWithItems(facture, newItems);

    await (_db.update(_db.invoices)).replace(
      devis.copyWith(
        isConverted: true,
        status: 'converted',
        updatedAt: DateTime.now(),
      ),
    );

    return facture;
  }

  Future<Invoice> createAvoirFromDocument(
    Invoice document, {
    List<InvoiceItem>? items,
    String? refundReason,
    double? refundAmount,
  }) async {
    Logger.method('InvoiceRepository', 'createAvoirFromDocument', {
      'documentId': document.id,
      'refundReason': refundReason,
      'refundAmount': refundAmount,
    });
    final newId = await generateId();
    final newNumber = await generateNumber(document.userId, 'avoir');

    final finalAmount = refundAmount ?? document.total;
    final ratio = finalAmount / document.total;
    final avoirSubtotal = document.subtotal * ratio;
    final avoirTva = document.tvaAmount * ratio;

    final avoir = Invoice(
      id: newId,
      userId: document.userId,
      customerId: document.customerId,
      type: 'avoir',
      number: newNumber,
      status: 'draft',
      issueDate: DateTime.now(),
      subtotal: avoirSubtotal,
      tvaAmount: avoirTva,
      total: finalAmount,
      notes: document.notes,
      parentDocumentId: document.id,
      parentDocumentType: document.type,
      refundReason: refundReason,
      isConverted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: 'pending',
    );

    final documentItems = items ?? await getItems(document.id);
    final newItems = documentItems
        .map(
          (item) => InvoiceItem(
            id: const Uuid().v4(),
            invoiceId: newId,
            productId: item.productId,
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            tvaRate: item.tvaRate,
            total: item.total * ratio,
          ),
        )
        .toList();

    await insertWithItems(avoir, newItems);
    return avoir;
  }

  Future<void> update(Invoice invoice) async {
    Logger.method('InvoiceRepository', 'update', {'id': invoice.id});
    Logger.db('UPDATE', 'invoices', {
      'id': invoice.id,
      'status': invoice.status,
    });
    await (_db.update(_db.invoices)).replace(invoice);
    await _syncQueue.queueUpdate('invoices', invoice.id);
    Logger.success('Invoice updated', tag: 'REPO');
  }

  Future<void> updateItems(String invoiceId, List<InvoiceItem> items) async {
    Logger.method('InvoiceRepository', 'updateItems', {
      'invoiceId': invoiceId,
      'itemsCount': items.length,
    });
    await _db.transaction(() async {
      await (_db.delete(
        _db.invoiceItems,
      )..where((i) => i.invoiceId.equals(invoiceId))).go();
      for (final item in items) {
        Logger.db('INSERT', 'invoice_items', {'id': item.id});
        await _db.into(_db.invoiceItems).insert(item);
      }
    });
    Logger.success('Invoice items updated', tag: 'REPO');
  }

  Future<void> delete(String id) async {
    Logger.method('InvoiceRepository', 'delete', {'id': id});
    Logger.db('DELETE', 'invoices', {'id': id});
    await _syncQueue.queueDelete('invoices', id);
    await _db.transaction(() async {
      await (_db.delete(
        _db.invoiceItems,
      )..where((i) => i.invoiceId.equals(id))).go();
      await (_db.delete(_db.invoices)..where((i) => i.id.equals(id))).go();
    });
    Logger.success('Invoice deleted', tag: 'REPO');
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    Logger.debug('Generated ID: $id', tag: 'REPO');
    return id;
  }

  Future<String> generateNumber(String userId, String type) async {
    final year = DateTime.now().year;
    final count =
        await (_db.select(_db.invoices)
              ..where((i) => i.userId.equals(userId) & i.type.equals(type)))
            .get()
            .then((list) => list.length + 1);
    final prefix = switch (type) {
      'invoice' => 'FAC',
      'devis' => 'DEV',
      'avoir' => 'AVR',
      _ => 'DOC',
    };
    final number = '$prefix-$year-${count.toString().padLeft(4, '0')}';
    Logger.debug('Generated invoice number: $number', tag: 'REPO');
    return number;
  }
}
