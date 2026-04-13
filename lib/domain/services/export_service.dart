import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/domain/services/pdf_service.dart';
import 'package:konta/data/repositories/invoice_repository.dart';
import 'package:konta/data/repositories/expense_repository.dart';
import 'package:konta/data/repositories/customer_repository.dart';
import 'package:konta/core/utils/logger.dart';

class ExportService {
  final InvoiceRepository _invoiceRepo;
  final ExpenseRepository _expenseRepo;
  final CustomerRepository _customerRepo;

  ExportService(this._invoiceRepo, this._expenseRepo, this._customerRepo);

  Future<String> exportMonthlyBundle({
    required Profile company,
    required int year,
    required int month,
  }) async {
    Logger.method('ExportService', 'exportMonthlyBundle', {
      'year': year,
      'month': month,
    });
    final directory = await getTemporaryDirectory();
    final exportDir = Directory(
      '${directory.path}/export_${year}_${month.toString().padLeft(2, '0')}',
    );
    if (exportDir.existsSync()) {
      Logger.debug('Deleting existing export directory', tag: 'EXPORT');
      exportDir.deleteSync(recursive: true);
    }
    exportDir.createSync(recursive: true);
    Logger.debug('Created export directory: ${exportDir.path}', tag: 'EXPORT');

    final invoices = await _invoiceRepo.getByType(company.id, 'invoice');
    final monthInvoices = invoices.where((i) {
      final isSameYear = i.issueDate.year == year;
      final isSameMonth = i.issueDate.month == month;
      return isSameYear && isSameMonth;
    }).toList();
    Logger.debug(
      'Found ${monthInvoices.length} invoices for $year-$month',
      tag: 'EXPORT',
    );

    final expenses = await _expenseRepo.getByMonth(company.id, year, month);
    Logger.debug(
      'Found ${expenses.length} expenses for $year-$month',
      tag: 'EXPORT',
    );

    Logger.ui('ExportService', 'CREATE_SALES_EXCEL');
    final salesExcel = await _createSalesExcel(
      company: company,
      invoices: monthInvoices,
    );
    final salesFile = File(
      '${exportDir.path}/ventes_${year}_${month.toString().padLeft(2, '0')}.xlsx',
    );
    salesFile.writeAsBytesSync(salesExcel);
    Logger.success('Created sales Excel: ${salesFile.path}', tag: 'EXPORT');

    Logger.ui('ExportService', 'CREATE_EXPENSES_EXCEL');
    final expensesExcel = await _createExpensesExcel(expenses: expenses);
    final expensesFile = File(
      '${exportDir.path}/depenses_${year}_${month.toString().padLeft(2, '0')}.xlsx',
    );
    expensesFile.writeAsBytesSync(expensesExcel);
    Logger.success(
      'Created expenses Excel: ${expensesFile.path}',
      tag: 'EXPORT',
    );

    Logger.ui('ExportService', 'GENERATE_PDFS');
    for (final invoice in monthInvoices) {
      final customer = await _customerRepo.getById(invoice.customerId);
      if (customer == null) {
        Logger.warning(
          'Customer not found for invoice: ${invoice.id}',
          tag: 'EXPORT',
        );
        continue;
      }
      final items = await _invoiceRepo.getItems(invoice.id);
      final pdf = await PdfService.generateInvoicePdf(
        company: company,
        customer: customer,
        invoice: invoice,
        items: items,
        languageCode: 'fr',
      );
      final pdfBytes = await pdf.save();
      final pdfFile = File('${exportDir.path}/${invoice.number}.pdf');
      pdfFile.writeAsBytesSync(pdfBytes);
      Logger.debug('Generated PDF: ${pdfFile.path}', tag: 'EXPORT');
    }

    Logger.ui('ExportService', 'COPY_RECEIPTS');
    for (final expense in expenses) {
      if (expense.receiptUrl != null && expense.receiptUrl!.isNotEmpty) {
        final receiptFile = File(expense.receiptUrl!);
        if (receiptFile.existsSync()) {
          final destFile = File('${exportDir.path}/recu_${expense.id}.jpg');
          receiptFile.copySync(destFile.path);
          Logger.debug('Copied receipt: ${destFile.path}', tag: 'EXPORT');
        }
      }
    }

    Logger.success('Export complete: ${exportDir.path}', tag: 'EXPORT');
    return exportDir.path;
  }

  Future<List<int>> _createSalesExcel({
    required Profile company,
    required List<Invoice> invoices,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Ventes'];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      'N° Facture',
    );
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Date');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Client');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue(
      'ICE Client',
    );
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Total HT');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('TVA');
    sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue(
      'Total TTC',
    );

    for (var i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];
      final customer = await _customerRepo.getById(invoice.customerId);
      final row = i + 2;

      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        invoice.number,
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(
        '${invoice.issueDate.day.toString().padLeft(2, '0')}/${invoice.issueDate.month.toString().padLeft(2, '0')}/${invoice.issueDate.year}',
      );
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(
        customer?.name ?? '',
      );
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(
        customer?.ice ?? '',
      );
      sheet.cell(CellIndex.indexByString('E$row')).value = DoubleCellValue(
        invoice.subtotal,
      );
      sheet.cell(CellIndex.indexByString('F$row')).value = DoubleCellValue(
        invoice.tvaAmount,
      );
      sheet.cell(CellIndex.indexByString('G$row')).value = DoubleCellValue(
        invoice.total,
      );
    }

    return excel.encode()!;
  }

  Future<List<int>> _createExpensesExcel({
    required List<Expense> expenses,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Dépenses'];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Date');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
      'Catégorie',
    );
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
      'Description',
    );
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Montant');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('TVA');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue(
      'Déductible',
    );

    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final row = i + 2;

      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(
        '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}',
      );
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(
        expense.category,
      );
      sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(
        expense.description ?? '',
      );
      sheet.cell(CellIndex.indexByString('D$row')).value = DoubleCellValue(
        expense.amount,
      );
      sheet.cell(CellIndex.indexByString('E$row')).value = DoubleCellValue(
        expense.tvaAmount,
      );
      sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(
        expense.isDeductible ? 'Oui' : 'Non',
      );
    }

    return excel.encode()!;
  }

  Future<void> shareExport(String directoryPath) async {
    Logger.method('ExportService', 'shareExport', {'path': directoryPath});
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      Logger.warning('Directory does not exist: $directoryPath', tag: 'EXPORT');
      return;
    }

    final files = dir.listSync().whereType<File>().toList();
    if (files.isEmpty) {
      Logger.warning('No files to share', tag: 'EXPORT');
      return;
    }

    Logger.debug('Sharing ${files.length} files', tag: 'EXPORT');
    await Share.shareXFiles(
      files.map((f) => XFile(f.path)).toList(),
      subject: 'Export Konta',
    );
    Logger.success('Share completed', tag: 'EXPORT');
  }
}
