import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database_helper.dart';
import '../domain/asset.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Asset Repository (inline — thin wrapper over DatabaseHelper)
/// Phase 4 — SQLite-First architecture
/// ─────────────────────────────────────────────────────────────────────────────
class _AssetRepo {
  final _db = DatabaseHelper.instance;

  Future<List<Asset>> getAll({bool activeOnly = true}) async {
    final rows = await _db.query(
      'assets',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'item_id ASC, serial_number ASC',
    );
    return rows.map((r) => Asset.fromJson(r)).toList();
  }

  Future<Asset?> getById(String id) async {
    final rows = await _db.query('assets', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Asset.fromJson(rows.first);
  }

  Future<Asset?> getByBarcode(String barcode) async {
    final rows = await _db.query('assets',
        where: 'barcode = ? AND is_active = 1', whereArgs: [barcode]);
    if (rows.isEmpty) return null;
    return Asset.fromJson(rows.first);
  }

  Future<void> insert(Asset asset) async {
    await _db.insert('assets', asset.toJson());
  }

  Future<void> update(Asset asset) async {
    await _db.update('assets', asset.toJson(),
        where: 'id = ?', whereArgs: [asset.id]);
  }

  Future<void> updateStatus(
      String id, AssetStatus status, String? customerId) async {
    final now = DateTime.now().toIso8601String();
    final updates = <String, dynamic>{
      'status': _statusStr(status),
      'last_action_date': now,
    };
    if (customerId != null) updates['current_customer_id'] = customerId;
    await _db.update('assets', updates, where: 'id = ?', whereArgs: [id]);
  }

  static String _statusStr(AssetStatus s) {
    const m = {
      AssetStatus.availableFull: 'AVAILABLE_FULL',
      AssetStatus.availableEmpty: 'AVAILABLE_EMPTY',
      AssetStatus.rented: 'RENTED',
      AssetStatus.sold: 'SOLD',
      AssetStatus.lost: 'LOST',
      AssetStatus.maintenance: 'MAINTENANCE',
      AssetStatus.retired: 'RETIRED',
    };
    return m[s] ?? 'AVAILABLE_FULL';
  }
}

// ── Asset Filter State ────────────────────────────────────────────────────────

class AssetFilter {
  final AssetStatus? status;
  final String? itemId;
  final bool unauditedOnly;
  final String searchQuery;

  const AssetFilter({
    this.status,
    this.itemId,
    this.unauditedOnly = false,
    this.searchQuery = '',
  });

  bool get hasActiveFilter =>
      status != null || itemId != null || unauditedOnly || searchQuery.isNotEmpty;

  AssetFilter copyWith({
    AssetStatus? status,
    String? itemId,
    bool? unauditedOnly,
    String? searchQuery,
  }) =>
      AssetFilter(
        status: status,
        itemId: itemId ?? this.itemId,
        unauditedOnly: unauditedOnly ?? this.unauditedOnly,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

final assetFilterProvider =
    NotifierProvider<_AssetFilterNotifier, AssetFilter>(
        _AssetFilterNotifier.new);

class _AssetFilterNotifier extends Notifier<AssetFilter> {
  @override
  AssetFilter build() => const AssetFilter();

  void setStatus(AssetStatus? s) =>
      state = AssetFilter(status: s, unauditedOnly: false, searchQuery: state.searchQuery);
  void setItemId(String? id) =>
      state = state.copyWith(itemId: id);
  void setUnaudited(bool v) =>
      state = AssetFilter(unauditedOnly: v, searchQuery: state.searchQuery);
  void setSearch(String q) =>
      state = state.copyWith(searchQuery: q);
  void clearAll() => state = const AssetFilter();
}

// ── Asset List Provider (SQLite-backed AsyncNotifier) ─────────────────────────

final assetListProvider =
    AsyncNotifierProvider<AssetListNotifier, List<Asset>>(
        AssetListNotifier.new);

class AssetListNotifier extends AsyncNotifier<List<Asset>> {
  final _repo = _AssetRepo();

  @override
  Future<List<Asset>> build() => _repo.getAll();

  void refresh() => ref.invalidateSelf();

  Future<void> addAsset(Asset asset) async {
    await _repo.insert(asset);
    ref.invalidateSelf();
  }

  Future<void> updateAsset(Asset asset) async {
    await _repo.update(asset);
    ref.invalidateSelf();
  }

  Future<void> setStatus(
      String id, AssetStatus newStatus, {String? customerId}) async {
    await _repo.updateStatus(id, newStatus, customerId);
    ref.invalidateSelf();
  }

  Future<void> markAsLost(String id) =>
      setStatus(id, AssetStatus.lost, customerId: Asset.warehouseId);

  Future<void> sendToMaintenance(String id) =>
      setStatus(id, AssetStatus.maintenance, customerId: Asset.warehouseId);

  Future<void> returnToWarehouse(String id) =>
      setStatus(id, AssetStatus.availableFull, customerId: Asset.warehouseId);

  /// Barcode lookup from full list (in-memory after load).
  Asset? getByBarcode(String barcode) {
    final all = state.value ?? [];
    try {
      return all.firstWhere(
          (a) => a.barcode == barcode && a.isActive);
    } catch (_) {
      return null;
    }
  }
}

// ── Filtered Assets Provider (derived) ───────────────────────────────────────

final filteredAssetProvider = Provider<AsyncValue<List<Asset>>>((ref) {
  final allAsync = ref.watch(assetListProvider);
  final filter = ref.watch(assetFilterProvider);

  return allAsync.whenData((all) {
    var filtered = all.where((a) => a.isActive).toList();

    if (filter.unauditedOnly) {
      filtered = filtered.where((a) => !a.isBarcodeAudited).toList();
    } else if (filter.status != null) {
      filtered = filtered.where((a) => a.status == filter.status).toList();
    }

    if (filter.itemId != null) {
      filtered = filtered.where((a) => a.itemId == filter.itemId).toList();
    }

    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      filtered = filtered
          .where((a) =>
              a.serialNumber.toLowerCase().contains(q) ||
              a.barcode.toLowerCase().contains(q) ||
              a.itemId.toLowerCase().contains(q))
          .toList();
    }

    return filtered;
  });
});

// ── Selected asset ID provider ────────────────────────────────────────────────

final selectedAssetIdProvider =
    NotifierProvider<_SelectedAssetIdNotifier, String?>(
        _SelectedAssetIdNotifier.new);

class _SelectedAssetIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
  void clear() => state = null;
}
