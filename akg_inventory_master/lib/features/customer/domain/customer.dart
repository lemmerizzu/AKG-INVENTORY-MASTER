/// Customer domain model — aligned 1:1 with `customers` SQLite table.
/// Phase 3 — Grand Refactor: tambah npwp, phone, reportUpdates dari ERD customerDetails
class Customer {
  final String id;
  final String customerCode;
  final String name;
  final String address;
  final bool isPpnEnabled;
  final bool isActive;
  final int termDays;
  final String? npwp;         // Phase 3: dari kolom 'npwp' Excel
  final String? phone;        // Phase 3: dari kolom 'call' Excel
  final DateTime? reportUpdates; // Phase 3: dari kolom 'reportUpdates' Excel
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.customerCode,
    required this.name,
    this.address = '',
    this.isPpnEnabled = false,
    this.isActive = true,
    this.termDays = 14,
    this.npwp,
    this.phone,
    this.reportUpdates,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        customerCode: json['customer_code'] as String,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        isPpnEnabled: json['is_ppn'] is bool
            ? json['is_ppn'] as bool
            : (json['is_ppn'] as int? ?? 0) == 1,
        isActive: json['is_active'] is bool
            ? json['is_active'] as bool
            : (json['is_active'] as int? ?? 1) == 1,
        termDays: (json['term_days'] as num?)?.toInt() ?? 14,
        npwp: json['npwp'] as String?,
        phone: json['phone'] as String?,
        reportUpdates: json['report_updates'] != null
            ? DateTime.tryParse(json['report_updates'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_code': customerCode,
        'name': name,
        'address': address,
        'is_ppn': isPpnEnabled ? 1 : 0,
        'is_active': isActive ? 1 : 0,
        'term_days': termDays,
        'npwp': npwp,
        'phone': phone,
        'report_updates': reportUpdates?.toIso8601String(),
      };

  Customer copyWith({
    String? id,
    String? customerCode,
    String? name,
    String? address,
    bool? isPpnEnabled,
    bool? isActive,
    int? termDays,
    String? npwp,
    String? phone,
    DateTime? reportUpdates,
  }) =>
      Customer(
        id: id ?? this.id,
        customerCode: customerCode ?? this.customerCode,
        name: name ?? this.name,
        address: address ?? this.address,
        isPpnEnabled: isPpnEnabled ?? this.isPpnEnabled,
        isActive: isActive ?? this.isActive,
        termDays: termDays ?? this.termDays,
        npwp: npwp ?? this.npwp,
        phone: phone ?? this.phone,
        reportUpdates: reportUpdates ?? this.reportUpdates,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// Customer-specific price override — aligned with `customer_pricelists` table.
class CustomerPricelist {
  final String id;
  final String customerId;
  final String itemId;
  final double customPrice; // changed int → double for NUMERIC(15,2) alignment

  const CustomerPricelist({
    required this.id,
    required this.customerId,
    required this.itemId,
    required this.customPrice,
  });

  factory CustomerPricelist.fromJson(Map<String, dynamic> json) =>
      CustomerPricelist(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        itemId: json['item_id'] as String,
        customPrice: (json['custom_price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'item_id': itemId,
        'custom_price': customPrice,
      };
}
