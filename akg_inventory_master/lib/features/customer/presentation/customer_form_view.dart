import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme.dart';
import '../domain/customer.dart';
import 'customer_provider.dart';

class CustomerFormView extends ConsumerStatefulWidget {
  const CustomerFormView({super.key});

  @override
  ConsumerState<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends ConsumerState<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _termCtrl;
  bool _isPpn = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _termCtrl = TextEditingController(text: '14');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  void _syncWithState(Customer? selCust) {
    if (selCust == null) {
      if (_codeCtrl.text.isEmpty) {
        _codeCtrl.text =
            ref.read(customerListProvider.notifier).generateNextCustomerCode();
      }
      return;
    }

    _codeCtrl.text = selCust.customerCode;
    _nameCtrl.text = selCust.name;
    _addressCtrl.text = selCust.address;
    _termCtrl.text = selCust.termDays.toString();
    _isPpn = selCust.isPpnEnabled;
    _isActive = selCust.isActive;
  }

  void _save(Customer? currentCustomer) {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: currentCustomer?.id ?? const Uuid().v4(),
      customerCode: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      termDays: int.tryParse(_termCtrl.text.trim()) ?? 14,
      isPpnEnabled: _isPpn,
      isActive: _isActive,
      createdAt: currentCustomer?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (currentCustomer == null) {
      ref.read(customerListProvider.notifier).addCustomer(customer);
    } else {
      ref.read(customerListProvider.notifier).updateCustomer(customer);
    }

    // Refresh selection
    ref.read(selectedCustomerProvider.notifier).select(customer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data Customer berhasil disimpan!'),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCustomer = ref.watch(selectedCustomerProvider);

    // Call only once right after build if selection changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWithState(selectedCustomer);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business_center,
                      color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        selectedCustomer == null
                            ? 'Tambah Customer'
                            : 'Edit Customer',
                        style: GoogleFonts.outfit(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    Text(
                        selectedCustomer == null
                            ? 'Buat profil pelanggan baru'
                            : 'Perbarui data pelanggan',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppTheme.textLight)),
                  ],
                ),
                const Spacer(),
                if (selectedCustomer != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(selectedCustomerProvider.notifier).select(null);
                      _codeCtrl.clear();
                      _nameCtrl.clear();
                      _addressCtrl.clear();
                      _termCtrl.text = '14';
                      setState(() {
                        _isPpn = false;
                        _isActive = true;
                      });
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Buat Baru'),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            // Form Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi Dasar',
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildField(
                          'Customer Code',
                          child: TextFormField(
                            controller: _codeCtrl,
                            readOnly: true,
                            decoration: InputDecoration(
                                hintText: 'Misal: AKG-001',
                                filled: true,
                                fillColor: Colors.grey.withValues(alpha: 0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                )),
                            validator: (v) =>
                                v!.isEmpty ? 'Kode wajib diisi' : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 7,
                        child: _buildField(
                          'Nama Customer/Perusahaan',
                          child: TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                                hintText: 'Masukkan nama perusahaan...'),
                            validator: (v) =>
                                v!.isEmpty ? 'Nama wajib diisi' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    'Alamat Lengkap',
                    child: TextFormField(
                      controller: _addressCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Masukkan alamat lengkap...'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          'Termin (Hari)',
                          child: TextFormField(
                            controller: _termCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: 'Misal: 14',
                                suffixText: 'Hari',
                                counterText: ''),
                            maxLength: 3,
                            validator: (v) => int.tryParse(v ?? '') == null
                                ? 'Angka tidak valid'
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _buildField(
                          'Pajak PPN',
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Include/Exclude PPN (Tax)',
                                style: GoogleFonts.inter(fontSize: 14)),
                            subtitle: Text('Otomatis ubah harga',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: AppTheme.textLight)),
                            value: _isPpn,
                            onChanged: (val) {
                              setState(() {
                                _isPpn = val;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Status Aktif Switch
                      Expanded(
                        flex: 1,
                        child: _buildField(
                          'Status Pelanggan',
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_isActive ? 'Aktif' : 'Nonaktif',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: _isActive
                                        ? AppTheme.primaryBlue
                                        : AppTheme.error)),
                            subtitle: Text('Status transaksi',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: AppTheme.textLight)),
                            value: _isActive,
                            activeColor: AppTheme.primaryBlue,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pricelist Placeholder Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Harga Khusus (Pricelist)',
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      // Tooltip info
                      const Icon(Icons.info_outline,
                          size: 16, color: AppTheme.textLight),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 32, color: Colors.grey.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('Fitur Pricelist sedang dalam pengembangan.',
                            style: GoogleFonts.inter(
                                color: AppTheme.textLight, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Reset to currently selected customer
                    _syncWithState(selectedCustomer);
                    setState(() {});
                  },
                  child: Text('Batal',
                      style: GoogleFonts.inter(color: AppTheme.textDark)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _save(selectedCustomer),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Simpan Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textDark)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
