import 'asset.dart';

/// Item master — aligned 1:1 with `items` SQL table.
class Item {
  final String id;
  final String itemCode;
  final String name;
  final String unit;
  final int basePrice; // Rupiah
  final AssetType defaultType;
  final bool isActive;
  final DateTime? createdAt;

  const Item({
    required this.id,
    required this.itemCode,
    required this.name,
    this.unit = 'Btl',
    required this.basePrice,
    this.defaultType = AssetType.rent,
    this.isActive = true,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        itemCode: json['item_code'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String? ?? 'Btl',
        basePrice: (json['base_price'] as num).toInt(),
        defaultType: json['default_type'] == 'EXCHANGE'
            ? AssetType.exchange
            : json['default_type'] == 'SELL'
                ? AssetType.sell
                : AssetType.rent,
        isActive: json['is_active'] is bool
            ? json['is_active'] as bool
            : (json['is_active'] as int? ?? 1) == 1,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );


  Map<String, dynamic> toJson() => {
        'id': id,
        'item_code': itemCode,
        'name': name,
        'unit': unit,
        'base_price': basePrice,
        'default_type': defaultType == AssetType.exchange
            ? 'EXCHANGE'
            : defaultType == AssetType.sell
                ? 'SELL'
                : 'RENT',
        'is_active': isActive,
      };

  Item copyWith({
    String? itemCode,
    String? name,
    String? unit,
    int? basePrice,
    AssetType? defaultType,
    bool? isActive,
  }) =>
      Item(
        id: id,
        itemCode: itemCode ?? this.itemCode,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        basePrice: basePrice ?? this.basePrice,
        defaultType: defaultType ?? this.defaultType,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );
}
