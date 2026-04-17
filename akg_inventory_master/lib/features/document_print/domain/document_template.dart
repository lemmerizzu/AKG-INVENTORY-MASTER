/// Configurable document template — all fields editable by user.
/// Stored per-company in Supabase `document_templates` table.
class DocumentTemplate {
  final String id;
  final String templateName; // e.g., "Faktur Penjualan", "Surat Jalan"

  // ── Company Header ───────────────────────────────────────────
  final String companyName;        // "Atmakarsa"
  final String companyLegalName;   // "PT Atma Karsa Gasindo"
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String? companyLogoPath;   // Local or remote URL

  // ── Document Title & Numbering ───────────────────────────────
  final String documentTitle;      // "FAKTUR PENJUALAN", "SURAT JALAN"
  final String numberPrefix;       // e.g., "INV-", "DO-"
  final String numberFormat;       // e.g., "{PREFIX}{YYMM}{SEQ}" → INV-2603001

  // ── Financial Summary Labels ─────────────────────────────────
  final String labelSubtotal;      // "Harga Jual"
  final String labelDiscount;      // "Potongan Harga"
  final String labelDownPayment;   // "Uang Muka Diterima"
  final String labelTaxBase;       // "Dasar Pengenaan Pajak"
  final String labelTax;           // "PPN 11%"
  final String labelGrandTotal;    // "Jumlah yang Harus Dibayarkan"
  final double taxPercentage;      // 0.11

  // ── Bank Accounts ────────────────────────────────────────────
  final List<BankAccount> bankAccounts;

  // ── Footer ───────────────────────────────────────────────────
  final String footerNote;         // "Mohon sertakan nomor faktur..."
  final String customerServiceLabel;
  final String customerServiceContact; // "WA 081333292028"

  // ── Signatory ────────────────────────────────────────────────
  final String signatoryCity;      // "Sidoarjo"
  final String signatoryName;      // "Wahyono"
  final String? signatoryTitle;    // Optional job title

  // ── Table Column Visibility & Formatting ─────────────────────
  final bool showUnitColumn;       // "Satuan" column
  final bool showPOField;          // No. PO field
  final bool showNPWPField;        // NPWP field
  final bool showPeriodNotes;      // "Pengiriman periode"
  final bool showReferenceNotes;   // "Referensi: ..."
  final bool showPrices;           // Show prices & totals (False for DO)
  final bool showDriverInfo;       // Show Driver & Vehicle Plate
  
  // ── Text Blocks ──────────────────────────────────────────────
  final String rulesText;          // Long T&C block for Surat Jalan

  const DocumentTemplate({
    required this.id,
    required this.templateName,
    required this.companyName,
    required this.companyLegalName,
    required this.companyAddress,
    required this.companyPhone,
    required this.companyEmail,
    this.companyLogoPath,
    required this.documentTitle,
    this.numberPrefix = '',
    this.numberFormat = '{SEQ}',
    this.labelSubtotal = 'Harga Jual',
    this.labelDiscount = 'Potongan Harga',
    this.labelDownPayment = 'Uang Muka Diterima',
    this.labelTaxBase = 'Dasar Pengenaan Pajak',
    this.labelTax = 'PPN 11%',
    this.labelGrandTotal = 'Jumlah yang Harus Dibayarkan',
    this.taxPercentage = 0.11,
    this.bankAccounts = const [],
    this.footerNote = 'Mohon sertakan nomor faktur pada berita/note.',
    this.customerServiceLabel = 'Customer Service :',
    this.customerServiceContact = '',
    this.signatoryCity = '',
    this.signatoryName = '',
    this.signatoryTitle,
    this.showUnitColumn = true,
    this.showPOField = true,
    this.showNPWPField = true,
    this.showPeriodNotes = true,
    this.showReferenceNotes = true,
    this.showPrices = true,
    this.showDriverInfo = false,
    this.rulesText = '',
  });

  /// Default AKG template (pre-filled from user's existing invoice)
  factory DocumentTemplate.akgDefault() => const DocumentTemplate(
        id: 'default-faktur',
        templateName: 'Faktur Penjualan',
        companyName: 'Atmakarsa',
        companyLegalName: 'PT Atma Karsa Gasindo',
        companyAddress:
            'Jl. Parengan Kali 19, Parengan, Kraton, Kec. Krian, Kab. Sidoarjo, Jawa Timur',
        companyPhone: '085655863676',
        companyEmail: 'atmakarsa.id@gmail.com',
        documentTitle: 'FAKTUR PENJUALAN',
        numberPrefix: '',
        numberFormat: '{SEQ}',
        taxPercentage: 0.11,
        bankAccounts: [
          BankAccount(bankName: 'BRI', accountNumber: '055301001926309', accountHolder: 'Atma Karsa Gasindo'),
          BankAccount(bankName: 'BNI', accountNumber: '1895607235', accountHolder: 'Atma Karsa Gasindo'),
          BankAccount(bankName: 'BCA', accountNumber: '1841622478', accountHolder: 'Rizki Kurniawan'),
        ],
        footerNote:
            'Mohon sertakan nomor faktur pada berita/note.\nPembayaran sah apabila terdapat bukti transfer ke :',
        customerServiceLabel: 'Customer Service :',
        customerServiceContact: 'WA  081333292028',
        signatoryCity: 'Sidoarjo',
        signatoryName: 'Wahyono',
      );

  factory DocumentTemplate.suratJalanDefault() => const DocumentTemplate(
        id: 'default-sj',
        templateName: 'Surat Jalan',
        companyName: 'Atmakarsa',
        companyLegalName: 'PT Atma Karsa Gasindo',
        companyAddress:
            'Jl. Parengan Kali 19, Parengan, Kraton, Kec. Krian, Kab. Sidoarjo, Jawa Timur',
        companyPhone: '085655863676',
        companyEmail: 'atmakarsa.id@gmail.com',
        documentTitle: 'SURAT JALAN',
        numberPrefix: 'SJ-',
        numberFormat: '{SEQ}',
        showPrices: false,
        showDriverInfo: true,
        showPOField: true,
        showNPWPField: false,
        showPeriodNotes: false,
        signatoryCity: 'Sidoarjo',
        signatoryName: 'Rizki Kurniawan',
        rulesText: '''PERATURAN PENYERAHAN GAS DAN PEMINJAMAN BOTOL
1. Pelanggan wajib memeriksa botol pada waktu menerima dan pada waktu mengembalikan botol kosong bersama petugas pengiriman.
2. Botol berisi yang sudah diterima baik, tidak dapat dikembalikan/diklaim mengenai tekanan/isinya, kecuali memang terdapat kebocoran botol dan lain lain oleh pihak PT Atma Karsa Gasindo.
3. Selama dalam waktu peminjaman, untuk setiap (1) kali periode pengisian, botol harus dikembalikan selambat-lambatnya 60 (enam puluh) hari sejak tanggal penyerahan. Keterlambatan pengembalian botol akan dikenakan tambahan biaya sewa.
4. Pelanggan tidak diperkenankan memodifikasi isi dan tampilan botol; memperjual belikan kembali botol; dipinjamkan dan dipindah-tangankan hak milik kepada pihak lain.
5. Pelanggan bertanggung jawab terhadap botol yang diterimanya/dipinjamnya. Apabila dalam waktu 3 (tiga) bulan sejak tanggal penyerahan belum dikembalikan, maka botol dinyatakan hilang dan pelanggan wajib membayar ganti rugi tunai.''',
      );

  factory DocumentTemplate.fromJson(Map<String, dynamic> json) =>
      DocumentTemplate(
        id: json['id'] as String,
        templateName: json['template_name'] as String,
        companyName: json['company_name'] as String,
        companyLegalName: json['company_legal_name'] as String,
        companyAddress: json['company_address'] as String,
        companyPhone: json['company_phone'] as String,
        companyEmail: json['company_email'] as String,
        companyLogoPath: json['company_logo_path'] as String?,
        documentTitle: json['document_title'] as String,
        numberPrefix: json['number_prefix'] as String? ?? '',
        numberFormat: json['number_format'] as String? ?? '{SEQ}',
        labelSubtotal: json['label_subtotal'] as String? ?? 'Harga Jual',
        labelDiscount: json['label_discount'] as String? ?? 'Potongan Harga',
        labelDownPayment: json['label_down_payment'] as String? ?? 'Uang Muka Diterima',
        labelTaxBase: json['label_tax_base'] as String? ?? 'Dasar Pengenaan Pajak',
        labelTax: json['label_tax'] as String? ?? 'PPN 11%',
        labelGrandTotal: json['label_grand_total'] as String? ?? 'Jumlah yang Harus Dibayarkan',
        taxPercentage: (json['tax_percentage'] as num?)?.toDouble() ?? 0.11,
        bankAccounts: (json['bank_accounts'] as List<dynamic>?)
                ?.map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        footerNote: json['footer_note'] as String? ?? '',
        customerServiceLabel: json['customer_service_label'] as String? ?? '',
        customerServiceContact: json['customer_service_contact'] as String? ?? '',
        signatoryCity: json['signatory_city'] as String? ?? '',
        signatoryName: json['signatory_name'] as String? ?? '',
        signatoryTitle: json['signatory_title'] as String?,
        showUnitColumn: json['show_unit_column'] as bool? ?? true,
        showPOField: json['show_po_field'] as bool? ?? true,
        showNPWPField: json['show_npwp_field'] as bool? ?? true,
        showPeriodNotes: json['show_period_notes'] as bool? ?? true,
        showReferenceNotes: json['show_reference_notes'] as bool? ?? true,
        showPrices: json['show_prices'] as bool? ?? true,
        showDriverInfo: json['show_driver_info'] as bool? ?? false,
        rulesText: json['rules_text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'template_name': templateName,
        'company_name': companyName,
        'company_legal_name': companyLegalName,
        'company_address': companyAddress,
        'company_phone': companyPhone,
        'company_email': companyEmail,
        'company_logo_path': companyLogoPath,
        'document_title': documentTitle,
        'number_prefix': numberPrefix,
        'number_format': numberFormat,
        'label_subtotal': labelSubtotal,
        'label_discount': labelDiscount,
        'label_down_payment': labelDownPayment,
        'label_tax_base': labelTaxBase,
        'label_tax': labelTax,
        'label_grand_total': labelGrandTotal,
        'tax_percentage': taxPercentage,
        'bank_accounts': bankAccounts.map((e) => e.toJson()).toList(),
        'footer_note': footerNote,
        'customer_service_label': customerServiceLabel,
        'customer_service_contact': customerServiceContact,
        'signatory_city': signatoryCity,
        'signatory_name': signatoryName,
        'signatory_title': signatoryTitle,
        'show_unit_column': showUnitColumn,
        'show_po_field': showPOField,
        'show_npwp_field': showNPWPField,
        'show_period_notes': showPeriodNotes,
        'show_reference_notes': showReferenceNotes,
        'show_prices': showPrices,
        'show_driver_info': showDriverInfo,
        'rules_text': rulesText,
      };

  DocumentTemplate copyWith({
    String? templateName,
    String? companyName,
    String? companyLegalName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyLogoPath,
    String? documentTitle,
    String? numberPrefix,
    String? numberFormat,
    String? labelSubtotal,
    String? labelDiscount,
    String? labelDownPayment,
    String? labelTaxBase,
    String? labelTax,
    String? labelGrandTotal,
    double? taxPercentage,
    List<BankAccount>? bankAccounts,
    String? footerNote,
    String? customerServiceLabel,
    String? customerServiceContact,
    String? signatoryCity,
    String? signatoryName,
    String? signatoryTitle,
    bool? showUnitColumn,
    bool? showPOField,
    bool? showNPWPField,
    bool? showPeriodNotes,
    bool? showReferenceNotes,
    bool? showPrices,
    bool? showDriverInfo,
    String? rulesText,
  }) =>
      DocumentTemplate(
        id: id,
        templateName: templateName ?? this.templateName,
        companyName: companyName ?? this.companyName,
        companyLegalName: companyLegalName ?? this.companyLegalName,
        companyAddress: companyAddress ?? this.companyAddress,
        companyPhone: companyPhone ?? this.companyPhone,
        companyEmail: companyEmail ?? this.companyEmail,
        companyLogoPath: companyLogoPath ?? this.companyLogoPath,
        documentTitle: documentTitle ?? this.documentTitle,
        numberPrefix: numberPrefix ?? this.numberPrefix,
        numberFormat: numberFormat ?? this.numberFormat,
        labelSubtotal: labelSubtotal ?? this.labelSubtotal,
        labelDiscount: labelDiscount ?? this.labelDiscount,
        labelDownPayment: labelDownPayment ?? this.labelDownPayment,
        labelTaxBase: labelTaxBase ?? this.labelTaxBase,
        labelTax: labelTax ?? this.labelTax,
        labelGrandTotal: labelGrandTotal ?? this.labelGrandTotal,
        taxPercentage: taxPercentage ?? this.taxPercentage,
        bankAccounts: bankAccounts ?? this.bankAccounts,
        footerNote: footerNote ?? this.footerNote,
        customerServiceLabel: customerServiceLabel ?? this.customerServiceLabel,
        customerServiceContact: customerServiceContact ?? this.customerServiceContact,
        signatoryCity: signatoryCity ?? this.signatoryCity,
        signatoryName: signatoryName ?? this.signatoryName,
        signatoryTitle: signatoryTitle ?? this.signatoryTitle,
        showUnitColumn: showUnitColumn ?? this.showUnitColumn,
        showPOField: showPOField ?? this.showPOField,
        showNPWPField: showNPWPField ?? this.showNPWPField,
        showPeriodNotes: showPeriodNotes ?? this.showPeriodNotes,
        showReferenceNotes: showReferenceNotes ?? this.showReferenceNotes,
        showPrices: showPrices ?? this.showPrices,
        showDriverInfo: showDriverInfo ?? this.showDriverInfo,
        rulesText: rulesText ?? this.rulesText,
      );
}

/// Reusable bank account entry for document footer.
class BankAccount {
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  const BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        bankName: json['bank_name'] as String,
        accountNumber: json['account_number'] as String,
        accountHolder: json['account_holder'] as String,
      );

  Map<String, dynamic> toJson() => {
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_holder': accountHolder,
      };
}

/// Data that fills into the template for a specific document instance (Invoice/DO).
class DocumentPrintData {
  final String documentNumber;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final String? npwp;
  final String? poNumber;
  final DateTime documentDate;
  final DateTime? dueDate;
  final List<DocumentLineItem> lineItems;
  final int subtotal;
  final int discount;
  final int downPayment;
  final int taxBase;
  final int taxAmount;
  final int grandTotal;
  final String? periodStart;
  final String? periodEnd;
  final List<String> referenceNumbers;
  
  // Driver Info (Specific to Surat Jalan)
  final String? driverName;
  final String? policeNumber;
  final String? driverPhone;

  const DocumentPrintData({
    required this.documentNumber,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    this.npwp,
    this.poNumber,
    required this.documentDate,
    this.dueDate,
    required this.lineItems,
    required this.subtotal,
    this.discount = 0,
    this.downPayment = 0,
    this.taxBase = 0,
    this.taxAmount = 0,
    required this.grandTotal,
    this.periodStart,
    this.periodEnd,
    this.referenceNumbers = const [],
    this.driverName,
    this.policeNumber,
    this.driverPhone,
  });
}

class DocumentLineItem {
  final int lineNumber;
  final String itemName;
  final String unit; // "Btl"
  final int qty;
  final int unitPrice;
  final int lineTotal;

  const DocumentLineItem({
    required this.lineNumber,
    required this.itemName,
    this.unit = 'Btl',
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });
}
