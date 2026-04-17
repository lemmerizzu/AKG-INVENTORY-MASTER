import '../../../core/database_helper.dart';
import '../domain/customer.dart';

/// Data access layer for customers and their related lists.
class CustomerRepository {
  final _db = DatabaseHelper.instance;

  // ── Customer CRUD ──────────────────────────────────────────────────

  Future<List<Customer>> getAll() async {
    final rows = await _db.query('customers', orderBy: 'name ASC');
    return rows.map((r) => Customer.fromJson(_intToBool(r))).toList();
  }

  Future<Customer?> getById(String id) async {
    final rows = await _db.query('customers',
        where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Customer.fromJson(_intToBool(rows.first));
  }

  Future<void> insert(Customer customer) async {
    await _db.insert('customers', customer.toJson());
  }

  Future<void> update(Customer customer) async {
    await _db.update('customers', customer.toJson(),
        where: 'id = ?', whereArgs: [customer.id]);
  }

  // ── Related List: Pricelists ───────────────────────────────────────

  /// Get all price entries for a given customer, joined with item names.
  Future<List<CustomerPricelistView>> getPricelistByCustomerId(
      String customerId) async {
    final rows = await _db.rawQuery('''
      SELECT cp.id, cp.customer_id, cp.item_id, cp.custom_price,
             i.name AS item_name, i.base_price, i.unit
      FROM customer_pricelists cp
      INNER JOIN items i ON i.id = cp.item_id
      WHERE cp.customer_id = ?
      ORDER BY i.name ASC
    ''', [customerId]);
    return rows.map((r) => CustomerPricelistView.fromRow(r)).toList();
  }

  // ── Related List: Assets at Customer ──────────────────────────────

  /// Get all assets currently held by this customer.
  Future<List<Map<String, dynamic>>> getAssetsByCustomerId(
      String customerId) async {
    return _db.rawQuery('''
      SELECT a.*, i.name AS item_name
      FROM assets a
      INNER JOIN items i ON i.id = a.item_id
      WHERE a.current_customer_id = ? AND a.is_active = 1
      ORDER BY i.name ASC, a.serial_number ASC
    ''', [customerId]);
  }

  // ── Related List: Transactions ────────────────────────────────────

  /// Get recent transactions for this customer.
  Future<List<Map<String, dynamic>>> getTransactionsByCustomerId(
      String customerId, {int limit = 50}) async {
    return _db.rawQuery('''
      SELECT * FROM transaction_documents
      WHERE customer_id = ?
      ORDER BY transaction_date DESC
      LIMIT ?
    ''', [customerId, limit]);
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// SQLite stores bools as int (0/1). Convert for fromJson compatibility.
  Map<String, dynamic> _intToBool(Map<String, dynamic> row) {
    final m = Map<String, dynamic>.from(row);
    if (m['is_ppn'] is int) m['is_ppn'] = m['is_ppn'] == 1;
    if (m['is_active'] is int) m['is_active'] = m['is_active'] == 1;
    return m;
  }
}

/// View model for pricelist entries with item details (JOIN result).
class CustomerPricelistView {
  final String id;
  final String customerId;
  final String itemId;
  final int customPrice;
  final String itemName;
  final int basePrice;
  final String unit;

  const CustomerPricelistView({
    required this.id,
    required this.customerId,
    required this.itemId,
    required this.customPrice,
    required this.itemName,
    required this.basePrice,
    required this.unit,
  });

  /// Price difference percentage: positive = more expensive, negative = discount.
  double get deltaPercent =>
      basePrice > 0 ? ((customPrice - basePrice) / basePrice) * 100 : 0;

  factory CustomerPricelistView.fromRow(Map<String, dynamic> row) {
    return CustomerPricelistView(
      id: row['id'] as String,
      customerId: row['customer_id'] as String,
      itemId: row['item_id'] as String,
      customPrice: (row['custom_price'] as num).toInt(),
      itemName: row['item_name'] as String,
      basePrice: (row['base_price'] as num).toInt(),
      unit: row['unit'] as String? ?? 'Btl',
    );
  }
}
