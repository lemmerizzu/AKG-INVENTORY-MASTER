import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'shared/widgets/dashboard_shell.dart';
import 'shared/widgets/placeholder_page.dart';
import 'features/transaction/presentation/transaction_page_layout.dart';
import 'features/transaction/presentation/pages/transaction_log_page.dart';

void main() {
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
            page: TransactionPageLayout(),
          ),
          const NavItem(
            icon: Icons.history,
            label: 'Log Transaksi',
            page: TransactionLogPage(),
          ),
          NavItem(
            icon: Icons.people_outline,
            label: 'Customer',
            page: const PlaceholderPage(
              title: 'Customer Master',
              icon: Icons.people_outline,
              description: 'Kelola data pelanggan, pricelist, dan termin.',
            ),
          ),
          NavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            page: const PlaceholderPage(
              title: 'Inventory & Aset',
              icon: Icons.inventory_2_outlined,
              description: 'Tracking tabung, status aset, dan cycle count.',
            ),
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
          NavItem(
            icon: Icons.print_outlined,
            label: 'Cetak Dokumen',
            page: const PlaceholderPage(
              title: 'Cetak Dokumen',
              icon: Icons.print_outlined,
              description: 'Cetak Faktur, Surat Jalan, dan dokumen lain.',
            ),
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
