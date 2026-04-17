import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../domain/asset.dart';
import 'asset_provider.dart';
import 'item_master_provider.dart';

/// Right panel: full detail of a selected asset + action buttons.
class AssetDetailView extends ConsumerWidget {
  final String assetId;
  const AssetDetailView({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetListProvider);
    final asset = assets.where((a) => a.id == assetId).firstOrNull;

    if (asset == null) {
      return const Center(child: Text('Aset tidak ditemukan'));
    }

    final items = ref.watch(itemListProvider).value ?? [];
    final item = items.where((i) => i.id == asset.itemId).firstOrNull;
    final notifier = ref.read(assetListProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.propane_tank,
                    color: AppTheme.primaryBlue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SN: ${asset.serialNumber}',
                        style: GoogleFonts.outfit(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item?.name ?? asset.itemId,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppTheme.textLight)),
                  ],
                ),
              ),
              _buildStatusChip(asset.status),
            ],
          ),

          const SizedBox(height: 12),

          // Unaudited alert bar
          if (!asset.isBarcodeAudited)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Barcode belum diaudit — "${asset.barcode.isEmpty ? '(kosong)' : asset.barcode}"',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 32),

          // Detail Grid
          _buildSection('Informasi Aset', [
            _detailRow('Barcode', asset.barcode.isEmpty ? '—' : asset.barcode),
            _detailRow('Serial Number', asset.serialNumber),
            _detailRow('SKU', '${item?.itemCode ?? '-'} — ${item?.name ?? '-'}'),
            _detailRow('Tipe', _typeLabel(asset.type)),
            _detailRow('Kategori', asset.category == AssetCategory.currentAsset ? 'Aset Lancar' : 'Aset Tetap'),
          ]),

          const SizedBox(height: 24),

          _buildSection('Status & Lokasi', [
            _detailRow('Status', _statusLabel(asset.status)),
            _detailRow('Lokasi / Customer', asset.isInWarehouse ? '🏭 Gudang (AKGREADY)' : '📦 ${asset.currentCustomerId ?? '-'}'),
            _detailRow('Cycle Count', '${asset.cycleCount} siklus'),
            _detailRow('Terakhir Diperbarui', asset.lastActionDate != null
                ? '${asset.lastActionDate!.day}/${asset.lastActionDate!.month}/${asset.lastActionDate!.year}'
                : '—'),
          ]),

          if (asset.adminNotes != null && asset.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSection('Catatan Admin', [
              _detailRow('Notes', asset.adminNotes!),
            ]),
          ],

          const SizedBox(height: 32),

          // Action Buttons
          Text('Aksi', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (asset.status == AssetStatus.availableFull)
                _actionButton(
                  icon: Icons.local_shipping,
                  label: 'Rentalkan',
                  color: AppTheme.primaryBlue,
                  onTap: () => notifier.updateStatus(asset.id, AssetStatus.rented),
                ),
              if (asset.status == AssetStatus.rented) ...[
                _actionButton(
                  icon: Icons.keyboard_return,
                  label: 'Kembalikan',
                  color: const Color(0xFF00C853),
                  onTap: () => notifier.updateStatus(
                      asset.id, AssetStatus.availableEmpty,
                      customerId: Asset.warehouseId),
                ),
                _actionButton(
                  icon: Icons.error_outline,
                  label: 'Hilang (Forced Sale)',
                  color: AppTheme.error,
                  onTap: () => notifier.markAsLost(asset.id),
                ),
              ],
              if (asset.status == AssetStatus.availableFull ||
                  asset.status == AssetStatus.availableEmpty)
                _actionButton(
                  icon: Icons.sell,
                  label: 'Jual',
                  color: Colors.purple,
                  onTap: () => notifier.sellAsset(asset.id),
                ),
              if (asset.status == AssetStatus.availableFull ||
                  asset.status == AssetStatus.availableEmpty)
                _actionButton(
                  icon: Icons.build_outlined,
                  label: 'Maintenance',
                  color: Colors.orange,
                  onTap: () => notifier.updateStatus(asset.id, AssetStatus.maintenance),
                ),
              if (asset.status == AssetStatus.maintenance)
                _actionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Selesai Perbaikan',
                  color: const Color(0xFF00C853),
                  onTap: () => notifier.updateStatus(asset.id, AssetStatus.availableFull),
                ),
              _actionButton(
                icon: Icons.print_outlined,
                label: 'Print Label',
                color: AppTheme.textLight,
                onTap: () {},
              ),
              _actionButton(
                icon: Icons.delete_outline,
                label: 'Deactivate',
                color: AppTheme.error,
                onTap: () => notifier.deactivate(asset.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStatusChip(AssetStatus status) {
    final (label, color) = switch (status) {
      AssetStatus.availableFull => ('READY', const Color(0xFF00C853)),
      AssetStatus.availableEmpty => ('EMPTY', Colors.grey),
      AssetStatus.rented => ('RENTED', AppTheme.primaryBlue),
      AssetStatus.sold => ('SOLD', Colors.purple),
      AssetStatus.lost => ('LOST', AppTheme.error),
      AssetStatus.maintenance => ('MAINTENANCE', Colors.orange),
      AssetStatus.retired => ('RETIRED', Colors.brown),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  String _typeLabel(AssetType t) => switch (t) {
        AssetType.rent => 'Rental',
        AssetType.exchange => 'Tukar Tabung',
        AssetType.sell => 'Jual Putus',
      };

  String _statusLabel(AssetStatus s) => switch (s) {
        AssetStatus.availableFull => 'Available (Full/Ready)',
        AssetStatus.availableEmpty => 'Available (Empty/Perlu Isi)',
        AssetStatus.rented => 'Sedang Dirental',
        AssetStatus.sold => 'Terjual',
        AssetStatus.lost => 'Hilang (Forced Sale)',
        AssetStatus.maintenance => 'Dalam Perbaikan',
        AssetStatus.retired => 'Tidak Layak Pakai',
      };
}
