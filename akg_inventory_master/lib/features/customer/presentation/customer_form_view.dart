import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_colors.dart';
import '../../../shared/widgets/ak_section_header.dart';
import '../domain/customer.dart';
import 'customer_provider.dart';

class CustomerFormView extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const CustomerFormView({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends ConsumerState<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _termCtrl;
  late TextEditingController _npwpCtrl;
  late TextEditingController _phoneCtrl;
  bool _isPpn = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _termCtrl = TextEditingController(text: '14');
    _npwpCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();

    // Initialize state from overlay provider context
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final overlay = ref.read(customerOverlayProvider);
      if (overlay.mode == CustomerFormMode.edit && overlay.customer != null) {
        _syncWithCustomer(overlay.customer!);
      } else {
        final code = await ref.read(customerListProvider.notifier).generateNextCustomerCode();
        if (mounted) {
          _codeCtrl.text = code;
        }
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _termCtrl.dispose();
    _npwpCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _syncWithCustomer(Customer customer) {
    _codeCtrl.text = customer.customerCode;
    _nameCtrl.text = customer.name;
    _addressCtrl.text = customer.address;
    _termCtrl.text = customer.termDays.toString();
    _npwpCtrl.text = customer.npwp ?? '';
    _phoneCtrl.text = customer.phone ?? '';
    _isPpn = customer.isPpnEnabled;
    _isActive = customer.isActive;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final overlay = ref.read(customerOverlayProvider);
    final currentCustomer = overlay.customer;

    final customer = Customer(
      id: currentCustomer?.id ?? const Uuid().v4(),
      customerCode: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      termDays: int.tryParse(_termCtrl.text.trim()) ?? 14,
      npwp: _npwpCtrl.text.trim().isEmpty ? null : _npwpCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      isPpnEnabled: _isPpn,
      isActive: _isActive,
      createdAt: currentCustomer?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (overlay.mode == CustomerFormMode.add) {
      await ref.read(customerListProvider.notifier).addCustomer(customer);
    } else {
      await ref.read(customerListProvider.notifier).updateCustomer(customer);
    }

    // Update selection to match saved customer
    ref.read(selectedCustomerProvider.notifier).select(customer);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Customer ${customer.name} berhasil disimpan!'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlay = ref.watch(customerOverlayProvider);
    final isEdit = overlay.mode == CustomerFormMode.edit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ───────────────────────────────────────────────────────────
        AkPanelHeader(
          title: isEdit ? 'EDIT CUSTOMER' : 'TAMBAH CUSTOMER',
          leading: Icon(
            isEdit ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
            color: AppColors.googleBlue,
          ),
          trailing: [
            AkIconButton(
              icon: Icons.close_rounded,
              onTap: widget.onClose,
              tooltip: 'Tutup',
            ),
          ],
        ),

        // ── Form Content ─────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionLabel('INFORMASI DASAR'),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          label: 'CUSTOMER CODE',
                          controller: _codeCtrl,
                          readOnly: true,
                          fillColor: AppColors.pageBg,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 7,
                        child: _buildTextField(
                          label: 'NAMA CUSTOMER / PERUSAHAAN',
                          controller: _nameCtrl,
                          hint: 'Masukkan nama...',
                          validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'NPWP',
                          controller: _npwpCtrl,
                          hint: 'Misal: 012345...',
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'NO. TELEPON',
                          controller: _phoneCtrl,
                          hint: '0812...',
                          icon: Icons.phone_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    label: 'ALAMAT LENGKAP',
                    controller: _addressCtrl,
                    hint: 'Masukkan alamat pengiriman...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),
                  _buildSectionLabel('PENGATURAN TRANSAKSI'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'TERMIN (HARI)',
                          controller: _termCtrl,
                          hint: '14',
                          suffixText: 'HARI',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildSwitchField(
                          label: 'PAJAK (PPN)',
                          value: _isPpn,
                          onChanged: (v) => setState(() => _isPpn = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildSwitchField(
                    label: 'STATUS AKTIF',
                    value: _isActive,
                    subtitle: 'Hanya customer aktif yang muncul di pilihan transaksi',
                    onChanged: (v) => setState(() => _isActive = v),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),

        // ── Footer Actions ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.pageBg,
            border: Border(top: BorderSide(color: AppColors.borderColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onClose,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: const Text('BATAL'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.googleBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH CUSTOMER',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    bool readOnly = false,
    int maxLines = 1,
    Color? fillColor,
    String? suffixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textSecondary) : null,
            suffixText: suffixText,
            filled: true,
            fillColor: fillColor ?? Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.googleBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pageBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppColors.googleBlue,
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
              )
            : null,
      ),
    );
  }
}
