import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/document_template.dart';

/// Generates a "Surat Jalan" (Delivery Order) PDF.
/// Layout follows the Excel design provided by the user.
class SuratJalanPdfGenerator {
  final DocumentTemplate template;
  final DocumentPrintData data;

  SuratJalanPdfGenerator({required this.template, required this.data});

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
        margin: const pw.EdgeInsets.all(35),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 12),
            _buildVehicleAndDriverInfo(),
            pw.SizedBox(height: 12),
            _buildItemTable(),
            pw.SizedBox(height: 16),
            _buildRulesAndConditions(),
            pw.Spacer(),
            _buildSignatureSection(),
          ],
        ),
      ),
    );

    return pdf;
  }

  // ── Header: Company + Document Title + Customer ──────────────────

  pw.Widget _buildHeader() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: Company Info
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                template.companyName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#2E1065'),
                ),
              ),
              pw.Text(
                template.companyLegalName,
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(template.companyAddress, style: const pw.TextStyle(fontSize: 7)),
              pw.Text('Telp : ${template.companyPhone}', style: const pw.TextStyle(fontSize: 7)),
              pw.Text('Email : ${template.companyEmail}', style: const pw.TextStyle(fontSize: 7)),
            ],
          ),
        ),
        // Right: Title & Customer
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                template.documentTitle,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: 180,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Kepada Yth :', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(
                      data.customerName,
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(data.customerAddress, style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Vehicle & Driver Info ───────────────────────────────────────

  pw.Widget _buildVehicleAndDriverInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              children: [
                _infoRow('Nomor Dokumen', data.documentNumber),
                _infoRow('Tanggal', _date(data.documentDate)),
                if (data.poNumber != null) _infoRow('Nomor PO', data.poNumber!),
              ],
            ),
          ),
          pw.VerticalDivider(width: 1, color: PdfColors.grey400),
          pw.Expanded(
            child: pw.Column(
              children: [
                _infoRow('No. Polisi', data.policeNumber ?? '-'),
                _infoRow('Driver', data.driverName ?? '-'),
                _infoRow('Telp. Driver', data.driverPhone ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 80, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8))),
          pw.Text(':', style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Item Table (Simplified, No Prices) ─────────────────────────

  pw.Widget _buildItemTable() {
    final headers = ['No', 'Nama Barang', if (template.showUnitColumn) 'Satuan', 'Kuantitas'];

    final rows = data.lineItems.map((item) {
      return [
        '${item.lineNumber}',
        item.itemName,
        if (template.showUnitColumn) item.unit,
        '${item.qty}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        0: pw.Alignment.center,
        3: pw.Alignment.center,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        if (template.showUnitColumn) 2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(60),
      },
    );
  }

  // ── Rules and Conditions Block ──────────────────────────────────

  pw.Widget _buildRulesAndConditions() {
    if (template.rulesText.isEmpty) return pw.SizedBox.shrink();
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PERATURAN PENYERAHAN GAS DAN PEMINJAMAN BOTOL',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            template.rulesText,
            style: const pw.TextStyle(fontSize: 6.5),
          ),
        ],
      ),
    );
  }

  // ── Signature Section (3 Columns) ──────────────────────────────

  pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signatureBox('Diterima Oleh,', ''),
        _signatureBox('Pengangkut,', data.driverName ?? ''),
        _signatureBox('Hormat Kami,', template.signatoryName),
      ],
    );
  }

  pw.Widget _signatureBox(String label, String name) {
    return pw.Container(
      width: 150,
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 40),
          pw.Text(
            name.isNotEmpty ? '( $name )' : '( ____________________ )',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
