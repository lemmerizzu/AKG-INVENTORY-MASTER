import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/theme.dart';
import 'core/database_helper.dart';
import 'shared/widgets/dashboard_shell.dart';
import 'shared/widgets/placeholder_page.dart';
import 'features/customer/presentation/customer_page_layout.dart';
import 'features/transaction/presentation/transaction_form_view.dart';
import 'features/transaction/presentation/pages/transaction_log_page.dart';
import 'features/inventory/presentation/asset_page_layout.dart';
import 'features/document_print/presentation/print_server_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for Windows/Linux desktop
  if (Platform.isWindows || Platform.isLinux) {
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
          NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            page: const PlaceholderPage(
              title: 'Dashboard',
              icon: Icons.dashboard_outlined,
              description: 'Overview, grafik, dan ringkasan bisnis.',
            ),
          ),
          const NavItem(
            icon: Icons.swap_horiz,
            label: 'Input Transaksi',
            page: TransactionFormView(),
          ),
          const NavItem(
            icon: Icons.history,
            label: 'Log Transaksi',
            page: TransactionLogPage(),
          ),
          const NavItem(
            icon: Icons.people_outline,
            label: 'Customer',
            page: CustomerPageLayout(),
          ),
          const NavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            page: AssetPageLayout(),
          ),
          NavItem(
            icon: Icons.receipt_long_outlined,
            label: 'Faktur',
            page: const PlaceholderPage(
              title: 'Faktur & Penagihan',
              icon: Icons.receipt_long_outlined,
              description: 'Buat invoice, cetak faktur, dan kelola piutang.',
            ),
          ),
          const NavItem(
            icon: Icons.print_outlined,
            label: 'Cetak Dokumen',
            page: PrintServerView(),
          ),
          NavItem(
            icon: Icons.settings_outlined,
            label: 'Pengaturan',
            page: const PlaceholderPage(
              title: 'Pengaturan',
              icon: Icons.settings_outlined,
              description: 'Template dokumen, akun bank, dan konfigurasi.',
            ),
          ),
        ],
      ),
    );
  }
}
