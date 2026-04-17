import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database_helper.dart';
import '../domain/transaction_document.dart';
import '../domain/audit_log.dart';

class TransactionRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<TransactionDocument>> fetchTransactions({
    MutationCode? mutation,
    String? customerId,
  }) async {
    String? where;
    List<dynamic>? whereArgs;

    if (mutation != null || customerId != null) {
      final List<String> conditions = [];
      whereArgs = [];
      if (mutation != null) {
        // Find the string key from MutationCode
        final Map<MutationCode, String> mutRev = {
          MutationCode.inbound: 'IN',
          MutationCode.outbound: 'OUT',
          MutationCode.other: 'OTHER',
        };
        conditions.add('mutation = ?');
        whereArgs.add(mutRev[mutation]);
      }
      if (customerId != null) {
        conditions.add('customer_id = ?');
        whereArgs.add(customerId);
      }
      where = conditions.join(' AND ');
    }

    final data = await _db.query(
      'transaction_documents',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'transaction_date DESC',
    );
    return data.map((json) => TransactionDocument.fromJson(json)).toList();
  }

  Future<List<InventoryLedgerEntry>> fetchLedgerEntries(String documentId) async {
    final data = await _db.query(
      'inventory_ledger',
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
    return data.map((json) => InventoryLedgerEntry.fromJson(json)).toList();
  }

  Future<List<AuditLog>> fetchAuditLogs(String documentId) async {
    final data = await _db.query(
      'audit_logs',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'created_at DESC',
    );
    return data.map((json) => AuditLog.fromJson(json)).toList();
  }

  /// Checks if a document has any EDIT audit logs.
  Future<bool> hasBeenEdited(String documentId) async {
    final data = await _db.query(
      'audit_logs',
      where: 'document_id = ? AND action = ?',
      whereArgs: [documentId, 'EDIT'],
      limit: 1,
    );
    return data.isNotEmpty;
  }

  Future<void> saveTransaction(
    TransactionDocument doc,
    List<InventoryLedgerEntry> lines, {
    String? editNote,
  }) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // 1. Insert/Update Header
      await txn.insert(
        'transaction_documents',
        doc.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Clear old ledger lines (if any) and insert new ones
      await txn.delete('inventory_ledger',
          where: 'document_id = ?', whereArgs: [doc.id]);
      for (final line in lines) {
        await txn.insert('inventory_ledger', line.toJson());
      }

      // 3. Add Audit Log
      final isNew = editNote == null; // Simple heuristic for mock
      final log = AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentId: doc.id,
        action: isNew ? 'CREATE' : 'EDIT',
        note: isNew ? 'Document created' : editNote,
        createdAt: DateTime.now(),
      );
      // Wait, AuditLog mapping might use document_id instead of documentId
      final logData = log.toJson();
      // Adjusting to DB column name since toJson might use camelCase if not careful
      // Actually my AuditLog.toJson uses 'document_id' correctly.

      await txn.insert('audit_logs', logData);
    });
  }

  Future<void> voidTransaction(String documentId, String reason) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'transaction_documents',
        {'status': 'VOID'},
        where: 'id = ?',
        whereArgs: [documentId],
      );

      final log = AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentId: documentId,
        action: 'VOID',
        note: reason,
        createdAt: DateTime.now(),
      );
      await txn.insert('audit_logs', log.toJson());
    });
  }
}

final transactionRepositoryProvider = Provider((ref) => TransactionRepository());
