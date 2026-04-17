import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:num2text/num2text.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/local/tables/tables.dart';
import 'package:konta/domain/services/log_service.dart';

class PdfService {
  static final _num2text = Num2Text();
  static final LogService _log = LogService();

  static PdfColor _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return PdfColor.fromInt(int.parse('FF$hexCode', radix: 16));
  }

  static Future<pw.Document> generateInvoicePdf({
    required Company company,
    required String userEmail,
    required Contact customer,
    required Document invoice,
    required List<DocumentLine> items,
    required String languageCode,
    InvoiceTemplate? template,
    Uint8List? logoBytes,
  }) async {
    _log.debug(
      LogTags.service,
      'generateInvoicePdf - starting',
      data: {
        'invoiceNumber': invoice.number,
        'company': company.name,
        'customer': customer.name,
        'itemsCount': items.length,
        'total': invoice.total,
      },
    );

    final pdf = pw.Document();

    final madFr = CurrencyInfo(
      mainUnitSingular: 'dirham',
      mainUnitPlural: 'dirhams',
      subUnitSingular: 'centime',
      subUnitPlural: 'centimes',
    );
    final madAr = CurrencyInfo(
      mainUnitSingular: 'درهم',
      mainUnitPlural: 'دراهم',
      subUnitSingular: 'سنتيم',
      subUnitPlural: 'سنتيمات',
    );

    _num2text.setLang(Lang.FR);
    final amountInWordsFr = _num2text.convert(
      invoice.total,
      options: FrOptions(currency: true, currencyInfo: madFr),
    );
    _num2text.setLang(Lang.AR);
    final amountInWordsAr = _num2text.convert(
      invoice.total,
      options: ArOptions(currency: true, currencyInfo: madAr),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          final primaryColor = template != null
              ? _hexToColor(template.primaryColor)
              : PdfColor.fromInt(0xFF2563EB);

          final logoWidget = logoBytes != null
              ? pw.Image(pw.MemoryImage(logoBytes), width: 80)
              : null;

          final headerContent = <pw.Widget>[
            if (template?.headerStyle == HeaderStyle.logoCenter &&
                logoBytes != null)
              pw.Center(child: pw.Image(pw.MemoryImage(logoBytes), width: 100)),
            if (template?.headerStyle == HeaderStyle.logoCenter &&
                logoBytes != null)
              pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (template?.headerStyle == HeaderStyle.logoLeft &&
                        logoBytes != null)
                      logoWidget!,
                    pw.Text(
                      company.name,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(company.address ?? ''),
                    pw.Text('Tél: ${company.phone ?? ''}'),
                    pw.Text('Email: $userEmail'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('ICE: ${company.ice ?? ''}'),
                    pw.Text('IF: ${company.ifNumber ?? ''}'),
                    pw.Text('RC: ${company.rc ?? ''}'),
                    pw.Text('CNSS: ${company.cnss ?? ''}'),
                    if (template?.headerStyle == HeaderStyle.logoRight &&
                        logoBytes != null)
                      pw.SizedBox(height: 30),
                    if (template?.headerStyle == HeaderStyle.logoRight &&
                        logoBytes != null)
                      logoWidget!,
                  ],
                ),
              ],
            ),
          ];

          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: headerContent,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Client:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(customer.name),
                    if (customer.address != null) pw.Text(customer.address!),
                    if (customer.ice != null &&
                        (template?.showCustomerIce ?? true))
                      pw.Text('ICE: ${customer.ice}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      invoice.type == DocumentType.invoice
                          ? 'FACTURE'
                          : 'DEVIS',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('N°: ${invoice.number}'),
                    pw.Text('Date: ${_formatDate(invoice.issueDate)}'),
                    if (invoice.dueDate != null &&
                        (template?.showPaymentTerms ?? true))
                      pw.Text('Échéance: ${_formatDate(invoice.dueDate!)}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: primaryColor),
                  children: [
                    _buildTableCell('Description', isHeader: true),
                    _buildTableCell('Qté', isHeader: true),
                    _buildTableCell('P.U. HT', isHeader: true),
                    _buildTableCell('TVA %', isHeader: true),
                    _buildTableCell('Total', isHeader: true),
                  ],
                ),
                ...items.map(
                  (item) => pw.TableRow(
                    children: [
                      _buildTableCell(item.description),
                      _buildTableCell(item.quantity.toString()),
                      _buildTableCell(
                        '${item.unitPrice.toStringAsFixed(2)} MAD',
                      ),
                      _buildTableCell('${item.tvaRate}%'),
                      _buildTableCell('${item.total.toStringAsFixed(2)} MAD'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('Total HT: ', style: const pw.TextStyle()),
                      pw.Text(
                        '${invoice.subtotal.toStringAsFixed(2)} MAD',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('TVA: ', style: const pw.TextStyle()),
                      pw.Text(
                        '${invoice.tvaAmount.toStringAsFixed(2)} MAD',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'Total TTC: ',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      pw.Text(
                        '${invoice.total.toStringAsFixed(2)} MAD',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Arrêtée la présente facture à la somme de:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(amountInWordsFr),
                  pw.SizedBox(height: 4),
                  pw.Text(amountInWordsAr, style: const pw.TextStyle()),
                ],
              ),
            ),
            if (template?.footerText != null &&
                template!.footerText!.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                template.footerText!,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                textAlign: pw.TextAlign.center,
              ),
            ],
            if (company.isAutoEntrepreneur) ...[
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFFEF3C7),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  'TVA applicable au taux de 1%, article 91 du CGI\n'
                  'الضريبة على القيمة المضافة بنسبة 1%، المادة 91 من المدونة العامة للضرائب',
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ];
        },
      ),
    );

    _log.info(LogTags.service, 'generateInvoicePdf - completed');
    return pdf;
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
