import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../domain/asset.dart';
import 'asset_provider.dart';
import 'item_master_provider.dart';

/// Left panel: Search, filter chips, and asset card list.
class AssetListView extends ConsumerStatefulWidget {
  final String? selectedAssetId;
  final ValueChanged<String> onAssetSelected;

  const AssetListView({
    super.key,
    this.selectedAssetId,
    required this.onAssetSelected,
  });

  @override
  ConsumerState<AssetListView> createState() => _AssetListViewState();
}

class _AssetListViewState extends ConsumerState<AssetListView> {
  String _searchQuery = '';
  AssetStatus? _statusFilter;
  bool _showUnauditedOnly = false;

  @override
  Widget build(BuildContext context) {
    final allAssets = ref.watch(assetListProvider);

    // Apply filters
    var filtered = allAssets.where((a) => a.isActive && a.category == AssetCategory.currentAsset).toList();

    if (_showUnauditedOnly) {
      filtered = filtered.where((a) => !a.isBarcodeAudited).toList();
    } else if (_statusFilter != null) {
      filtered = filtered.where((a) => a.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((a) =>
          a.serialNumber.toLowerCase().contains(q) ||
          a.barcode.toLowerCase().contains(q) ||
          a.itemId.toLowerCase().contains(q)).toList();
    }

    final unauditedCount = allAssets.where((a) => a.isActive && !a.isBarcodeAudited).length;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari Serial / Barcode...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('All', null, filtered.length),
                _filterChip('🟢 Full', AssetStatus.availableFull, null),
                _filterChip('🔵 Rented', AssetStatus.rented, null),
                _filterChip('🟡 Maint', AssetStatus.maintenance, null),
                _filterChip('🔴 Sold', AssetStatus.sold, null),
                _unauditedChip(unauditedCount),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('${filtered.length} aset',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Asset List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('Tidak ada aset ditemukan',
                        style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 13)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final asset = filtered[i];
                      final isSelected = asset.id == widget.selectedAssetId;
                      final itemName = ref.read(itemListProvider).where((it) => it.id == asset.itemId).firstOrNull?.name ?? asset.itemId;
                      return _AssetCard(
                        asset: asset,
                        itemName: itemName,
                        isSelected: isSelected,
                        onTap: () => widget.onAssetSelected(asset.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, AssetStatus? status, int? count) {
    final isActive = !_showUnauditedOnly && _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
        selected: isActive,
        selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
        backgroundColor: AppTheme.background,
        side: BorderSide.none,
        onSelected: (_) => setState(() {
          _statusFilter = status;
          _showUnauditedOnly = false;
        }),
      ),
    );
  }

  Widget _unauditedChip(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            Text('Unaudited ($count)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        selected: _showUnauditedOnly,
        selectedColor: Colors.orange.withValues(alpha: 0.15),
        backgroundColor: AppTheme.background,
        side: BorderSide.none,
        onSelected: (_) => setState(() {
          _showUnauditedOnly = !_showUnauditedOnly;
          _statusFilter = null;
        }),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Asset asset;
  final String itemName;
  final bool isSelected;
  final VoidCallback onTap;

  const _AssetCard({
    required this.asset,
    required this.itemName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.primaryBlue.withValues(alpha: 0.08)
          : AppTheme.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor(asset.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('SN: ${asset.serialNumber}',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        if (!asset.isBarcodeAudited) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.warning_amber,
                              size: 14, color: Colors.orange),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(itemName,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ),
              _StatusBadge(status: asset.status),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(AssetStatus s) {
    switch (s) {
      case AssetStatus.availableFull:
        return const Color(0xFF00C853);
      case AssetStatus.availableEmpty:
        return Colors.grey;
      case AssetStatus.rented:
        return AppTheme.primaryBlue;
      case AssetStatus.sold:
        return Colors.purple;
      case AssetStatus.lost:
        return AppTheme.error;
      case AssetStatus.maintenance:
        return Colors.orange;
      case AssetStatus.retired:
        return Colors.brown;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final AssetStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AssetStatus.availableFull => ('READY', const Color(0xFF00C853)),
      AssetStatus.availableEmpty => ('EMPTY', Colors.grey),
      AssetStatus.rented => ('RENTED', AppTheme.primaryBlue),
      AssetStatus.sold => ('SOLD', Colors.purple),
      AssetStatus.lost => ('LOST', AppTheme.error),
      AssetStatus.maintenance => ('MAINT', Colors.orange),
      AssetStatus.retired => ('RETIRED', Colors.brown),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
