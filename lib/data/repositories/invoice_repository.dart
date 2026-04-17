import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class InvoiceRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;

  InvoiceRepository(this._db, this._syncQueue);

  Future<List<Document>> getAll(String companyId) async {
    Logger.method('InvoiceRepository', 'getAll', {'companyId': companyId});
    return (_db.select(_db.documents)
          ..where((i) => i.companyId.equals(companyId))
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<List<Document>> getByType(String companyId, DocumentType type) async {
    Logger.method('InvoiceRepository', 'getByType', {
      'companyId': companyId,
      'type': type,
    });
    return (_db.select(_db.documents)
          ..where(
            (i) => i.companyId.equals(companyId) & i.type.equals(type.name),
          )
          ..orderBy([
            (i) =>
                OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<Document?> getById(String id) async {
    Logger.method('InvoiceRepository', 'getById', {'id': id});
    return (_db.select(
      _db.documents,
    )..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  Future<List<Document>> getFacturesFromDevis(String devisId) async {
    Logger.method('InvoiceRepository', 'getFacturesFromDevis', {
      'devisId': devisId,
    });
    return (_db.select(_db.documents)..where(
          (i) =>
              i.parentDocumentId.equals(devisId) &
              i.type.equals(DocumentType.invoice.name),
        ))
        .get();
  }

  Future<List<Document>> getAvoirsForDocument(String documentId) async {
    Logger.method('InvoiceRepository', 'getAvoirsForDocument', {
      'documentId': documentId,
    });
    return (_db.select(_db.documents)..where(
          (i) =>
              i.parentDocumentId.equals(documentId) &
              i.type.equals(DocumentType.creditNote.name),
        ))
        .get();
  }

  Future<List<DocumentLine>> getItems(String documentId) async {
    Logger.method('InvoiceRepository', 'getItems', {'documentId': documentId});
    return (_db.select(
      _db.documentLines,
    )..where((i) => i.documentId.equals(documentId))).get();
  }

  Future<void> insertWithItems(
    Document invoice,
    List<DocumentLine> items,
  ) async {
    Logger.method('InvoiceRepository', 'insertWithItems', {
      'id': invoice.id,
      'itemsCount': items.length,
    });
    Logger.db('INSERT', 'invoices', {
      'id': invoice.id,
      'number': invoice.number,
    });
    await _db.transaction(() async {
      await _db.into(_db.documents).insert(invoice);
      for (final item in items) {
        Logger.db('INSERT', 'invoice_items', {
          'id': item.id,
          'documentId': invoice.id,
        });
        await _db.into(_db.documentLines).insert(item);
      }
    });
    await _syncQueue.queueInsert('invoices', invoice.id);
    for (final item in items) {
      await _syncQueue.queueInsert('invoice_items', item.id);
    }
    Logger.success('Invoice with items inserted', tag: 'REPO');
  }

  Future<Document> createFactureFromDevis(
    Document devis, {
    List<DocumentLine>? items,
  }) async {
    Logger.method('InvoiceRepository', 'createFactureFromDevis', {
      'devisId': devis.id,
    });
    final newId = await generateId();
    final newNumber = await generateNumber(
      devis.companyId,
      DocumentType.invoice,
    );

    final facture = Document(
      id: newId,
      companyId: devis.companyId,
      contactId: devis.contactId,
      type: DocumentType.invoice,
      number: newNumber,
      status: DocumentStatus.draft,
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
          (item) => DocumentLine(
            id: const Uuid().v4(),
            documentId: newId,
            itemId: item.itemId,
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            tvaRate: item.tvaRate,
            total: item.total,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'pending',
          ),
        )
        .toList();

    await insertWithItems(facture, newItems);

    await (_db.update(
      _db.documents,
    )).replace(devis.copyWith(isConverted: true, updatedAt: DateTime.now()));

    return facture;
  }

  Future<Document> createAvoirFromDocument(
    Document document, {
    List<DocumentLine>? items,
    String? refundReason,
    double? refundAmount,
  }) async {
    Logger.method('InvoiceRepository', 'createAvoirFromDocument', {
      'documentId': document.id,
      'refundReason': refundReason,
      'refundAmount': refundAmount,
    });
    final newId = await generateId();
    final newNumber = await generateNumber(
      document.companyId,
      DocumentType.creditNote,
    );

    final finalAmount = refundAmount ?? document.total;
    final ratio = finalAmount / document.total;
    final avoirSubtotal = document.subtotal * ratio;
    final avoirTva = document.tvaAmount * ratio;

    final avoir = Document(
      id: newId,
      companyId: document.companyId,
      contactId: document.contactId,
      type: DocumentType.creditNote,
      number: newNumber,
      status: DocumentStatus.draft,
      issueDate: DateTime.now(),
      subtotal: avoirSubtotal,
      tvaAmount: avoirTva,
      total: finalAmount,
      notes: document.notes,
      parentDocumentId: document.id,
      parentDocumentType: 'document',
      refundReason: refundReason,
      isConverted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: 'pending',
    );

    final documentItems = items ?? await getItems(document.id);
    final newItems = documentItems
        .map(
          (item) => DocumentLine(
            id: const Uuid().v4(),
            documentId: newId,
            itemId: item.itemId,
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            tvaRate: item.tvaRate,
            total: item.total * ratio,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'pending',
          ),
        )
        .toList();

    await insertWithItems(avoir, newItems);
    return avoir;
  }

  Future<void> update(Document invoice) async {
    Logger.method('InvoiceRepository', 'update', {'id': invoice.id});
    Logger.db('UPDATE', 'invoices', {
      'id': invoice.id,
      'status': invoice.status,
    });
    await (_db.update(_db.documents)).replace(invoice);
    await _syncQueue.queueUpdate('invoices', invoice.id);
    Logger.success('Invoice updated', tag: 'REPO');
  }

  Future<void> updateItems(String invoiceId, List<DocumentLine> items) async {
    Logger.method('InvoiceRepository', 'updateItems', {
      'invoiceId': invoiceId,
      'itemsCount': items.length,
    });

    await _db.transaction(() async {
      await (_db.delete(
        _db.documentLines,
      )..where((i) => i.documentId.equals(invoiceId))).go();

      for (final item in items) {
        final itemToInsert = DocumentLine(
          id: item.id,
          documentId: invoiceId,
          itemId: item.itemId,
          description: item.description,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          tvaRate: item.tvaRate,
          total: item.total,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
        );
        Logger.db('INSERT', 'invoice_items', {
          'id': item.id,
          'documentId': invoiceId,
        });
        await _db.into(_db.documentLines).insert(itemToInsert);
      }
    });

    await _syncQueue.queueUpdate('invoices', invoiceId);
    for (final item in items) {
      await _syncQueue.queueInsert('invoice_items', item.id);
    }
    Logger.success('Invoice items updated', tag: 'REPO');
  }

  Future<void> delete(String id) async {
    Logger.method('InvoiceRepository', 'delete', {'id': id});
    Logger.db('DELETE', 'invoices', {'id': id});
    final items = await getItems(id);
    for (final item in items) {
      await _syncQueue.queueDelete('invoice_items', item.id);
    }
    await _syncQueue.queueDelete('invoices', id);
    await _db.transaction(() async {
      await (_db.delete(
        _db.documentLines,
      )..where((i) => i.documentId.equals(id))).go();
      await (_db.delete(_db.documents)..where((i) => i.id.equals(id))).go();
    });
    Logger.success('Invoice deleted', tag: 'REPO');
  }

  Future<String> generateId() async {
    final id = const Uuid().v4();
    Logger.debug('Generated ID: $id', tag: 'REPO');
    return id;
  }

  Future<String> generateNumber(String companyId, DocumentType type) async {
    final year = DateTime.now().year;
    final count =
        await (_db.select(_db.documents)..where(
              (i) => i.companyId.equals(companyId) & i.type.equals(type.name),
            ))
            .get()
            .then((list) => list.length + 1);
    final prefix = switch (type) {
      DocumentType.invoice => 'FAC',
      DocumentType.quote => 'DEV',
      DocumentType.creditNote => 'AVR',
    };
    final number = '$prefix-$year-${count.toString().padLeft(4, '0')}';
    Logger.debug('Generated invoice number: $number', tag: 'REPO');
    return number;
  }
}
