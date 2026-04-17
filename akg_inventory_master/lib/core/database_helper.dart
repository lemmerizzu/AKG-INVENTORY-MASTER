import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'seed_data.dart';

/// Singleton database helper for local SQLite storage.
/// Designed for Windows desktop; will be replaced by Supabase in production.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}${Platform.pathSeparator}akg_master.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // ── Schema Creation ─────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        item_code TEXT NOT NULL,
        name TEXT NOT NULL,
        unit TEXT DEFAULT 'Btl',
        base_price INTEGER NOT NULL,
        default_type TEXT DEFAULT 'RENT',
        is_active INTEGER DEFAULT 1,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        customer_code TEXT NOT NULL,
        name TEXT NOT NULL,
        address TEXT DEFAULT '',
        is_ppn INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        term_days INTEGER DEFAULT 14,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customer_pricelists (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        custom_price INTEGER NOT NULL,
        UNIQUE(customer_id, item_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assets (
        id TEXT PRIMARY KEY,
        barcode TEXT DEFAULT '',
        serial_number TEXT NOT NULL,
        item_id TEXT NOT NULL,
        type TEXT DEFAULT 'RENT',
        category TEXT DEFAULT 'CURRENT',
        status TEXT DEFAULT 'AVAILABLE_FULL',
        current_customer_id TEXT,
        cycle_count INTEGER DEFAULT 0,
        admin_notes TEXT,
        is_active INTEGER DEFAULT 1,
        last_action_date TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_documents (
        id TEXT PRIMARY KEY,
        sys_doc_number TEXT NOT NULL,
        po_reference TEXT,
        mutation TEXT NOT NULL,
        input_mode TEXT DEFAULT 'BULK',
        customer_id TEXT NOT NULL,
        transaction_date TEXT NOT NULL,
        shipping_address TEXT DEFAULT '',
        status TEXT DEFAULT 'DRAFT',
        geo_latitude REAL,
        geo_longitude REAL,
        device_created_at TEXT,
        synced_at TEXT,
        created_by TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory_ledger (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        cylinder_barcode TEXT,
        item_id TEXT,
        is_barcode_audited INTEGER DEFAULT 1,
        qty INTEGER NOT NULL,
        rental_price INTEGER,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE document_templates (
        id TEXT PRIMARY KEY,
        template_name TEXT NOT NULL,
        company_name TEXT NOT NULL,
        company_legal_name TEXT NOT NULL,
        company_address TEXT,
        company_phone TEXT,
        company_email TEXT,
        company_logo_path TEXT,
        document_title TEXT NOT NULL,
        number_prefix TEXT DEFAULT '',
        number_format TEXT DEFAULT '{SEQ}',
        label_subtotal TEXT,
        label_discount TEXT,
        label_down_payment TEXT,
        label_tax_base TEXT,
        label_tax TEXT,
        label_grand_total TEXT,
        tax_percentage REAL,
        bank_accounts TEXT, -- JSON string
        footer_note TEXT,
        customer_service_label TEXT,
        customer_service_contact TEXT,
        signatory_city TEXT,
        signatory_name TEXT,
        signatory_title TEXT,
        show_unit_column INTEGER DEFAULT 1,
        show_po_field INTEGER DEFAULT 1,
        show_npwp_field INTEGER DEFAULT 1,
        show_period_notes INTEGER DEFAULT 1,
        show_reference_notes INTEGER DEFAULT 1,
        show_prices INTEGER DEFAULT 1,
        show_driver_info INTEGER DEFAULT 0,
        rules_text TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // ── Indexes for Related List queries ────────────────────────────
    await db.execute(
        'CREATE INDEX idx_pl_customer ON customer_pricelists(customer_id)');
    await db.execute(
        'CREATE INDEX idx_pl_item ON customer_pricelists(item_id)');
    await db.execute(
        'CREATE INDEX idx_assets_customer ON assets(current_customer_id)');
    await db.execute(
        'CREATE INDEX idx_assets_item ON assets(item_id)');
    await db.execute(
        'CREATE INDEX idx_txn_customer ON transaction_documents(customer_id)');
    await db.execute(
        'CREATE INDEX idx_ledger_doc ON inventory_ledger(document_id)');
    await db.execute(
        'CREATE INDEX idx_ledger_barcode ON inventory_ledger(cylinder_barcode)');

    // ── Seed ────────────────────────────────────────────────────────
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final batch = db.batch();

    for (final item in SeedData.items) {
      batch.insert('items', item);
    }
    for (final cust in SeedData.customers) {
      batch.insert('customers', cust);
    }
    for (final pl in SeedData.pricelists) {
      batch.insert('customer_pricelists', pl);
    }
    for (final asset in SeedData.assets) {
      batch.insert('assets', asset);
    }
    for (final template in SeedData.documentTemplates) {
      batch.insert('document_templates', template);
    }

    await batch.commit(noResult: true);
  }

  // ── Generic CRUD Helpers ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<int> insert(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Reset database (for testing purposes)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}${Platform.pathSeparator}akg_master.db';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    _database = await _initDatabase();
  }
}
