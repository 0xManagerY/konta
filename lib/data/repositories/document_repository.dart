import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/sync/sync_queue_helper.dart';

class DocumentRepository {
  final AppDatabase _db;
  final SyncQueueHelper _syncQueue;
  final LogService _log = LogService();

  DocumentRepository(this._db, this._syncQueue);

  Future<List<Document>> getAll(String companyId) async {
    _log.debug(
      LogTags.repo,
      'getAll - fetching documents',
      data: {'companyId': companyId},
    );
    try {
      final result = await _db.getDocumentsByCompany(companyId);
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

  Future<List<Document>> getByType(String companyId, DocumentType type) async {
    _log.debug(
      LogTags.repo,
      'getByType - fetching documents',
      data: {'companyId': companyId, 'type': type.name},
    );
    try {
      final result = await _db.getDocumentsByType(companyId, type);
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

  Future<List<Document>> getInvoices(String companyId) =>
      getByType(companyId, DocumentType.invoice);

  Future<List<Document>> getQuotes(String companyId) =>
      getByType(companyId, DocumentType.quote);

  Future<List<Document>> getCreditNotes(String companyId) =>
      getByType(companyId, DocumentType.creditNote);

  Future<Document?> getById(String id) async {
    _log.debug(LogTags.repo, 'getById - fetching document', data: {'id': id});
    try {
      final result = await _db.getDocumentById(id);
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

  Future<List<Document>> getFacturesFromDevis(String devisId) async {
    _log.debug(
      LogTags.repo,
      'getFacturesFromDevis - starting',
      data: {'devisId': devisId},
    );
    try {
      final result =
          (_db.select(_db.documents)..where(
                (d) =>
                    d.parentDocumentId.equals(devisId) &
                    d.type.equals(DocumentType.invoice.name),
              ))
              .get();
      _log.info(LogTags.repo, 'getFacturesFromDevis - completed');
      return result;
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'getFacturesFromDevis - failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<List<Document>> getAvoirsForDocument(String documentId) async {
    _log.debug(
      LogTags.repo,
      'getAvoirsForDocument - starting',
      data: {'documentId': documentId},
    );
    try {
      final result =
          (_db.select(_db.documents)..where(
                (d) =>
                    d.parentDocumentId.equals(documentId) &
                    d.type.equals(DocumentType.creditNote.name),
              ))
              .get();
      _log.info(LogTags.repo, 'getAvoirsForDocument - completed');
      return result;
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'getAvoirsForDocument - failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<List<DocumentLine>> getLines(String documentId) async {
    _log.debug(
      LogTags.repo,
      'getLines - fetching lines',
      data: {'documentId': documentId},
    );
    try {
      final result = await _db.getDocumentLines(documentId);
      _log.info(
        LogTags.repo,
        'getLines - completed',
        data: {'count': result.length},
      );
      return result;
    } catch (e, st) {
      _log.error(LogTags.repo, 'getLines - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> insertWithLines(
    Document document,
    List<DocumentLine> lines,
  ) async {
    _log.debug(
      LogTags.repo,
      'insertWithLines - starting',
      data: {'id': document.id, 'linesCount': lines.length},
    );
    _log.debug(
      LogTags.db,
      'INSERT - documents',
      data: {'id': document.id, 'number': document.number},
    );
    try {
      await _db.transaction(() async {
        await _db.into(_db.documents).insert(document);
        for (final line in lines) {
          _log.debug(
            LogTags.db,
            'INSERT - document_lines',
            data: {'id': line.id, 'documentId': document.id},
          );
          await _db.into(_db.documentLines).insert(line);
        }
      });
      await _syncQueue.queueInsert('documents', document.id);
      for (final line in lines) {
        await _syncQueue.queueInsert('document_lines', line.id);
      }
      _log.info(
        LogTags.repo,
        'insertWithLines - completed',
        data: {'id': document.id},
      );
    } catch (e, st) {
      _log.error(LogTags.repo, 'insertWithLines - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<Document> createFactureFromDevis(
    Document devis, {
    List<DocumentLine>? lines,
  }) async {
    _log.debug(
      LogTags.repo,
      'createFactureFromDevis - starting',
      data: {'devisId': devis.id},
    );
    try {
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
        parentDocumentType: DocumentType.quote.name,
        isConverted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      final devisLines = lines ?? await getLines(devis.id);
      final newLines = devisLines
          .map(
            (line) => DocumentLine(
              id: const Uuid().v4(),
              documentId: newId,
              itemId: line.itemId,
              description: line.description,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
              taxId: line.taxId,
              tvaRate: line.tvaRate,
              total: line.total,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              syncStatus: 'pending',
            ),
          )
          .toList();

      await insertWithLines(facture, newLines);

      await (_db.update(_db.documents)).replace(
        devis.copyWith(
          isConverted: true,
          status: DocumentStatus.draft,
          updatedAt: DateTime.now(),
        ),
      );

      _log.info(
        LogTags.repo,
        'createFactureFromDevis - completed',
        data: {'id': newId},
      );
      return facture;
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'createFactureFromDevis - failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<Document> createAvoirFromDocument(
    Document document, {
    List<DocumentLine>? lines,
    String? refundReason,
    double? refundAmount,
  }) async {
    _log.debug(
      LogTags.repo,
      'createAvoirFromDocument - starting',
      data: {
        'documentId': document.id,
        'refundReason': refundReason,
        'refundAmount': refundAmount,
      },
    );
    try {
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
        parentDocumentType: document.type.name,
        refundReason: refundReason,
        isConverted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      final documentLines = lines ?? await getLines(document.id);
      final newLines = documentLines
          .map(
            (line) => DocumentLine(
              id: const Uuid().v4(),
              documentId: newId,
              itemId: line.itemId,
              description: line.description,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
              taxId: line.taxId,
              tvaRate: line.tvaRate,
              total: line.total * ratio,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              syncStatus: 'pending',
            ),
          )
          .toList();

      await insertWithLines(avoir, newLines);
      _log.info(
        LogTags.repo,
        'createAvoirFromDocument - completed',
        data: {'id': newId},
      );
      return avoir;
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'createAvoirFromDocument - failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<void> update(Document document) async {
    _log.debug(LogTags.repo, 'update - starting', data: {'id': document.id});
    _log.debug(
      LogTags.db,
      'UPDATE - documents',
      data: {'id': document.id, 'status': document.status.name},
    );
    try {
      await (_db.update(
        _db.documents,
      )..where((d) => d.id.equals(document.id))).write(
        DocumentsCompanion(
          status: Value(document.status),
          issueDate: Value(document.issueDate),
          dueDate: Value(document.dueDate),
          subtotal: Value(document.subtotal),
          tvaAmount: Value(document.tvaAmount),
          total: Value(document.total),
          notes: Value(document.notes),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      await _syncQueue.queueUpdate('documents', document.id);
      _log.info(LogTags.repo, 'update - completed', data: {'id': document.id});
    } catch (e, st) {
      _log.error(
        LogTags.repo,
        'update - failed',
        error: e,
        stack: st,
        data: {'id': document.id},
      );
      rethrow;
    }
  }

  Future<void> updateLines(String documentId, List<DocumentLine> lines) async {
    _log.debug(
      LogTags.repo,
      'updateLines - starting',
      data: {'documentId': documentId, 'linesCount': lines.length},
    );

    try {
      await _db.transaction(() async {
        await (_db.delete(
          _db.documentLines,
        )..where((dl) => dl.documentId.equals(documentId))).go();

        for (final line in lines) {
          final lineToInsert = DocumentLine(
            id: line.id,
            documentId: documentId,
            itemId: line.itemId,
            description: line.description,
            quantity: line.quantity,
            unitPrice: line.unitPrice,
            taxId: line.taxId,
            tvaRate: line.tvaRate,
            total: line.total,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncStatus: 'pending',
          );
          _log.debug(
            LogTags.db,
            'INSERT - document_lines',
            data: {'id': line.id, 'documentId': documentId},
          );
          await _db.into(_db.documentLines).insert(lineToInsert);
        }
      });

      await _syncQueue.queueUpdate('documents', documentId);
      for (final line in lines) {
        await _syncQueue.queueInsert('document_lines', line.id);
      }
      _log.info(
        LogTags.repo,
        'updateLines - completed',
        data: {'documentId': documentId},
      );
    } catch (e, st) {
      _log.error(LogTags.repo, 'updateLines - failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    _log.debug(LogTags.repo, 'delete - starting', data: {'id': id});
    _log.debug(LogTags.db, 'DELETE - documents', data: {'id': id});
    try {
      final lines = await getLines(id);
      for (final line in lines) {
        await _syncQueue.queueDelete('document_lines', line.id);
      }
      await _syncQueue.queueDelete('documents', id);
      await _db.transaction(() async {
        await (_db.delete(
          _db.documentLines,
        )..where((dl) => dl.documentId.equals(id))).go();
        await (_db.delete(_db.documents)..where((d) => d.id.equals(id))).go();
      });
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
    final id = const Uuid().v4();
    _log.debug(LogTags.repo, 'generateId - generated', data: {'id': id});
    return id;
  }

  Future<String> generateNumber(String companyId, DocumentType type) async {
    final year = DateTime.now().year;
    final docs = await getByType(companyId, type);
    final count = docs.length + 1;
    final prefix = switch (type) {
      DocumentType.invoice => 'FAC',
      DocumentType.quote => 'DEV',
      DocumentType.creditNote => 'AVR',
    };
    final number = '$prefix-$year-${count.toString().padLeft(4, '0')}';
    _log.debug(
      LogTags.repo,
      'generateNumber - generated',
      data: {'number': number},
    );
    return number;
  }
}
