/// Item master — aligned 1:1 with `items` SQL table.
class Item {
  final String id;
  final String itemCode;
  final String name;
  final int basePrice; // Rupiah
  final DateTime? createdAt;

  const Item({
    required this.id,
    required this.itemCode,
    required this.name,
    required this.basePrice,
    this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        itemCode: json['item_code'] as String,
        name: json['name'] as String,
        basePrice: (json['base_price'] as num).toInt(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_code': itemCode,
        'name': name,
        'base_price': basePrice,
      };
}
