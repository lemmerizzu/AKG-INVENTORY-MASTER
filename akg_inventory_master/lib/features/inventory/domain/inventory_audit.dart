
enum AuditStatus { draft, completed }

/// Header for Inventory Audit (Stock Opname) document.
class InventoryAudit {
  final String id;
  final String auditNumber;
  final DateTime auditDate;
  final AuditStatus status;
  final String? note;
  final DateTime? createdAt;

  const InventoryAudit({
    required this.id,
    required this.auditNumber,
    required this.auditDate,
    this.status = AuditStatus.draft,
    this.note,
    this.createdAt,
  });

  factory InventoryAudit.fromJson(Map<String, dynamic> json) => InventoryAudit(
        id: json['id'] as String,
        auditNumber: json['audit_number'] as String,
        auditDate: DateTime.parse(json['audit_date'] as String),
        status: json['status'] == 'COMPLETED' ? AuditStatus.completed : AuditStatus.draft,
        note: json['note'] as String?,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'audit_number': auditNumber,
        'audit_date': auditDate.toIso8601String(),
        'status': status == AuditStatus.completed ? 'COMPLETED' : 'DRAFT',
        'note': note,
        'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

  InventoryAudit copyWith({
    String? auditNumber,
    DateTime? auditDate,
    AuditStatus? status,
    String? note,
  }) =>
      InventoryAudit(
        id: id,
        auditNumber: auditNumber ?? this.auditNumber,
        auditDate: auditDate ?? this.auditDate,
        status: status ?? this.status,
        note: note ?? this.note,
        createdAt: createdAt,
      );
}

/// Detail line for Inventory Audit.
class InventoryAuditLine {
  final String id;
  final String auditId;
  final String itemId;
  final String? itemName; // Joined for UI
  final String? itemCode; // Joined for UI
  final int systemQty;
  final int physicalQty;
  final String? note;

  const InventoryAuditLine({
    required this.id,
    required this.auditId,
    required this.itemId,
    this.itemName,
    this.itemCode,
    required this.systemQty,
    this.physicalQty = 0,
    this.note,
  });

  int get discrepancy => physicalQty - systemQty;

  factory InventoryAuditLine.fromJson(Map<String, dynamic> json) => InventoryAuditLine(
        id: json['id'] as String,
        auditId: json['audit_id'] as String,
        itemId: json['item_id'] as String,
        itemName: json['item_name'] as String?,
        itemCode: json['item_code'] as String?,
        systemQty: (json['system_qty'] as num).toInt(),
        physicalQty: (json['physical_qty'] as num? ?? 0).toInt(),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'audit_id': auditId,
        'item_id': itemId,
        'system_qty': systemQty,
        'physical_qty': physicalQty,
        'note': note,
      };

  InventoryAuditLine copyWith({
    int? physicalQty,
    String? note,
    String? itemName,
    String? itemCode,
  }) =>
      InventoryAuditLine(
        id: id,
        auditId: auditId,
        itemId: itemId,
        itemName: itemName ?? this.itemName,
        itemCode: itemCode ?? this.itemCode,
        systemQty: systemQty,
        physicalQty: physicalQty ?? this.physicalQty,
        note: note ?? this.note,
      );
}
