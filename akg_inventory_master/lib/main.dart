import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import 'core/theme.dart';
import 'core/database_helper.dart';
import 'shared/widgets/dashboard_shell.dart';
import 'shared/widgets/placeholder_page.dart';
import 'features/customer/presentation/customer_page_layout.dart';
import 'features/transaction/presentation/pages/transaction_log_page.dart';
import 'features/inventory/presentation/asset_page_layout.dart';
import 'features/document_print/presentation/print_server_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase (CRITICAL FOR PRINT SERVER)
  // TODO: Replace with your actual project credentials
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key',
  );

  // Initialize SQLite FFI for Windows/Linux desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Pre-initialize database (creates tables + seeds on first run)
  await DatabaseHelper.instance.database;

  runApp(
    const ProviderScope(
      child: AkgMasterApp(),
    ),
  );
}

class AkgMasterApp extends StatelessWidget {
  const AkgMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AKG Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: DashboardShell(
        navItems: [
          // ── Figma sidebar icon order (top to bottom) ──────────
          // 1. Dokumen / Transaksi (analytics-plus icon — active in Figma)
          const NavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Transactions',
            page: TransactionLogPage(),
          ),
          // 2. Customer (people icon)
          const NavItem(
            icon: Icons.people_outline_rounded,
            label: 'Customer',
            page: CustomerPageLayout(),
          ),
          // 4. Inventory (link/chain → inventory)
          const NavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            page: AssetPageLayout(),
          ),
          // 5. Faktur (dollar/money icon)
          NavItem(
            icon: Icons.attach_money_rounded,
            label: 'Faktur',
            page: const PlaceholderPage(
              title: 'Faktur & Penagihan',
              icon: Icons.attach_money_rounded,
              description: 'Buat invoice, cetak faktur, dan kelola piutang.',
            ),
          ),
          // 6. Cetak Dokumen (receipt icon)
          const NavItem(
            icon: Icons.receipt_long_outlined,
            label: 'Cetak Dokumen',
            page: PrintServerView(),
          ),
          // 7. Pengaturan (person/user icon → settings)
          NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profil & Pengaturan',
            page: const PlaceholderPage(
              title: 'Pengaturan',
              icon: Icons.person_outline_rounded,
              description: 'Template dokumen, akun bank, dan konfigurasi.',
            ),
          ),
          // 8. Info/Help (info icon)
          NavItem(
            icon: Icons.info_outline_rounded,
            label: 'Bantuan',
            page: const PlaceholderPage(
              title: 'Bantuan',
              icon: Icons.info_outline_rounded,
              description: 'Panduan penggunaan dan FAQ.',
            ),
          ),
        ],
      ),
    );
  }
}
