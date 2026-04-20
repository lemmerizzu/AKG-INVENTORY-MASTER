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

  /// Returns the number of 'EDIT' actions for a document.
  Future<int> getRevisionCount(String documentId) async {
    final data = await _db.rawQuery(
      'SELECT COUNT(*) as cnt FROM audit_logs WHERE document_id = ? AND action = ?',
      [documentId, 'EDIT'],
    );
    return data.isNotEmpty ? (data.first['cnt'] as int? ?? 0) : 0;
  }

  Future<void> saveTransaction(
    TransactionDocument doc,
    List<InventoryLedgerEntry> lines, {
    String? editNote,
  }) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // 0. Detect old serials for reconciliation (if edit)
      final oldLines = await txn.query('inventory_ledger',
          where: 'document_id = ?', whereArgs: [doc.id]);
      final Set<String> oldSerials = {};
      for (final r in oldLines) {
        final sn = r['cylinder_barcode'] as String?;
        if (sn != null && sn.isNotEmpty) {
          oldSerials.addAll(sn.split(',').map((s) => s.trim()));
        }
      }

      // 1. Insert/Update Header
      await txn.insert(
        'transaction_documents',
        doc.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Clear old ledger lines and insert new ones
      await txn.delete('inventory_ledger',
          where: 'document_id = ?', whereArgs: [doc.id]);
      
      final Set<String> newSerials = {};
      for (final line in lines) {
        await txn.insert('inventory_ledger', line.toJson());
        if (line.cylinderBarcode != null && line.cylinderBarcode!.isNotEmpty) {
          newSerials.addAll(line.cylinderBarcode!.split(',').map((s) => s.trim()));
        }
      }

      // 3. Asset Reconciliation Logic
      // - Removed serials: (old - new)
      // - Added/Stayed serials: (new)
      final removedSerials = oldSerials.difference(newSerials);
      
      final isOutbound = doc.mutation == MutationCode.outbound;
      
      // Handle Added/Update serials in this doc
      if (newSerials.isNotEmpty) {
        final targetValue = isOutbound ? doc.customerId : 'AKGREADY';
        final statusValue = isOutbound ? 'RENTED' : 'AVAILABLE_EMPTY'; // Simplified status
        
        for (final sn in newSerials) {
          await txn.update(
            'assets',
            {
              'current_customer_id': targetValue,
              'status': statusValue,
              'last_action_date': DateTime.now().toIso8601String(),
            },
            where: 'serial_number = ?',
            whereArgs: [sn],
          );
        }
      }

      // Handle Removed serials (Back to source)
      if (removedSerials.isNotEmpty) {
        final revertValue = isOutbound ? 'AKGREADY' : doc.customerId;
        final statusValue = isOutbound ? 'AVAILABLE_EMPTY' : 'RENTED';
        
        for (final sn in removedSerials) {
          await txn.update(
            'assets',
            {
              'current_customer_id': revertValue,
              'status': statusValue,
              'last_action_date': DateTime.now().toIso8601String(),
            },
            where: 'serial_number = ?',
            whereArgs: [sn],
          );
        }
      }

      // 4. Add Audit Log
      final isNew = editNote == null;
      final log = AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentId: doc.id,
        action: isNew ? 'CREATE' : 'EDIT',
        note: isNew ? 'Document created' : editNote,
        createdAt: DateTime.now(),
      );
      await txn.insert('audit_logs', log.toJson());
    });
  }

  Future<void> voidTransaction(String documentId, String reason) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      // 1. Get document info before voiding
      final docRows = await txn.query('transaction_documents', where: 'id = ?', whereArgs: [documentId]);
      if (docRows.isEmpty) return;
      final status = docRows.first['status'] as String;
      if (status == 'VOID') return; // Already voided

      final mutation = docRows.first['mutation'] as String;
      final customerId = docRows.first['customer_id'] as String;

      // 2. Update status to VOID
      await txn.update(
        'transaction_documents',
        {'status': 'VOID'},
        where: 'id = ?',
        whereArgs: [documentId],
      );

      // 3. Asset Reversion (Everything back to start)
      final ledgerRows = await txn.query('inventory_ledger', where: 'document_id = ?', whereArgs: [documentId]);
      final List<String> allSerials = [];
      for (final r in ledgerRows) {
        final sn = r['cylinder_barcode'] as String?;
        if (sn != null && sn.isNotEmpty) {
          allSerials.addAll(sn.split(',').map((s) => s.trim()));
        }
      }

      if (allSerials.isNotEmpty) {
        // If OUT, revert to Gudang. If IN, revert to Customer.
        final targetValue = (mutation == 'OUT') ? 'AKGREADY' : customerId;
        final statusValue = (mutation == 'OUT') ? 'AVAILABLE_EMPTY' : 'RENTED';

        for (final sn in allSerials) {
          await txn.update(
            'assets',
            {'current_customer_id': targetValue, 'status': statusValue},
            where: 'serial_number = ?',
            whereArgs: [sn],
          );
        }
      }

      // 4. Add Audit Log
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
