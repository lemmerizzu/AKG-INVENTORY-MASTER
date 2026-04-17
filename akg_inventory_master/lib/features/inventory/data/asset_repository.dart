import '../../../core/database_helper.dart';
import '../domain/asset.dart';

/// Data access layer for assets and their related movement history.
class AssetRepository {
  final _db = DatabaseHelper.instance;

  // ── Asset CRUD ────────────────────────────────────────────────────

  Future<List<Asset>> getAll() async {
    final rows = await _db.query('assets',
        where: 'is_active = 1', orderBy: 'serial_number ASC');
    return rows.map((r) => Asset.fromJson(_intToBool(r))).toList();
  }

  Future<Asset?> getById(String id) async {
    final rows =
        await _db.query('assets', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Asset.fromJson(_intToBool(rows.first));
  }

  Future<Asset?> getByBarcode(String barcode) async {
    final rows = await _db.query('assets',
        where: 'barcode = ? AND is_active = 1', whereArgs: [barcode]);
    if (rows.isEmpty) return null;
    return Asset.fromJson(_intToBool(rows.first));
  }

  Future<void> insert(Asset asset) async {
    await _db.insert('assets', asset.toJson());
  }

  Future<void> update(Asset asset) async {
    await _db.update('assets', asset.toJson(),
        where: 'id = ?', whereArgs: [asset.id]);
  }

  // ── Related List: Movement History ────────────────────────────────

  /// Get ledger entries for a specific asset (by barcode).
  Future<List<Map<String, dynamic>>> getMovementHistory(
      String barcode) async {
    return _db.rawQuery('''
      SELECT il.*, td.sys_doc_number, td.mutation, td.transaction_date,
             c.name AS customer_name
      FROM inventory_ledger il
      INNER JOIN transaction_documents td ON td.id = il.document_id
      LEFT JOIN customers c ON c.id = td.customer_id
      WHERE il.cylinder_barcode = ?
      ORDER BY il.created_at DESC
    ''', [barcode]);
  }

  // ── Filtered Queries ──────────────────────────────────────────────

  Future<List<Asset>> getByCustomerId(String customerId) async {
    final rows = await _db.query('assets',
        where: 'current_customer_id = ? AND is_active = 1',
        whereArgs: [customerId],
        orderBy: 'serial_number ASC');
    return rows.map((r) => Asset.fromJson(_intToBool(r))).toList();
  }

  Future<List<Asset>> getByItemId(String itemId) async {
    final rows = await _db.query('assets',
        where: 'item_id = ? AND is_active = 1',
        whereArgs: [itemId],
        orderBy: 'serial_number ASC');
    return rows.map((r) => Asset.fromJson(_intToBool(r))).toList();
  }

  Future<List<Asset>> getByStatus(AssetStatus status) async {
    final statusStr = {
      AssetStatus.availableFull: 'AVAILABLE_FULL',
      AssetStatus.availableEmpty: 'AVAILABLE_EMPTY',
      AssetStatus.rented: 'RENTED',
      AssetStatus.sold: 'SOLD',
      AssetStatus.lost: 'LOST',
      AssetStatus.maintenance: 'MAINTENANCE',
      AssetStatus.retired: 'RETIRED',
    }[status]!;
    final rows = await _db.query('assets',
        where: 'status = ? AND is_active = 1',
        whereArgs: [statusStr],
        orderBy: 'serial_number ASC');
    return rows.map((r) => Asset.fromJson(_intToBool(r))).toList();
  }

  Future<List<Asset>> getUnaudited() async {
    final rows = await _db.rawQuery('''
      SELECT * FROM assets
      WHERE is_active = 1 AND (
        barcode = '' OR barcode IS NULL
        OR LOWER(barcode) IN ('no barcode','nobarcode','not valid','not asigned yet','-','bas')
        OR LOWER(barcode) LIKE 'di alihkan%'
      )
      ORDER BY serial_number ASC
    ''');
    return rows.map((r) => Asset.fromJson(_intToBool(r))).toList();
  }

  // ── Stats ─────────────────────────────────────────────────────────

  Future<Map<String, int>> getOverviewStats() async {
    final total = await _db.rawQuery(
        'SELECT COUNT(*) as c FROM assets WHERE is_active = 1');
    final warehouse = await _db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE current_customer_id = 'AKGREADY' AND is_active = 1");
    final rented = await _db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE status = 'RENTED' AND is_active = 1");
    final maintenance = await _db.rawQuery(
        "SELECT COUNT(*) as c FROM assets WHERE status = 'MAINTENANCE' AND is_active = 1");

    return {
      'total': (total.first['c'] as num).toInt(),
      'warehouse': (warehouse.first['c'] as num).toInt(),
      'rented': (rented.first['c'] as num).toInt(),
      'maintenance': (maintenance.first['c'] as num).toInt(),
    };
  }

  Map<String, dynamic> _intToBool(Map<String, dynamic> row) {
    final m = Map<String, dynamic>.from(row);
    if (m['is_active'] is int) m['is_active'] = m['is_active'] == 1;
    return m;
  }
}
