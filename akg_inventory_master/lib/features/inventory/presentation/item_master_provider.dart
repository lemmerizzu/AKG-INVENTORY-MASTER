import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/asset.dart';
import '../domain/item.dart';

// ── 9 SKU Master (from real CSV data) ─────────────────────────────────────

final mockItemsMaster = [
  const Item(id: 'e8544a46', itemCode: 'OXY1M3', name: 'Oksigen 1m3', unit: 'Btl', basePrice: 25000),
  const Item(id: '8bdbe149', itemCode: 'OXY6M3', name: 'Oksigen 6m3', unit: 'Btl', basePrice: 50000),
  const Item(id: '7d2764f1', itemCode: 'OXY7M3', name: 'Oksigen 7m3', unit: 'Btl', basePrice: 50000),
  const Item(id: '66af7c72', itemCode: 'AR6M3', name: 'Argon 6m3', unit: 'Btl', basePrice: 120000),
  const Item(id: 'ef306e54', itemCode: 'CO2', name: 'Karbondioksida', unit: 'Btl', basePrice: 165000),
  const Item(id: 'a50ce892', itemCode: 'N2', name: 'Nitrogen 6m3', unit: 'Btl', basePrice: 80000),
  const Item(id: 'be525f3b', itemCode: 'LPG12', name: 'LPG 12kg', unit: 'Btl', basePrice: 200000, defaultType: AssetType.exchange),
  const Item(id: 'b7a8fff1', itemCode: 'LPG50', name: 'LPG 50kg', unit: 'Btl', basePrice: 800000, defaultType: AssetType.exchange),
  const Item(id: '3b9d6a30', itemCode: 'ACE', name: 'Acetyline', unit: 'Btl', basePrice: 150000),
];

// ── Provider ──────────────────────────────────────────────────────────────

final itemListProvider = NotifierProvider<ItemMasterNotifier, List<Item>>(
  ItemMasterNotifier.new,
);

class ItemMasterNotifier extends Notifier<List<Item>> {
  @override
  List<Item> build() => [...mockItemsMaster];

  void addItem(Item item) {
    state = [...state, item];
  }

  void updateItem(String id, Item updated) {
    state = [
      for (final item in state)
        if (item.id == id) updated else item,
    ];
  }

  void toggleActive(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isActive: !item.isActive) else item,
    ];
  }

  Item? getById(String id) {
    try {
      return state.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
