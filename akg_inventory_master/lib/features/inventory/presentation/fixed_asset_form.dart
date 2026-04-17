import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../domain/asset.dart';

// ── Fixed Asset Provider ──────────────────────────────────────────────

final fixedAssetListProvider =
    NotifierProvider<FixedAssetListNotifier, List<FixedAssetDetail>>(
  FixedAssetListNotifier.new,
);

class FixedAssetListNotifier extends Notifier<List<FixedAssetDetail>> {
  @override
  List<FixedAssetDetail> build() => [
        // Sample fixed asset data
        FixedAssetDetail(
          assetId: 'FA-001',
          assetTag: 'FA-2025-001',
          brand: 'Toyota',
          model: 'Avanza',
          plateNumber: 'W 1234 AB',
          acquisitionDate: DateTime(2023, 3, 15),
          originalValue: 180000000,
          vendorName: 'PT Auto Jaya',
          depreciationMethod: 'straight_line',
          usefulLifeMonths: 60,
          salvageValue: 30000000,
          location: 'Gudang A',
          custodian: 'Pak Wahyono',
        ),
      ];

  void addFixedAsset(FixedAssetDetail detail) {
    state = [...state, detail];
  }

  void removeFixedAsset(String assetId) {
    state = state.where((d) => d.assetId != assetId).toList();
  }
}

// ── Form State ───────────────────────────────────────────────────────

class FixedAssetFormState {
  final String assetName;
  final String assetTag;
  final String brand;
  final String model;
  final String plateNumber;
  final String serialNumber;
  final String assetCategory;
  final DateTime? acquisitionDate;
  final String originalValue;
  final String vendorName;
  final String poReference;
  final String depreciationMethod;
  final String usefulLifeMonths;
  final String salvageValue;
  final String depreciationStartDate;
  final String location;
  final String custodian;
  final String notes;
  final String? savedMessage;

  const FixedAssetFormState({
    this.assetName = '',
    this.assetTag = '',
    this.brand = '',
    this.model = '',
    this.plateNumber = '',
    this.serialNumber = '',
    this.assetCategory = 'Kendaraan',
    this.acquisitionDate,
    this.originalValue = '',
    this.vendorName = '',
    this.poReference = '',
    this.depreciationMethod = 'Garis Lurus (Straight Line)',
    this.usefulLifeMonths = '60',
    this.salvageValue = '',
    this.depreciationStartDate = '',
    this.location = '',
    this.custodian = '',
    this.notes = '',
    this.savedMessage,
  });

  FixedAssetFormState copyWith({
    String? assetName,
    String? assetTag,
    String? brand,
    String? model,
    String? plateNumber,
    String? serialNumber,
    String? assetCategory,
    DateTime? acquisitionDate,
    String? originalValue,
    String? vendorName,
    String? poReference,
    String? depreciationMethod,
    String? usefulLifeMonths,
    String? salvageValue,
    String? depreciationStartDate,
    String? location,
    String? custodian,
    String? notes,
    String? savedMessage,
  }) {
    return FixedAssetFormState(
      assetName: assetName ?? this.assetName,
      assetTag: assetTag ?? this.assetTag,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      assetCategory: assetCategory ?? this.assetCategory,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      originalValue: originalValue ?? this.originalValue,
      vendorName: vendorName ?? this.vendorName,
      poReference: poReference ?? this.poReference,
      depreciationMethod: depreciationMethod ?? this.depreciationMethod,
      usefulLifeMonths: usefulLifeMonths ?? this.usefulLifeMonths,
      salvageValue: salvageValue ?? this.salvageValue,
      depreciationStartDate: depreciationStartDate ?? this.depreciationStartDate,
      location: location ?? this.location,
      custodian: custodian ?? this.custodian,
      notes: notes ?? this.notes,
      savedMessage: savedMessage,
    );
  }
}

final fixedAssetFormProvider =
    NotifierProvider<FixedAssetFormNotifier, FixedAssetFormState>(
  FixedAssetFormNotifier.new,
);

class FixedAssetFormNotifier extends Notifier<FixedAssetFormState> {
  @override
  FixedAssetFormState build() => const FixedAssetFormState();

  void updateField(String field, String value) {
    switch (field) {
      case 'assetName': state = state.copyWith(assetName: value);
      case 'assetTag': state = state.copyWith(assetTag: value);
      case 'brand': state = state.copyWith(brand: value);
      case 'model': state = state.copyWith(model: value);
      case 'plateNumber': state = state.copyWith(plateNumber: value);
      case 'serialNumber': state = state.copyWith(serialNumber: value);
      case 'assetCategory': state = state.copyWith(assetCategory: value);
      case 'originalValue': state = state.copyWith(originalValue: value);
      case 'vendorName': state = state.copyWith(vendorName: value);
      case 'poReference': state = state.copyWith(poReference: value);
      case 'depreciationMethod': state = state.copyWith(depreciationMethod: value);
      case 'usefulLifeMonths': state = state.copyWith(usefulLifeMonths: value);
      case 'salvageValue': state = state.copyWith(salvageValue: value);
      case 'location': state = state.copyWith(location: value);
      case 'custodian': state = state.copyWith(custodian: value);
      case 'notes': state = state.copyWith(notes: value);
    }
  }

  void setAcquisitionDate(DateTime date) {
    state = state.copyWith(acquisitionDate: date);
  }

  void saveFixedAsset() {
    final s = state;
    if (s.assetName.isEmpty) {
      state = state.copyWith(savedMessage: '! Nama Aset wajib diisi');
      return;
    }
    if (s.originalValue.isEmpty) {
      state = state.copyWith(savedMessage: '! Harga Beli wajib diisi');
      return;
    }

    final id = 'FA-${DateTime.now().millisecondsSinceEpoch}';
    final detail = FixedAssetDetail(
      assetId: id,
      assetTag: s.assetTag.isEmpty ? null : s.assetTag,
      brand: s.brand.isEmpty ? null : s.brand,
      model: s.model.isEmpty ? null : s.model,
      plateNumber: s.plateNumber.isEmpty ? null : s.plateNumber,
      acquisitionDate: s.acquisitionDate,
      originalValue: double.tryParse(s.originalValue.replaceAll('.', '')) ?? 0,
      vendorName: s.vendorName.isEmpty ? null : s.vendorName,
      poReference: s.poReference.isEmpty ? null : s.poReference,
      depreciationMethod: s.depreciationMethod.contains('Saldo')
          ? 'declining_balance'
          : 'straight_line',
      usefulLifeMonths: int.tryParse(s.usefulLifeMonths) ?? 60,
      salvageValue: double.tryParse(s.salvageValue.replaceAll('.', '')) ?? 0,
      location: s.location.isEmpty ? null : s.location,
      custodian: s.custodian.isEmpty ? null : s.custodian,
    );

    ref.read(fixedAssetListProvider.notifier).addFixedAsset(detail);
    state = const FixedAssetFormState(savedMessage: '✓ Aset Tetap berhasil disimpan');
  }

  void reset() {
    state = const FixedAssetFormState();
  }
}

/// Tab 2: Fixed Asset Management form (SAP/Odoo-style).
class FixedAssetForm extends ConsumerStatefulWidget {
  const FixedAssetForm({super.key});

  @override
  ConsumerState<FixedAssetForm> createState() => _FixedAssetFormState();
}

class _FixedAssetFormState extends ConsumerState<FixedAssetForm> {
  final _nameCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _snCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  final _lifeCtrl = TextEditingController(text: '60');
  final _salvageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _custodianCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nameCtrl, _tagCtrl, _brandCtrl, _modelCtrl, _plateCtrl, _snCtrl, _priceCtrl, _vendorCtrl, _poCtrl, _lifeCtrl, _salvageCtrl, _locationCtrl, _custodianCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(fixedAssetFormProvider.notifier);
    final existingAssets = ref.watch(fixedAssetListProvider);

    // Listen for save messages
    ref.listen<FixedAssetFormState>(fixedAssetFormProvider, (prev, next) {
      if (next.savedMessage != null) {
        final isError = next.savedMessage!.startsWith('!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.savedMessage!),
            backgroundColor: isError ? AppTheme.error : const Color(0xFF00C853),
          ),
        );
        if (!isError) _clearControllers();
      }
    });

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
                      Text('${existingAssets.length} aset tetap terdaftar',
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
                    Row(children: [
                      Expanded(child: _textField(label: 'Nama Aset *', hint: 'Cth: Truk Pengiriman 01', ctrl: _nameCtrl, field: 'assetName')),
                      const SizedBox(width: 16),
                      Expanded(child: _textField(label: 'Nomor Tag Inventaris', hint: 'FA-2025-001', ctrl: _tagCtrl, field: 'assetTag')),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _textField(label: 'Merek / Brand', hint: 'Toyota, Pertamina', ctrl: _brandCtrl, field: 'brand')),
                      const SizedBox(width: 16),
                      Expanded(child: _textField(label: 'Model', hint: 'Avanza, Compressor X200', ctrl: _modelCtrl, field: 'model')),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _textField(label: 'Nomor Plat', hint: 'L 1234 AB', ctrl: _plateCtrl, field: 'plateNumber')),
                      const SizedBox(width: 16),
                      Expanded(child: _textField(label: 'Serial Number', hint: 'Opsional', ctrl: _snCtrl, field: 'serialNumber')),
                    ]),
                    const SizedBox(height: 16),
                    _dropdownField(
                      label: 'Kategori Aset',
                      items: ['Kendaraan', 'Mesin Pengisi', 'Peralatan Berat', 'Perlengkapan Kantor', 'Lainnya'],
                      field: 'assetCategory',
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
                    Row(children: [
                      Expanded(child: _dateField(label: 'Tanggal Pembelian *', context: context)),
                      const SizedBox(width: 16),
                      Expanded(child: _textField(label: 'Harga Beli (Rp) *', hint: '150.000.000', ctrl: _priceCtrl, field: 'originalValue', icon: Icons.attach_money)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _textField(label: 'Nama Vendor / Supplier', hint: 'PT Supplier Indonesia', ctrl: _vendorCtrl, field: 'vendorName')),
                      const SizedBox(width: 16),
                      Expanded(child: _textField(label: 'Nomor PO / Invoice', hint: 'PO-2025-0001', ctrl: _poCtrl, field: 'poReference')),
                    ]),
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
                    Row(children: [
                      Expanded(child: _dropdownField(
                        label: 'Metode Depresiasi',
                        items: ['Garis Lurus (Straight Line)', 'Saldo Menurun (Declining Balance)'],
                        field: 'depreciationMethod',
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _textField(label: 'Umur Ekonomis (bulan)', hint: '60', ctrl: _lifeCtrl, field: 'usefulLifeMonths')),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _textField(label: 'Nilai Sisa / Salvage Value (Rp)', hint: '10.000.000', ctrl: _salvageCtrl, field: 'salvageValue')),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()),
                    ]),
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
                    Row(children: [
                      Expanded(child: _textField(label: 'Lokasi', hint: 'Gudang A, Kantor Pusat', ctrl: _locationCtrl, field: 'location')),
                      const SizedBox(width: 16),
                      Expanded(child: _textField(label: 'PIC / Custodian', hint: 'Nama penanggung jawab', ctrl: _custodianCtrl, field: 'custodian')),
                    ]),
                    const SizedBox(height: 16),
                    _textField(label: 'Catatan', hint: 'Catatan tambahan...', ctrl: _notesCtrl, field: 'notes', maxLines: 3),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      notifier.reset();
                      _clearControllers();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => notifier.saveFixedAsset(),
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

  void _clearControllers() {
    for (final c in [_nameCtrl, _tagCtrl, _brandCtrl, _modelCtrl, _plateCtrl, _snCtrl, _priceCtrl, _vendorCtrl, _poCtrl, _salvageCtrl, _locationCtrl, _custodianCtrl, _notesCtrl]) {
      c.clear();
    }
    _lifeCtrl.text = '60';
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
    required TextEditingController ctrl,
    required String field,
    IconData? icon,
    int maxLines = 1,
  }) {
    final notifier = ref.read(fixedAssetFormProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          onChanged: (v) => notifier.updateField(field, v),
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

  Widget _dropdownField({required String label, required List<String> items, required String field}) {
    final notifier = ref.read(fixedAssetFormProvider.notifier);
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
          onChanged: (v) {
            if (v != null) notifier.updateField(field, v);
          },
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

  Widget _dateField({required String label, required BuildContext context}) {
    final formState = ref.watch(fixedAssetFormProvider);
    final notifier = ref.read(fixedAssetFormProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: formState.acquisitionDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) notifier.setAcquisitionDate(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppTheme.textLight),
                const SizedBox(width: 10),
                Text(
                  formState.acquisitionDate != null
                      ? '${formState.acquisitionDate!.day}/${formState.acquisitionDate!.month}/${formState.acquisitionDate!.year}'
                      : 'Pilih tanggal...',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: formState.acquisitionDate != null ? AppTheme.textDark : AppTheme.textLight.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
