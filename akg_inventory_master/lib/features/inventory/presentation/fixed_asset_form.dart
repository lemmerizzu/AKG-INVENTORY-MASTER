import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';

/// Tab 2: Fixed Asset Management form (SAP/Odoo-style).
/// For vehicles, machinery, and other non-operational assets.
class FixedAssetForm extends ConsumerWidget {
  const FixedAssetForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
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
                    child: const Icon(Icons.business_outlined,
                        color: AppTheme.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Registrasi Aset Tetap',
                          style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('Kendaraan, mesin, peralatan berat',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppTheme.textLight)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Section 1: Identification
              _sectionTitle('Identifikasi Aset'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Nama Aset *', hint: 'Cth: Truk Pengiriman 01')),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Nomor Tag Inventaris', hint: 'FA-2025-001')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Merek / Brand', hint: 'Toyota, Pertamina')),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Model', hint: 'Avanza, Compressor X200')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Nomor Plat', hint: 'L 1234 AB')),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Serial Number', hint: 'Opsional')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _dropdownField(
                      label: 'Kategori Aset',
                      items: ['Kendaraan', 'Mesin Pengisi', 'Peralatan Berat', 'Perlengkapan Kantor', 'Lainnya'],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section 2: Acquisition
              _sectionTitle('Data Akuisisi'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Tanggal Pembelian *', hint: 'DD/MM/YYYY', icon: Icons.calendar_today)),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Harga Beli (Rp) *', hint: '150.000.000', icon: Icons.attach_money)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Nama Vendor / Supplier', hint: 'PT Supplier Indonesia')),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Nomor PO / Invoice', hint: 'PO-2025-0001')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section 3: Depreciation
              _sectionTitle('Parameter Depresiasi'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _dropdownField(
                            label: 'Metode Depresiasi',
                            items: ['Garis Lurus (Straight Line)', 'Saldo Menurun (Declining Balance)'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Umur Ekonomis (bulan)', hint: '60')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Nilai Sisa / Salvage Value (Rp)', hint: '10.000.000')),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Tanggal Mulai Depresiasi', hint: 'DD/MM/YYYY', icon: Icons.calendar_today)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Section 4: Location & Custody
              _sectionTitle('Lokasi & Penanggung Jawab'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Lokasi', hint: 'Gudang A, Kantor Pusat')),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'PIC / Custodian', hint: 'Nama penanggung jawab')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _textField(label: 'Catatan', hint: 'Catatan tambahan...', maxLines: 3),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Simpan Aset Tetap'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _sectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold));
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight.withValues(alpha: 0.6)),
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({required String label, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 13))))
              .toList(),
          onChanged: (_) {},
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
