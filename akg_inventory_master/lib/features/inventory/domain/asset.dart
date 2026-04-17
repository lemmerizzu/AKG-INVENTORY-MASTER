/// Asset type determines the flow behavior.
enum AssetType { rent, exchange, sell }

/// Asset category for accounting classification.
enum AssetCategory { currentAsset, fixedAsset }

/// Lifecycle status of an individual asset.
enum AssetStatus {
  availableFull,
  availableEmpty,
  rented,
  sold,
  lost,
  maintenance,
  retired,
}

/// Generalized asset model — aligned 1:1 with `assets` SQL table.
/// Replaces the old CylinderAsset model.
class Asset {
  final String id;
  final String barcode;
  final String serialNumber;
  final String itemId;
  final AssetType type;
  final AssetCategory category;
  final AssetStatus status;
  final String? currentCustomerId;
  final int cycleCount;
  final String? adminNotes;
  final bool isActive;
  final DateTime? lastActionDate;
  final DateTime? createdAt;

  static const String warehouseId = 'AKGREADY';

  const Asset({
    required this.id,
    this.barcode = '',
    required this.serialNumber,
    required this.itemId,
    this.type = AssetType.rent,
    this.category = AssetCategory.currentAsset,
    this.status = AssetStatus.availableFull,
    this.currentCustomerId,
    this.cycleCount = 0,
    this.adminNotes,
    this.isActive = true,
    this.lastActionDate,
    this.createdAt,
  });

  // ── Computed Properties ──

  bool get isInWarehouse =>
      currentCustomerId == null ||
      currentCustomerId!.isEmpty ||
      currentCustomerId == warehouseId;

  bool get isBarcodeAudited {
    if (barcode.isEmpty) return false;
    final invalid = [
      'no barcode',
      'nobarcode',
      'not valid',
      'not asigned yet',
      '-',
      'bas',
    ];
    final lower = barcode.toLowerCase().trim();
    if (invalid.contains(lower)) return false;
    if (lower.startsWith('di alihkan')) return false;
    return true;
  }

  bool get requiresBarcode => type == AssetType.rent;

  // ── Serialization ──

  static const _typeMap = {
    'RENT': AssetType.rent,
    'EXCHANGE': AssetType.exchange,
    'SELL': AssetType.sell,
  };
  static const _typeRev = {
    AssetType.rent: 'RENT',
    AssetType.exchange: 'EXCHANGE',
    AssetType.sell: 'SELL',
  };
  static const _catMap = {
    'CURRENT': AssetCategory.currentAsset,
    'FIXED': AssetCategory.fixedAsset,
  };
  static const _catRev = {
    AssetCategory.currentAsset: 'CURRENT',
    AssetCategory.fixedAsset: 'FIXED',
  };
  static const _statusMap = {
    'AVAILABLE_FULL': AssetStatus.availableFull,
    'AVAILABLE_EMPTY': AssetStatus.availableEmpty,
    'RENTED': AssetStatus.rented,
    'SOLD': AssetStatus.sold,
    'LOST': AssetStatus.lost,
    'MAINTENANCE': AssetStatus.maintenance,
    'RETIRED': AssetStatus.retired,
  };
  static const _statusRev = {
    AssetStatus.availableFull: 'AVAILABLE_FULL',
    AssetStatus.availableEmpty: 'AVAILABLE_EMPTY',
    AssetStatus.rented: 'RENTED',
    AssetStatus.sold: 'SOLD',
    AssetStatus.lost: 'LOST',
    AssetStatus.maintenance: 'MAINTENANCE',
    AssetStatus.retired: 'RETIRED',
  };

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
        id: json['id'] as String,
        barcode: json['barcode'] as String? ?? '',
        serialNumber: json['serial_number'] as String,
        itemId: json['item_id'] as String,
        type: _typeMap[json['type']] ?? AssetType.rent,
        category: _catMap[json['category']] ?? AssetCategory.currentAsset,
        status: _statusMap[json['status']] ?? AssetStatus.availableFull,
        currentCustomerId: json['current_customer_id'] as String?,
        cycleCount: json['cycle_count'] as int? ?? 0,
        adminNotes: json['admin_notes'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        lastActionDate: json['last_action_date'] != null
            ? DateTime.parse(json['last_action_date'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'barcode': barcode,
        'serial_number': serialNumber,
        'item_id': itemId,
        'type': _typeRev[type],
        'category': _catRev[category],
        'status': _statusRev[status],
        'current_customer_id': currentCustomerId,
        'cycle_count': cycleCount,
        'admin_notes': adminNotes,
        'is_active': isActive,
      };

  Asset copyWith({
    String? barcode,
    String? serialNumber,
    String? itemId,
    AssetType? type,
    AssetCategory? category,
    AssetStatus? status,
    String? currentCustomerId,
    int? cycleCount,
    String? adminNotes,
    bool? isActive,
    DateTime? lastActionDate,
  }) =>
      Asset(
        id: id,
        barcode: barcode ?? this.barcode,
        serialNumber: serialNumber ?? this.serialNumber,
        itemId: itemId ?? this.itemId,
        type: type ?? this.type,
        category: category ?? this.category,
        status: status ?? this.status,
        currentCustomerId: currentCustomerId ?? this.currentCustomerId,
        cycleCount: cycleCount ?? this.cycleCount,
        adminNotes: adminNotes ?? this.adminNotes,
        isActive: isActive ?? this.isActive,
        lastActionDate: lastActionDate ?? this.lastActionDate,
        createdAt: createdAt,
      );
}

/// Extended detail for Fixed Assets (vehicles, machinery, etc).
/// Based on SAP/Odoo fixed asset management best practices.
class FixedAssetDetail {
  // ── Identification ──
  final String assetId;
  final String? assetTag;
  final String? brand;
  final String? model;
  final String? plateNumber;

  // ── Acquisition ──
  final DateTime? acquisitionDate;
  final double originalValue;
  final String? vendorName;
  final String? poReference;

  // ── Depreciation ──
  final String depreciationMethod; // 'straight_line', 'declining_balance'
  final int usefulLifeMonths;
  final double salvageValue;

  // ── Location & Custody ──
  final String? location;
  final String? custodian;

  const FixedAssetDetail({
    required this.assetId,
    this.assetTag,
    this.brand,
    this.model,
    this.plateNumber,
    this.acquisitionDate,
    this.originalValue = 0,
    this.vendorName,
    this.poReference,
    this.depreciationMethod = 'straight_line',
    this.usefulLifeMonths = 60,
    this.salvageValue = 0,
    this.location,
    this.custodian,
  });

  double get monthlyDepreciation =>
      usefulLifeMonths > 0 ? (originalValue - salvageValue) / usefulLifeMonths : 0;

  double currentBookValue(DateTime asOf) {
    if (acquisitionDate == null) return originalValue;
    final months = (asOf.year - acquisitionDate!.year) * 12 +
        (asOf.month - acquisitionDate!.month);
    final depreciated = monthlyDepreciation * months;
    final bookValue = originalValue - depreciated;
    return bookValue < salvageValue ? salvageValue : bookValue;
  }

  factory FixedAssetDetail.fromJson(Map<String, dynamic> json) =>
      FixedAssetDetail(
        assetId: json['asset_id'] as String,
        assetTag: json['asset_tag'] as String?,
        brand: json['brand'] as String?,
        model: json['model'] as String?,
        plateNumber: json['plate_number'] as String?,
        acquisitionDate: json['acquisition_date'] != null
            ? DateTime.parse(json['acquisition_date'] as String)
            : null,
        originalValue: (json['original_value'] as num?)?.toDouble() ?? 0,
        vendorName: json['vendor_name'] as String?,
        poReference: json['po_reference'] as String?,
        depreciationMethod:
            json['depreciation_method'] as String? ?? 'straight_line',
        usefulLifeMonths: json['useful_life_months'] as int? ?? 60,
        salvageValue: (json['salvage_value'] as num?)?.toDouble() ?? 0,
        location: json['location'] as String?,
        custodian: json['custodian'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        'asset_tag': assetTag,
        'brand': brand,
        'model': model,
        'plate_number': plateNumber,
        'acquisition_date': acquisitionDate?.toIso8601String(),
        'original_value': originalValue,
        'vendor_name': vendorName,
        'po_reference': poReference,
        'depreciation_method': depreciationMethod,
        'useful_life_months': usefulLifeMonths,
        'salvage_value': salvageValue,
        'location': location,
        'custodian': custodian,
      };

  FixedAssetDetail copyWith({
    String? assetTag,
    String? brand,
    String? model,
    String? plateNumber,
    DateTime? acquisitionDate,
    double? originalValue,
    String? vendorName,
    String? poReference,
    String? depreciationMethod,
    int? usefulLifeMonths,
    double? salvageValue,
    String? location,
    String? custodian,
  }) =>
      FixedAssetDetail(
        assetId: assetId,
        assetTag: assetTag ?? this.assetTag,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        plateNumber: plateNumber ?? this.plateNumber,
        acquisitionDate: acquisitionDate ?? this.acquisitionDate,
        originalValue: originalValue ?? this.originalValue,
        vendorName: vendorName ?? this.vendorName,
        poReference: poReference ?? this.poReference,
        depreciationMethod: depreciationMethod ?? this.depreciationMethod,
        usefulLifeMonths: usefulLifeMonths ?? this.usefulLifeMonths,
        salvageValue: salvageValue ?? this.salvageValue,
        location: location ?? this.location,
        custodian: custodian ?? this.custodian,
      );
}
