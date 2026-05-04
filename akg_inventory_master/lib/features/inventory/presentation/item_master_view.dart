import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme.dart';
import '../domain/asset.dart';
import '../domain/item.dart';
import 'item_master_provider.dart';

/// Tab 3: Item Master (SKU) management — DataTable with inline CRUD.
class ItemMasterView extends ConsumerWidget {
  const ItemMasterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemListProvider);
    final notifier = ref.read(itemListProvider.notifier);

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) => SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
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
                    child: const Icon(Icons.category_outlined,
                        color: AppTheme.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Master SKU',
                          style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('${items.length} items terdaftar',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppTheme.textLight)),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, notifier),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah SKU'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Table
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: WidgetStateProperty.all(AppTheme.background),
                    headingTextStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textLight),
                    dataTextStyle: GoogleFonts.inter(fontSize: 13),
                    columns: const [
                      DataColumn(label: Text('Kode')),
                      DataColumn(label: Text('Nama Item')),
                      DataColumn(label: Text('Unit')),
                      DataColumn(label: Text('Harga Dasar')),
                      DataColumn(label: Text('Tipe')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: items.map((item) => _buildRow(context, item, notifier)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  DataRow _buildRow(BuildContext context, Item item, ItemMasterNotifier notifier) {
    return DataRow(
      cells: [
        DataCell(Text(item.itemCode,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
        DataCell(Text(item.name)),
        DataCell(Text(item.unit)),
        DataCell(Text('Rp ${_formatPrice(item.basePrice)}')),
        DataCell(_typeBadge(item.defaultType)),
        DataCell(
          item.isActive
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Active',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00C853))),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Inactive',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                ),
        ),
      ],
    );
  }

  Widget _typeBadge(AssetType type) {
    final (label, color) = switch (type) {
      AssetType.rent => ('Rental', AppTheme.primaryBlue),
      AssetType.exchange => ('Exchange', Colors.orange),
      AssetType.sell => ('Sell', Colors.purple),
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _showAddDialog(BuildContext context, ItemMasterNotifier notifier) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    AssetType selectedType = AssetType.rent;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tambah SKU Baru',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: StatefulBuilder(
            builder: (ctx, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeCtrl,
                    decoration: InputDecoration(
                        labelText: 'Kode Item',
                        hintText: 'OXY6M3',
                        labelStyle: GoogleFonts.inter(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                        labelText: 'Nama Item',
                        hintText: 'Oksigen 6m3',
                        labelStyle: GoogleFonts.inter(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Harga Dasar (Rp)',
                        hintText: '50000',
                        labelStyle: GoogleFonts.inter(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AssetType>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                        labelText: 'Tipe Default',
                        labelStyle: GoogleFonts.inter(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    items: AssetType.values.map((t) {
                      final label = switch (t) {
                        AssetType.rent => 'Rental',
                        AssetType.exchange => 'Exchange (Tukar)',
                        AssetType.sell => 'Sell (Jual Putus)',
                      };
                      return DropdownMenuItem(value: t, child: Text(label));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedType = v!),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                notifier.addItem(Item(
                  id: const Uuid().v4(),
                  itemCode: codeCtrl.text.toUpperCase(),
                  name: nameCtrl.text,
                  basePrice: int.tryParse(priceCtrl.text) ?? 0,
                  defaultType: selectedType,
                ));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(elevation: 0),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
