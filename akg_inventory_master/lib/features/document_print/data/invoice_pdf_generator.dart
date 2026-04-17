import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/document_template.dart';

/// Generates PDF documents from [DocumentTemplate] + [DocumentPrintData].
/// The template controls layout/labels; the data fills in dynamic values.
class InvoicePdfGenerator {
  final DocumentTemplate template;
  final DocumentPrintData data;

  InvoicePdfGenerator({required this.template, required this.data});

  static final _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 2);

  String _rp(int amount) => _currencyFormat.format(amount);
  String _date(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Future<pw.Document> generate() async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 16),
            _buildDocumentInfo(),
            pw.SizedBox(height: 12),
            _buildItemTable(),
            pw.SizedBox(height: 8),
            _buildFinancialSummary(),
            pw.Spacer(),
            _buildSignatureAndNotes(),
            pw.SizedBox(height: 20),
            _buildBankFooter(),
          ],
        ),
      ),
    );

    return pdf;
  }

  // ── Header: Company + Customer ────────────────────────────────

  pw.Widget _buildHeader() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: Company
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                template.companyName,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#2E1065'),
                ),
              ),
              pw.Text(
                template.companyLegalName,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(template.companyAddress,
                  style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Telp  : ${template.companyPhone}',
                  style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Email : ${template.companyEmail}',
                  style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),
        // Right: Customer
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Kepada Yth :',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text(
                data.customerName,
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(data.customerAddress,
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Document Info Block ───────────────────────────────────────

  pw.Widget _buildDocumentInfo() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            template.documentTitle,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (template.showNPWPField)
                    _infoRow('NPWP', data.npwp ?? ''),
                  _infoRow('ID Pelanggan', data.customerId),
                  if (template.showPOField)
                    _infoRow('No. PO', data.poNumber ?? ''),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                   _infoRow('No. Faktur', data.documentNumber),
                   _infoRow('Tgl. Faktur', _date(data.documentDate)),
                   _infoRow('Batas Pembayaran', data.dueDate != null ? _date(data.dueDate!) : '-'),
                 ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          ),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Item Table ────────────────────────────────────────────────

  pw.Widget _buildItemTable() {
    final headers = [
      'No',
      'Nama Barang',
      if (template.showUnitColumn) 'Satuan',
      'Kuantitas',
      'Harga Satuan',
      'Jumlah',
    ];

    final rows = data.lineItems.map((item) {
      return [
        '${item.lineNumber}',
        item.itemName,
        if (template.showUnitColumn) item.unit,
        '${item.qty}',
        'Rp   ${_rp(item.unitPrice)}',
        'Rp   ${_rp(item.lineTotal)}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      border: const pw.TableBorder(
        top: pw.BorderSide(width: 0.5),
        bottom: pw.BorderSide(width: 0.5),
        horizontalInside: pw.BorderSide(width: 0.25, color: PdfColors.grey400),
      ),
      headerStyle:
          pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        0: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(4),
        if (template.showUnitColumn) 2: const pw.FixedColumnWidth(50),
      },
    );
  }

  // ── Financial Summary ─────────────────────────────────────────

  pw.Widget _buildFinancialSummary() {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 300,
        child: pw.Column(
          children: [
            _summaryRow(template.labelSubtotal, data.subtotal),
            _summaryRow(template.labelDiscount, data.discount, show: data.discount > 0),
            _summaryRow(template.labelDownPayment, data.downPayment, show: data.downPayment > 0),
            _summaryRow(template.labelTaxBase, data.taxBase, show: data.taxBase > 0),
            _summaryRow(template.labelTax, data.taxAmount, show: data.taxAmount > 0),
            pw.Divider(thickness: 0.5),
            _summaryRow(template.labelGrandTotal, data.grandTotal, bold: true),
          ],
        ),
      ),
    );
  }

  pw.Widget _summaryRow(String label, int amount,
      {bool bold = false, bool show = true}) {
    if (!show) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text('Rp   ${_rp(amount)}',
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  // ── Signature + Notes ─────────────────────────────────────────

  pw.Widget _buildSignatureAndNotes() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: notes
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Catatan :',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
              if (template.showPeriodNotes &&
                  data.periodStart != null)
                pw.Text(
                  'Pengiriman periode\n${data.periodStart} - ${data.periodEnd}',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              if (template.showReferenceNotes &&
                  data.referenceNumbers.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Referensi :', style: const pw.TextStyle(fontSize: 8)),
                pw.Text(data.referenceNumbers.join(' '),
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ],
          ),
        ),
        // Right: signature
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                '${template.signatoryCity}, ${DateFormat('dd MMMM yyyy', 'id_ID').format(data.documentDate)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 50), // Signature space
              pw.Text(
                template.signatoryName,
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
              if (template.signatoryTitle != null)
                pw.Text(template.signatoryTitle!,
                    style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bank Footer ───────────────────────────────────────────────

  pw.Widget _buildBankFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Text(template.footerNote,
            style: const pw.TextStyle(fontSize: 7)),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 7,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: template.bankAccounts
                    .map(
                      (bank) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 40,
                              child: pw.Text(bank.bankName,
                                  style: pw.TextStyle(
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Text(
                              '${bank.accountNumber} (${bank.accountHolder})',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                '${template.customerServiceLabel}     ${template.customerServiceContact}',
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
