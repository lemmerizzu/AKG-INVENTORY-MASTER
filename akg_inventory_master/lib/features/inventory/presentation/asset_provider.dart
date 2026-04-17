import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/asset.dart';

// ── Mock Asset Data (sample from CSV — representative subset) ─────────────

final _mockAssets = [
  // Oksigen 1m3
  Asset(id: 'a-001', barcode: '683269185', serialNumber: '0003', itemId: 'e8544a46', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2025, 8, 13)),
  Asset(id: 'a-002', barcode: '', serialNumber: '0005', itemId: 'e8544a46', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2025, 8, 13)),
  Asset(id: 'a-003', barcode: '683328637', serialNumber: '0006', itemId: 'e8544a46', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2025, 8, 13)),

  // Oksigen 6m3 (biggest group)
  Asset(id: 'a-010', barcode: '673544971', serialNumber: '1101', itemId: '8bdbe149', currentCustomerId: 'ba97d58d', status: AssetStatus.rented, cycleCount: 5, lastActionDate: DateTime(2025, 9, 13)),
  Asset(id: 'a-011', barcode: '682458205', serialNumber: '1102', itemId: '8bdbe149', currentCustomerId: '1c4d5e93', status: AssetStatus.rented, cycleCount: 3, lastActionDate: DateTime(2025, 11, 22)),
  Asset(id: 'a-012', barcode: '', serialNumber: '1103', itemId: '8bdbe149', currentCustomerId: '01158be1', status: AssetStatus.rented),
  Asset(id: 'a-013', barcode: '672403145', serialNumber: '1105', itemId: '8bdbe149', currentCustomerId: 'a0f0ad2d', status: AssetStatus.rented, cycleCount: 2, lastActionDate: DateTime(2025, 9, 8)),
  Asset(id: 'a-014', barcode: '682359357', serialNumber: '1109', itemId: '8bdbe149', currentCustomerId: 'AKGREADY', cycleCount: 4, lastActionDate: DateTime(2025, 11, 5)),
  Asset(id: 'a-015', barcode: 'No barcode', serialNumber: '1114', itemId: '8bdbe149', currentCustomerId: '01158be1', status: AssetStatus.rented, lastActionDate: DateTime(2026, 2, 19)),
  Asset(id: 'a-016', barcode: '683327151', serialNumber: '1134', itemId: '8bdbe149', currentCustomerId: '9e66ced9', status: AssetStatus.rented, cycleCount: 1, lastActionDate: DateTime(2025, 9, 11)),
  Asset(id: 'a-017', barcode: '682457181', serialNumber: '1157', itemId: '8bdbe149', currentCustomerId: 'AKGREADY', cycleCount: 6, lastActionDate: DateTime(2026, 3, 13)),
  Asset(id: 'a-018', barcode: 'NOT ASIGNED YET', serialNumber: '1125', itemId: '8bdbe149', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2026, 1, 21)),

  // Oksigen 7m3
  Asset(id: 'a-030', barcode: '673539827', serialNumber: '11135', itemId: '7d2764f1', currentCustomerId: '7b9d8eba', status: AssetStatus.rented, cycleCount: 2, lastActionDate: DateTime(2025, 9, 11)),
  Asset(id: 'a-031', barcode: '683330711', serialNumber: '11139', itemId: '7d2764f1', currentCustomerId: '01158be1', status: AssetStatus.rented, lastActionDate: DateTime(2026, 2, 11)),
  Asset(id: 'a-032', barcode: '683321458', serialNumber: '11144', itemId: '7d2764f1', currentCustomerId: 'AKGREADY', cycleCount: 3, lastActionDate: DateTime(2025, 8, 13)),
  Asset(id: 'a-033', barcode: 'No Barcode', serialNumber: '11313', itemId: '7d2764f1', currentCustomerId: '9828dfc5', status: AssetStatus.rented, lastActionDate: DateTime(2026, 3, 7)),

  // Argon 6m3
  Asset(id: 'a-050', barcode: 'Di alihkan N2', serialNumber: '12001', itemId: '66af7c72', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2026, 1, 31)),
  Asset(id: 'a-051', barcode: '683271728', serialNumber: '12002', itemId: '66af7c72', currentCustomerId: '17a8e612', status: AssetStatus.rented, cycleCount: 1, lastActionDate: DateTime(2025, 9, 29)),
  Asset(id: 'a-052', barcode: '683275070', serialNumber: '12005', itemId: '66af7c72', currentCustomerId: '01158be1', status: AssetStatus.rented, lastActionDate: DateTime(2026, 2, 19)),
  Asset(id: 'a-053', barcode: '683271791', serialNumber: '12055', itemId: '66af7c72', currentCustomerId: 'AKGREADY', cycleCount: 2, lastActionDate: DateTime(2025, 8, 30)),

  // Karbondioksida (CO2)
  Asset(id: 'a-070', barcode: '683319204', serialNumber: '13003', itemId: 'ef306e54', currentCustomerId: '1c4d5e93', status: AssetStatus.rented, cycleCount: 1, lastActionDate: DateTime(2025, 9, 22)),
  Asset(id: 'a-071', barcode: '683330702', serialNumber: '13004', itemId: 'ef306e54', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2025, 8, 29)),
  Asset(id: 'a-072', barcode: '', serialNumber: '13009', itemId: 'ef306e54', currentCustomerId: 'e86baf3b', status: AssetStatus.rented),

  // Nitrogen
  Asset(id: 'a-090', barcode: '696407235', serialNumber: '14001', itemId: 'a50ce892', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2026, 1, 10)),
  Asset(id: 'a-091', barcode: '2026000464', serialNumber: '14002', itemId: 'a50ce892', currentCustomerId: 'd9b2fac5', status: AssetStatus.rented, lastActionDate: DateTime(2026, 1, 28)),
  Asset(id: 'a-092', barcode: 'No Barcode', serialNumber: '14006', itemId: 'a50ce892', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2026, 3, 14)),

  // LPG 12kg (Exchange type)
  Asset(id: 'a-100', barcode: '000012', serialNumber: 'L001', itemId: 'be525f3b', type: AssetType.exchange, currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2026, 1, 10)),
  Asset(id: 'a-101', barcode: '000015', serialNumber: 'L004', itemId: 'be525f3b', type: AssetType.exchange, currentCustomerId: 'eec2e801', status: AssetStatus.rented, lastActionDate: DateTime(2026, 1, 10)),
  Asset(id: 'a-102', barcode: '000016', serialNumber: 'L005', itemId: 'be525f3b', type: AssetType.exchange, currentCustomerId: '98c84274', status: AssetStatus.rented, lastActionDate: DateTime(2026, 1, 10)),

  // LPG 50kg (Exchange type)
  Asset(id: 'a-110', barcode: '0001', serialNumber: 'LL001', itemId: 'b7a8fff1', type: AssetType.exchange, currentCustomerId: 'f7243d00', status: AssetStatus.rented, lastActionDate: DateTime(2026, 1, 10)),
  Asset(id: 'a-111', barcode: '0002', serialNumber: 'LL002', itemId: 'b7a8fff1', type: AssetType.exchange, currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2026, 1, 10)),

  // Acetyline
  Asset(id: 'a-120', barcode: '778890', serialNumber: '7001', itemId: '3b9d6a30', currentCustomerId: 'e86baf3b', status: AssetStatus.rented, adminNotes: 'No Baru', lastActionDate: DateTime(2026, 1, 8)),
  Asset(id: 'a-121', barcode: '2026000500', serialNumber: '7003', itemId: '3b9d6a30', currentCustomerId: '89d46c39', status: AssetStatus.rented, lastActionDate: DateTime(2026, 1, 24)),
  Asset(id: 'a-122', barcode: 'BAS', serialNumber: '7814', itemId: '3b9d6a30', currentCustomerId: 'AKGREADY', lastActionDate: DateTime(2026, 3, 11)),

  // Maintenance example 
  Asset(id: 'a-200', barcode: '1448243232', serialNumber: '56', itemId: '8bdbe149', currentCustomerId: 'AKGREADY', status: AssetStatus.maintenance, adminNotes: 'sementara', lastActionDate: DateTime(2026, 2, 6)),
];

// ── Provider ──────────────────────────────────────────────────────────────

final assetListProvider = NotifierProvider<AssetListNotifier, List<Asset>>(
  AssetListNotifier.new,
);

class AssetListNotifier extends Notifier<List<Asset>> {
  @override
  List<Asset> build() => [..._mockAssets];

  void addAsset(Asset asset) {
    state = [...state, asset];
  }

  void updateAsset(String id, Asset updated) {
    state = [
      for (final a in state)
        if (a.id == id) updated else a,
    ];
  }

  void updateStatus(String id, AssetStatus newStatus, {String? customerId}) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(
            status: newStatus,
            currentCustomerId: customerId ?? a.currentCustomerId,
            cycleCount: (newStatus == AssetStatus.rented || newStatus == AssetStatus.availableEmpty)
                ? a.cycleCount + 1
                : a.cycleCount,
            lastActionDate: DateTime.now(),
          )
        else
          a,
    ];
  }

  /// Mark as lost → auto forced sale
  void markAsLost(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(
            status: AssetStatus.lost,
            lastActionDate: DateTime.now(),
          )
        else
          a,
    ];
  }

  void sellAsset(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(
            status: AssetStatus.sold,
            lastActionDate: DateTime.now(),
          )
        else
          a,
    ];
  }

  void deactivate(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(isActive: false) else a,
    ];
  }

  Asset? getByBarcode(String barcode) {
    try {
      return state.firstWhere((a) => a.barcode == barcode && a.isActive);
    } catch (_) {
      return null;
    }
  }

  List<Asset> getByStatus(AssetStatus status) =>
      state.where((a) => a.status == status && a.isActive).toList();

  List<Asset> getByItemId(String itemId) =>
      state.where((a) => a.itemId == itemId && a.isActive).toList();

  List<Asset> getUnaudited() =>
      state.where((a) => !a.isBarcodeAudited && a.isActive).toList();
}
