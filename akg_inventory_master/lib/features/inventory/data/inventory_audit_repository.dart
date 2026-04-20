import '../../../core/database_helper.dart';
import '../domain/inventory_audit.dart';

class InventoryAuditRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<InventoryAudit>> fetchAudits() async {
    final data = await _db.query('inventory_audits', orderBy: 'audit_date DESC');
    return data.map((json) => InventoryAudit.fromJson(json)).toList();
  }

  Future<List<InventoryAuditLine>> fetchAuditLines(String auditId) async {
    // Join with items to get names and codes
    final sql = '''
      SELECT al.*, i.name as item_name, i.item_code 
      FROM inventory_audit_lines al
      JOIN items i ON al.item_id = i.id
      WHERE al.audit_id = ?
    ''';
    final data = await _db.rawQuery(sql, [auditId]);
    return data.map((json) => InventoryAuditLine.fromJson(json)).toList();
  }

  Future<void> createAudit(InventoryAudit audit) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // 1. Insert Header
      await txn.insert('inventory_audits', audit.toJson());

      // 2. Snapshot Current Stock levels
      // Sum qty from inventory_ledger where transaction is not void
      const snapshotSql = '''
        SELECT item_id, SUM(qty) as balance 
        FROM inventory_ledger 
        WHERE document_id IN (SELECT id FROM transaction_documents WHERE status != 'VOID') 
        GROUP BY item_id
      ''';
      
      final balances = await txn.rawQuery(snapshotSql);
      
      // Also get all active items that might have 0 balance but should be in the audit
      final activeItems = await txn.query('items', where: 'is_active = 1');
      
      final Map<String, int> stockMap = {
        for (var item in activeItems) (item['id'] as String): 0
      };
      
      for (var row in balances) {
        final itemId = row['item_id'] as String;
        final balance = (row['balance'] as num).toInt();
        stockMap[itemId] = balance;
      }

      // 3. Create Audit Lines
      for (var entry in stockMap.entries) {
        final lineId = '${audit.id}_${entry.key}';
        await txn.insert('inventory_audit_lines', {
          'id': lineId,
          'audit_id': audit.id,
          'item_id': entry.key,
          'system_qty': entry.value,
          'physical_qty': 0, // Initial
          'note': null,
        });
      }
    });
  }

  Future<void> updateAuditLine(InventoryAuditLine line) async {
    await _db.update(
      'inventory_audit_lines',
      line.toJson(),
      where: 'id = ?',
      whereArgs: [line.id],
    );
  }

  Future<void> saveAudit(InventoryAudit audit) async {
    await _db.update(
      'inventory_audits',
      audit.toJson(),
      where: 'id = ?',
      whereArgs: [audit.id],
    );
  }

  Future<void> completeAudit(String auditId, List<InventoryAuditLine> lines) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // 1. Update status to COMPLETED
      await txn.update(
        'inventory_audits',
        {'status': 'COMPLETED'},
        where: 'id = ?',
        whereArgs: [auditId],
      );

      // 2. Update all lines physical counts
      for (var line in lines) {
        await txn.update(
          'inventory_audit_lines',
          line.toJson(),
          where: 'id = ?',
          whereArgs: [line.id],
        );

        // 3. Optional: Auto-correction logic could go here
        // if (line.discrepancy != 0) {
        //   // Generate a Correction Transaction
        // }
      }
    });
  }
}
