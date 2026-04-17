import '../../../core/database_helper.dart';
import '../domain/item.dart';

/// Data access layer for items and their related lists.
class ItemRepository {
  final _db = DatabaseHelper.instance;

  // ── Item CRUD ─────────────────────────────────────────────────────

  Future<List<Item>> getAll() async {
    final rows = await _db.query('items', orderBy: 'name ASC');
    return rows.map((r) => Item.fromJson(_intToBool(r))).toList();
  }

  Future<Item?> getById(String id) async {
    final rows =
        await _db.query('items', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Item.fromJson(_intToBool(rows.first));
  }

  Future<void> insert(Item item) async {
    await _db.insert('items', item.toJson());
  }

  Future<void> update(Item item) async {
    await _db.update('items', item.toJson(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  // ── Related List: Customer Prices ─────────────────────────────────

  /// Get all customers with custom prices for this item.
  Future<List<ItemPricelistView>> getPricelistByItemId(String itemId) async {
    final rows = await _db.rawQuery('''
      SELECT cp.id, cp.customer_id, cp.item_id, cp.custom_price,
             c.name AS customer_name, c.customer_code
      FROM customer_pricelists cp
      INNER JOIN customers c ON c.id = cp.customer_id
      WHERE cp.item_id = ?
      ORDER BY c.name ASC
    ''', [itemId]);
    return rows.map((r) => ItemPricelistView.fromRow(r)).toList();
  }

  // ── Related List: Assets of this Item ─────────────────────────────

  /// Get all assets that belong to this item type.
  Future<List<Map<String, dynamic>>> getAssetsByItemId(String itemId) async {
    return _db.rawQuery('''
      SELECT a.*,
             CASE WHEN a.current_customer_id = 'AKGREADY' THEN 'Gudang AKG'
                  ELSE COALESCE(c.name, a.current_customer_id)
             END AS location_name
      FROM assets a
      LEFT JOIN customers c ON c.id = a.current_customer_id
      WHERE a.item_id = ? AND a.is_active = 1
      ORDER BY a.serial_number ASC
    ''', [itemId]);
  }

  // ── Stats ─────────────────────────────────────────────────────────

  /// Get inventory summary per item (total, in warehouse, rented, etc.)
  Future<Map<String, int>> getAssetStatsByItemId(String itemId) async {
    final total = await _db.rawQuery(
        'SELECT COUNT(*) as c FROM assets WHERE item_id = ? AND is_active = 1',
        [itemId]);
    final warehouse = await _db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE item_id = ? AND current_customer_id = 'AKGREADY' AND is_active = 1",
        [itemId]);
    final rented = await _db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE item_id = ? AND status = 'RENTED' AND is_active = 1",
        [itemId]);

    return {
      'total': (total.first['c'] as num).toInt(),
      'warehouse': (warehouse.first['c'] as num).toInt(),
      'rented': (rented.first['c'] as num).toInt(),
    };
  }

  Map<String, dynamic> _intToBool(Map<String, dynamic> row) {
    final m = Map<String, dynamic>.from(row);
    if (m['is_active'] is int) m['is_active'] = m['is_active'] == 1;
    return m;
  }
}

/// View model for item-centric pricelist entries (JOIN with customer).
class ItemPricelistView {
  final String id;
  final String customerId;
  final String itemId;
  final int customPrice;
  final String customerName;
  final String customerCode;

  const ItemPricelistView({
    required this.id,
    required this.customerId,
    required this.itemId,
    required this.customPrice,
    required this.customerName,
    required this.customerCode,
  });

  factory ItemPricelistView.fromRow(Map<String, dynamic> row) {
    return ItemPricelistView(
      id: row['id'] as String,
      customerId: row['customer_id'] as String,
      itemId: row['item_id'] as String,
      customPrice: (row['custom_price'] as num).toInt(),
      customerName: row['customer_name'] as String,
      customerCode: row['customer_code'] as String,
    );
  }
}
