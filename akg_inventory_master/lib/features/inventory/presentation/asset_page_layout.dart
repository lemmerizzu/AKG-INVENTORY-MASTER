import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';
import 'asset_list_view.dart';
import 'asset_detail_view.dart';
import 'fixed_asset_form.dart';
import 'item_master_view.dart';
import 'inventory_audit_view.dart';
import 'asset_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AssetPageLayout — 3-Tab + AppSheet 3-pane layout
/// Phase 4 — SQLite-First, AppColors aligned
/// Tabs: [Aset Operasional (Split-Pane)] | [Aset Tetap] | [Master SKU]
/// ─────────────────────────────────────────────────────────────────────────────
class AssetPageLayout extends ConsumerStatefulWidget {
  const AssetPageLayout({super.key});

  @override
  ConsumerState<AssetPageLayout> createState() => _AssetPageLayoutState();
}

class _AssetPageLayoutState extends ConsumerState<AssetPageLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          // ── Tab Header ─────────────────────────────────────────────
          Container(
            color: AppColors.panelBg,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.googleBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.googleBlue,
              indicatorWeight: 2,
              labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(Icons.propane_tank_outlined, size: 16),
                  text: 'Aset Operasional',
                ),
                Tab(
                  icon: Icon(Icons.business_center_outlined, size: 16),
                  text: 'Aset Tetap',
                ),
                Tab(
                  icon: Icon(Icons.category_outlined, size: 16),
                  text: 'Master SKU',
                ),
                Tab(
                  icon: Icon(Icons.inventory_rounded, size: 16),
                  text: 'Audit Inventori',
                ),
              ],
            ),
          ),

          // ── Tab Content ────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ── Tab 1: Operational Assets (Split-Pane) ──────────
                _OperationalAssetPane(),

                // ── Tab 2: Fixed Assets ─────────────────────────────
                const FixedAssetForm(),

                // ── Tab 3: Item Master ──────────────────────────────
                const ItemMasterView(),

                // ── Tab 4: Inventory Audit ──────────────────────────
                const InventoryAuditView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Operational Asset 3-Pane ──────────────────────────────────────────────────
class _OperationalAssetPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedAssetIdProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: Master List 480px
        Container(
          width: 480,
          decoration: const BoxDecoration(
            color: AppColors.panelBg,
            border: Border(
              right: BorderSide(color: AppColors.borderColor, width: 1),
            ),
          ),
          child: const AssetListView(),
        ),

        // Right: Detail or Empty
        Expanded(
          child: selectedId == null
              ? const _EmptyAssetPlaceholder()
              : AssetDetailView(assetId: selectedId),
        ),
      ],
    );
  }
}

// ── Empty Detail Placeholder ──────────────────────────────────────────────────
class _EmptyAssetPlaceholder extends StatelessWidget {
  const _EmptyAssetPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pageBg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.panelBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(
                Icons.propane_tank_outlined,
                size: 48,
                color: AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih aset',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Klik salah satu aset dari daftar kiri\nuntuk melihat detail dan history',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
