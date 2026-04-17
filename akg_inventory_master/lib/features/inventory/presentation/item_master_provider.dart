import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/item_repository.dart';
import '../domain/item.dart';

// ── Repository singleton ──────────────────────────────────────────────────
final itemRepositoryProvider = Provider((ref) => ItemRepository());

// ── Provider (SQLite-backed) ──────────────────────────────────────────────

final itemListProvider =
    AsyncNotifierProvider<ItemMasterNotifier, List<Item>>(
  ItemMasterNotifier.new,
);

class ItemMasterNotifier extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() async {
    final repo = ref.read(itemRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addItem(Item item) async {
    final repo = ref.read(itemRepositoryProvider);
    await repo.insert(item);
    state = AsyncData(await repo.getAll());
  }

  Future<void> updateItem(String id, Item updated) async {
    final repo = ref.read(itemRepositoryProvider);
    await repo.update(updated);
    state = AsyncData(await repo.getAll());
  }

  Item? getById(String id) {
    try {
      return state.value?.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  void refresh() => ref.invalidateSelf();
}

// ══════════════════════════════════════════════════════════════════════════
// Related List Providers
// ══════════════════════════════════════════════════════════════════════════

/// Customers with custom prices for this item.
final itemPricelistProvider =
    FutureProvider.family<List<ItemPricelistView>, String>(
  (ref, itemId) async {
    final repo = ref.read(itemRepositoryProvider);
    return repo.getPricelistByItemId(itemId);
  },
);

/// All serialized assets of this item type.
final itemAssetsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, itemId) async {
    final repo = ref.read(itemRepositoryProvider);
    return repo.getAssetsByItemId(itemId);
  },
);

/// Inventory stats for an item.
final itemStatsProvider =
    FutureProvider.family<Map<String, int>, String>(
  (ref, itemId) async {
    final repo = ref.read(itemRepositoryProvider);
    return repo.getAssetStatsByItemId(itemId);
  },
);
