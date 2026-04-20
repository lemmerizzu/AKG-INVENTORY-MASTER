import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';
import '../../../shared/widgets/ak_badge.dart';
import '../../../shared/widgets/ak_section_header.dart';
import '../domain/asset.dart';
import 'asset_provider.dart';
import 'item_master_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AssetListView — Left pane of the inventory split-pane layout
/// Phase 4 — SQLite-backed, AppColors aligned
/// ─────────────────────────────────────────────────────────────────────────────
class AssetListView extends ConsumerStatefulWidget {
  const AssetListView({super.key});

  @override
  ConsumerState<AssetListView> createState() => _AssetListViewState();
}

class _AssetListViewState extends ConsumerState<AssetListView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredAssetProvider);
    final allAsync = ref.watch(assetListProvider);
    final filter = ref.watch(assetFilterProvider);
    final selected = ref.watch(selectedAssetIdProvider);

    final total = allAsync.value?.where((a) => a.isActive).length ?? 0;
    final unauditedCount = allAsync.value
            ?.where((a) => a.isActive && !a.isBarcodeAudited)
            .length ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Panel Header ────────────────────────────────────────────
        AkPanelHeader(
          title: 'Aset Operasional',
          trailing: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.filterBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$total',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AkIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
              onTap: () => ref.read(assetListProvider.notifier).refresh(),
            ),
          ],
        ),

        // ── Search Box ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(fontSize: 13),
            onChanged: (v) =>
                ref.read(assetFilterProvider.notifier).setSearch(v),
            decoration: InputDecoration(
              hintText: 'Cari serial / barcode...',
              hintStyle: GoogleFonts.inter(
                  color: AppColors.textDisabled, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 18, color: AppColors.textDisabled),
              suffixIcon: filter.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          size: 16, color: AppColors.textDisabled),
                      onPressed: () {
                        _searchCtrl.clear();
                        ref.read(assetFilterProvider.notifier).setSearch('');
                      })
                  : null,
              filled: true,
              fillColor: AppColors.pageBg,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    const BorderSide(color: AppColors.googleBlue, width: 1.5),
              ),
            ),
          ),
        ),

        // ── Status Filter Chips ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(
                  label: 'Semua',
                  active: !filter.hasActiveFilter,
                  onTap: () =>
                      ref.read(assetFilterProvider.notifier).clearAll(),
                ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: 'READY',
                  dotColor: AppColors.googleGreen,
                  active: filter.status == AssetStatus.availableFull,
                  onTap: () => ref
                      .read(assetFilterProvider.notifier)
                      .setStatus(AssetStatus.availableFull),
                ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: 'RENTED',
                  dotColor: AppColors.googleBlue,
                  active: filter.status == AssetStatus.rented,
                  onTap: () => ref
                      .read(assetFilterProvider.notifier)
                      .setStatus(AssetStatus.rented),
                ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: 'MAINT',
                  dotColor: AppColors.googleYellow,
                  active: filter.status == AssetStatus.maintenance,
                  onTap: () => ref
                      .read(assetFilterProvider.notifier)
                      .setStatus(AssetStatus.maintenance),
                ),
                const SizedBox(width: 6),
                _StatusChip(
                  label: '⚠ Unaudited ($unauditedCount)',
                  dotColor: AppColors.googleOrange,
                  active: filter.unauditedOnly,
                  onTap: () => ref
                      .read(assetFilterProvider.notifier)
                      .setUnaudited(!filter.unauditedOnly),
                ),
              ],
            ),
          ),
        ),

        // ── List ─────────────────────────────────────────────────────
        Expanded(
          child: filteredAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style: GoogleFonts.inter(color: AppColors.errorRed)),
            ),
            data: (assets) {
              if (assets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.propane_tank_outlined,
                          size: 36, color: AppColors.textDisabled),
                      const SizedBox(height: 10),
                      Text(
                        filter.hasActiveFilter
                            ? 'Tidak ada aset dengan filter ini'
                            : 'Belum ada aset',
                        style: GoogleFonts.inter(
                          color: AppColors.textDisabled,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: assets.length,
                itemBuilder: (_, i) {
                  final asset = assets[i];
                  final itemName = ref
                          .read(itemListProvider)
                          .value
                          ?.where((it) => it.id == asset.itemId)
                          .firstOrNull
                          ?.name ??
                      asset.itemId;
                  return _AssetListItem(
                    asset: asset,
                    itemName: itemName,
                    isSelected: selected == asset.id,
                    onTap: () => ref
                        .read(selectedAssetIdProvider.notifier)
                        .select(asset.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Asset List Item ───────────────────────────────────────────────────────────
class _AssetListItem extends StatefulWidget {
  final Asset asset;
  final String itemName;
  final bool isSelected;
  final VoidCallback onTap;

  const _AssetListItem({
    required this.asset,
    required this.itemName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AssetListItem> createState() => _AssetListItemState();
}

class _AssetListItemState extends State<_AssetListItem> {
  bool _hovering = false;

  Color get _statusDot {
    switch (widget.asset.status) {
      case AssetStatus.availableFull:
        return AppColors.googleGreen;
      case AssetStatus.availableEmpty:
        return AppColors.textDisabled;
      case AssetStatus.rented:
        return AppColors.googleBlue;
      case AssetStatus.sold:
        return Colors.purple;
      case AssetStatus.lost:
        return AppColors.errorRed;
      case AssetStatus.maintenance:
        return AppColors.googleYellow;
      case AssetStatus.retired:
        return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.isSelected) {
      bg = AppColors.selectedBg;
    } else if (_hovering) {
      bg = AppColors.dividerColor;
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.dividerColor, width: 1),
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
                  color: _statusDot,
                ),
              ),
              const SizedBox(width: 12),

              // Center: serial + item name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SN: ${widget.asset.serialNumber}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (!widget.asset.isBarcodeAudited) ...[
                          const SizedBox(width: 4),
                           Icon(Icons.warning_amber_rounded,
                              size: 14, color: AppColors.googleOrange),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.itemName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (widget.asset.cycleCount > 0)
                      Text(
                        '${widget.asset.cycleCount}x siklus',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textDisabled,
                        ),
                      ),
                  ],
                ),
              ),

              // Right: status badge + barcode audited indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AkBadge.assetStatus(_statusLabel(widget.asset.status)),
                  if (widget.asset.barcode.isNotEmpty &&
                      widget.asset.isBarcodeAudited) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.qr_code_rounded,
                            size: 10, color: AppColors.textDisabled),
                        const SizedBox(width: 2),
                        Text(
                          widget.asset.barcode.substring(
                              0,
                              widget.asset.barcode.length > 8
                                  ? 8
                                  : widget.asset.barcode.length),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(AssetStatus s) {
    switch (s) {
      case AssetStatus.availableFull:
        return 'READY';
      case AssetStatus.availableEmpty:
        return 'EMPTY';
      case AssetStatus.rented:
        return 'RENTED';
      case AssetStatus.sold:
        return 'SOLD';
      case AssetStatus.lost:
        return 'LOST';
      case AssetStatus.maintenance:
        return 'MAINT';
      case AssetStatus.retired:
        return 'RETIRED';
    }
  }
}

// ── Status Filter Chip ────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final bool active;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    this.dotColor,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.googleBlue : AppColors.filterBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppColors.googleBlue : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? Colors.white : dotColor!,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
