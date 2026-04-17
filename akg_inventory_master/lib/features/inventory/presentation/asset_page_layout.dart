import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import 'asset_list_view.dart';
import 'asset_detail_view.dart';
import 'fixed_asset_form.dart';
import 'item_master_view.dart';


/// 3-Tab layout: Current Assets | Fixed Assets | Master SKU
class AssetPageLayout extends ConsumerStatefulWidget {
  const AssetPageLayout({super.key});

  @override
  ConsumerState<AssetPageLayout> createState() => _AssetPageLayoutState();
}

class _AssetPageLayoutState extends ConsumerState<AssetPageLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedAssetId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Tab Header ──
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.textLight,
              indicatorColor: AppTheme.primaryBlue,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(Icons.propane_tank_outlined, size: 18),
                  text: 'Aset Operasional',
                ),
                Tab(
                  icon: Icon(Icons.business_outlined, size: 18),
                  text: 'Aset Tetap',
                ),
                Tab(
                  icon: Icon(Icons.category_outlined, size: 18),
                  text: 'Master SKU',
                ),
              ],
            ),
          ),

          // ── Tab Content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Current/Operational Assets (Split-Pane)
                Row(
                  children: [
                    SizedBox(
                      width: 380,
                      child: AssetListView(
                        selectedAssetId: _selectedAssetId,
                        onAssetSelected: (id) =>
                            setState(() => _selectedAssetId = id),
                      ),
                    ),
                    Container(
                      width: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _selectedAssetId != null
                          ? AssetDetailView(assetId: _selectedAssetId!)
                          : _buildEmptyDetail(),
                    ),
                  ],
                ),

                // Tab 2: Fixed Assets
                const FixedAssetForm(),

                // Tab 3: Item Master
                const ItemMasterView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetail() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined,
              size: 56, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('Pilih aset dari daftar di sebelah kiri',
              style: GoogleFonts.inter(
                  color: AppTheme.textLight, fontSize: 14)),
        ],
      ),
    );
  }
}
