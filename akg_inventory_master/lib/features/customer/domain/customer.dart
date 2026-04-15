/// Customer domain model — aligned 1:1 with `customers` SQL table.
class Customer {
  final String id;
  final String customerCode;
  final String name;
  final String address;
  final bool isPpnEnabled;
  final int termDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.customerCode,
    required this.name,
    this.address = '',
    this.isPpnEnabled = false,
    this.termDays = 14,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        customerCode: json['customer_code'] as String,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        isPpnEnabled: json['is_ppn'] as bool? ?? false,
        termDays: json['term_days'] as int? ?? 14,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_code': customerCode,
        'name': name,
        'address': address,
        'is_ppn': isPpnEnabled,
        'term_days': termDays,
      };

  Customer copyWith({
    String? id,
    String? customerCode,
    String? name,
    String? address,
    bool? isPpnEnabled,
    int? termDays,
  }) =>
      Customer(
        id: id ?? this.id,
        customerCode: customerCode ?? this.customerCode,
        name: name ?? this.name,
        address: address ?? this.address,
        isPpnEnabled: isPpnEnabled ?? this.isPpnEnabled,
        termDays: termDays ?? this.termDays,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// Customer-specific price override — aligned with `customer_pricelists` table.
class CustomerPricelist {
  final String id;
  final String customerId;
  final String itemId;
  final int customPrice; // Rupiah integer to avoid floating-point errors

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
        customPrice: (json['custom_price'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'item_id': itemId,
        'custom_price': customPrice,
      };
}
