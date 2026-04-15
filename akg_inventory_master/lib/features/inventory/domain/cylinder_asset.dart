/// Lifecycle status of an individual cylinder asset.
enum AssetStatus { availableFull, rented, availableEmpty, maintenance }

/// Physical cylinder asset — aligned 1:1 with `cylinder_assets` SQL table.
/// Each row represents one physical tube with unique barcode/series.
class CylinderAsset {
  final String barcode; // Primary key
  final String itemId;
  final AssetStatus status;
  final String? currentCustomerId;
  final int cycleCount;
  final DateTime? lastActionDate;

  const CylinderAsset({
    required this.barcode,
    required this.itemId,
    this.status = AssetStatus.availableFull,
    this.currentCustomerId,
    this.cycleCount = 0,
    this.lastActionDate,
  });

  static const _statusMap = {
    'AVAILABLE_FULL': AssetStatus.availableFull,
    'RENTED': AssetStatus.rented,
    'AVAILABLE_EMPTY': AssetStatus.availableEmpty,
    'MAINTENANCE': AssetStatus.maintenance,
  };

  static const _statusReverseMap = {
    AssetStatus.availableFull: 'AVAILABLE_FULL',
    AssetStatus.rented: 'RENTED',
    AssetStatus.availableEmpty: 'AVAILABLE_EMPTY',
    AssetStatus.maintenance: 'MAINTENANCE',
  };

  factory CylinderAsset.fromJson(Map<String, dynamic> json) => CylinderAsset(
        barcode: json['barcode'] as String,
        itemId: json['item_id'] as String,
        status: _statusMap[json['status']] ?? AssetStatus.availableFull,
        currentCustomerId: json['current_customer_id'] as String?,
        cycleCount: json['cycle_count'] as int? ?? 0,
        lastActionDate: json['last_action_date'] != null
            ? DateTime.parse(json['last_action_date'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'item_id': itemId,
        'status': _statusReverseMap[status],
        'current_customer_id': currentCustomerId,
        'cycle_count': cycleCount,
      };

  CylinderAsset copyWith({
    AssetStatus? status,
    String? currentCustomerId,
    int? cycleCount,
    DateTime? lastActionDate,
  }) =>
      CylinderAsset(
        barcode: barcode,
        itemId: itemId,
        status: status ?? this.status,
        currentCustomerId: currentCustomerId ?? this.currentCustomerId,
        cycleCount: cycleCount ?? this.cycleCount,
        lastActionDate: lastActionDate ?? this.lastActionDate,
      );
}
