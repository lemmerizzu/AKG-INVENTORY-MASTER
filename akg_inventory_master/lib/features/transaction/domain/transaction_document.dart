enum MutationCode { inbound, outbound, other }
enum InputMode { bulk, reserve }
enum DocStatus { draft, completed, void_ }

/// Transaction document header — aligned 1:1 with `transaction_documents`.
class TransactionDocument {
  final String id;
  final String sysDocNumber;
  final String? poReference;
  final MutationCode mutation;
  final InputMode inputMode;
  final String customerId;
  final DateTime transactionDate;
  final String shippingAddress;
  final DocStatus status;
  final double? geoLatitude;
  final double? geoLongitude;
  final DateTime? deviceCreatedAt;
  final DateTime? syncedAt;
  final String? createdBy;

  const TransactionDocument({
    required this.id,
    required this.sysDocNumber,
    this.poReference,
    required this.mutation,
    this.inputMode = InputMode.bulk,
    required this.customerId,
    required this.transactionDate,
    this.shippingAddress = '',
    this.status = DocStatus.draft,
    this.geoLatitude,
    this.geoLongitude,
    this.deviceCreatedAt,
    this.syncedAt,
    this.createdBy,
  });

  static const _mutMap = {
    'IN': MutationCode.inbound,
    'OUT': MutationCode.outbound,
    'OTHER': MutationCode.other,
  };
  static const _mutRev = {
    MutationCode.inbound: 'IN',
    MutationCode.outbound: 'OUT',
    MutationCode.other: 'OTHER',
  };
  static const _statusMap = {
    'DRAFT': DocStatus.draft,
    'COMPLETED': DocStatus.completed,
    'VOID': DocStatus.void_,
  };
  static const _statusRev = {
    DocStatus.draft: 'DRAFT',
    DocStatus.completed: 'COMPLETED',
    DocStatus.void_: 'VOID',
  };
  static const _modeMap = {
    'BULK': InputMode.bulk,
    'RESERVE': InputMode.reserve,
  };
  static const _modeRev = {
    InputMode.bulk: 'BULK',
    InputMode.reserve: 'RESERVE',
  };

  factory TransactionDocument.fromJson(Map<String, dynamic> json) =>
      TransactionDocument(
        id: json['id'] as String,
        sysDocNumber: json['sys_doc_number'] as String,
        poReference: json['po_reference'] as String?,
        mutation: _mutMap[json['mutation']] ?? MutationCode.other,
        inputMode: _modeMap[json['input_mode']] ?? InputMode.bulk,
        customerId: json['customer_id'] as String,
        transactionDate:
            DateTime.parse(json['transaction_date'] as String),
        shippingAddress: json['shipping_address'] as String? ?? '',
        status: _statusMap[json['status']] ?? DocStatus.draft,
        geoLatitude: (json['geo_latitude'] as num?)?.toDouble(),
        geoLongitude: (json['geo_longitude'] as num?)?.toDouble(),
        deviceCreatedAt: json['device_created_at'] != null
            ? DateTime.parse(json['device_created_at'] as String)
            : null,
        syncedAt: json['synced_at'] != null
            ? DateTime.parse(json['synced_at'] as String)
            : null,
        createdBy: json['created_by'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sys_doc_number': sysDocNumber,
        'po_reference': poReference,
        'mutation': _mutRev[mutation],
        'input_mode': _modeRev[inputMode],
        'customer_id': customerId,
        'transaction_date': transactionDate.toIso8601String(),
        'shipping_address': shippingAddress,
        'status': _statusRev[status],
        'geo_latitude': geoLatitude,
        'geo_longitude': geoLongitude,
        'device_created_at': deviceCreatedAt?.toIso8601String(),
        'created_by': createdBy,
      };
}

/// Individual ledger line — aligned 1:1 with `inventory_ledger`.
/// IMMUTABLE by design: no update/delete, only insert.
class InventoryLedgerEntry {
  final String id;
  final String documentId;
  final String? cylinderBarcode;
  final String? itemId;
  final bool isBarcodeAudited;
  final int qty;
  final int? rentalPrice;
  final DateTime? createdAt;

  const InventoryLedgerEntry({
    required this.id,
    required this.documentId,
    this.cylinderBarcode,
    this.itemId,
    this.isBarcodeAudited = true,
    required this.qty,
    this.rentalPrice,
    this.createdAt,
  });

  factory InventoryLedgerEntry.fromJson(Map<String, dynamic> json) =>
      InventoryLedgerEntry(
        id: json['id'] as String,
        documentId: json['document_id'] as String,
        cylinderBarcode: json['cylinder_barcode'] as String?,
        itemId: json['item_id'] as String?,
        isBarcodeAudited: (json['is_barcode_audited'] as int? ?? 1) == 1,
        qty: json['qty'] as int,
        rentalPrice: (json['rental_price'] as num?)?.toInt(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'document_id': documentId,
        'cylinder_barcode': cylinderBarcode,
        'item_id': itemId,
        'is_barcode_audited': isBarcodeAudited ? 1 : 0,
        'qty': qty,
        'rental_price': rentalPrice,
      };
}
