import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../domain/transaction_document.dart';
import '../../customer/domain/customer.dart';
import 'transaction_form_provider.dart';

class TransactionFormView extends ConsumerStatefulWidget {
  const TransactionFormView({super.key});

  @override
  ConsumerState<TransactionFormView> createState() =>
      _TransactionFormViewState();
}

class _TransactionFormViewState extends ConsumerState<TransactionFormView>
    with SingleTickerProviderStateMixin {
  final _docNumberController = TextEditingController();
  final _addressController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _docNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);
    final customers = ref.watch(customerListProvider);

    // Listen for save messages
    ref.listen<TransactionFormState>(transactionFormProvider, (prev, next) {
      if (next.savedMessage != null) {
        final isError = next.savedMessage!.contains('!') &&
            !next.savedMessage!.contains('berhasil');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.savedMessage!),
            backgroundColor:
                isError ? AppTheme.error : const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        notifier.clearMessage();
      }
    });

    // Sync address controller
    if (_addressController.text != formState.shippingAddress) {
      _addressController.text = formState.shippingAddress;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Warehouse Transaction',
                          style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                      Text('Buat transaksi keluar/masuk tabung',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppTheme.textLight)),
                    ],
                  ),
                  const Spacer(),
                  // Reset button
                  OutlinedButton.icon(
                    onPressed: () {
                      notifier.resetForm();
                      _docNumberController.clear();
                      _addressController.clear();
                    },
                    icon:
                        const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textLight,
                      side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Form Card ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1)),
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
                    _buildField(
                      'Customer Name',
                      isRequired: true,
                      child: _buildCustomerDropdown(formState, notifier, customers),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            'Mutation Code',
                            isRequired: true,
                            child: _buildMutationToggle(formState, notifier),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            'Input Mode',
                            child: _buildInputModeToggle(formState, notifier),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            'Doc Number',
                            isRequired: true,
                            child: TextFormField(
                              controller: _docNumberController,
                              onChanged: notifier.setDocNumber,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan nomor dokumen...',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            'Datetime',
                            isRequired: true,
                            child: _buildDateTimePicker(context, formState, notifier),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      'Shipping Address',
                      isRequired: true,
                      child: TextFormField(
                        controller: _addressController,
                        onChanged: notifier.setShippingAddress,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Alamat pengiriman...',
                          prefixIcon: const Icon(Icons.location_on_outlined,
                              color: AppTheme.textLight, size: 20),
                          suffixIcon: formState.selectedCustomer != null
                              ? IconButton(
                                  icon: const Icon(Icons.sync,
                                      size: 18,
                                      color: AppTheme.primaryBlue),
                                  tooltip: 'Gunakan alamat customer',
                                  onPressed: () {
                                    notifier.setShippingAddress(
                                        formState.selectedCustomer!.address);
                                    _addressController.text =
                                        formState.selectedCustomer!.address;
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Items Section ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Kelola Item Logistik',
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${formState.scannedItems.length} item',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showBarcodeDialog(context),
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            label: const Text('Scan / Input Barcode'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showManualInputDialog(context),
                            icon: const Icon(Icons.keyboard, size: 18),
                            label: const Text('Input Series Manual'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryBlue,
                              side: BorderSide(
                                  color: AppTheme.primaryBlue
                                      .withValues(alpha: 0.4)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showUnauditedDialog(context),
                            icon: const Icon(Icons.warning_amber_rounded,
                                size: 18),
                            label: const Text('Non-Barcode'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.warning,
                              side: BorderSide(
                                  color: AppTheme.warning
                                      .withValues(alpha: 0.4)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Scanned items list
                    if (formState.scannedItems.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: formState.scannedItems.length,
                          separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.1)),
                          itemBuilder: (context, index) {
                            final item = formState.scannedItems[index];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                item.isBarcodeAudited
                                    ? Icons.qr_code
                                    : Icons.warning_amber,
                                color: item.isBarcodeAudited
                                    ? AppTheme.primaryBlue
                                    : AppTheme.warning,
                                size: 20,
                              ),
                              title: Text(item.itemName,
                                  style: GoogleFonts.inter(fontSize: 13)),
                              subtitle: Text(item.barcode,
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppTheme.textLight)),
                              trailing: IconButton(
                                icon: const Icon(Icons.close,
                                    size: 16, color: AppTheme.error),
                                onPressed: () =>
                                    notifier.removeScannedItem(index),
                              ),
                            );
                          },
                        ),
                      ),

                    if (formState.scannedItems.isEmpty)
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.15)),
                        ),
                        child: Center(
                          child: Text(
                            'Belum ada item. Gunakan tombol di atas untuk menambahkan tabung.',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppTheme.textLight),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Bottom Actions ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      notifier.resetForm();
                      _docNumberController.clear();
                      _addressController.clear();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                    ),
                    child: Text('Batal',
                        style: GoogleFonts.inter(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: formState.isSaving
                        ? null
                        : () => notifier.saveTransaction(),
                    icon: formState.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(formState.isSaving
                        ? 'Menyimpan...'
                        : 'Simpan Transaksi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Field helpers ───────────────────────────────────────────────

  Widget _buildField(String label,
      {bool isRequired = false, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textDark)),
            if (isRequired)
              Text(' *',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildCustomerDropdown(TransactionFormState formState,
      TransactionFormNotifier notifier, List<Customer> customers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: formState.selectedCustomer?.id,
          hint: Text('Pilih customer...',
              style:
                  GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight)),
          icon: const Icon(Icons.arrow_drop_down_rounded,
              color: AppTheme.textLight),
          items: customers
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name,
                        style: GoogleFonts.inter(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (id) {
            final customer = customers.firstWhere((c) => c.id == id);
            notifier.selectCustomer(customer);
          },
        ),
      ),
    );
  }

  Widget _buildMutationToggle(
      TransactionFormState formState, TransactionFormNotifier notifier) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: MutationCode.values.map((code) {
          final isSelected = formState.mutationCode == code;
          return Expanded(
            child: GestureDetector(
              onTap: () => notifier.setMutationCode(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  code.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textLight,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker(
      TransactionFormState formState, TransactionFormNotifier notifier) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: formState.transactionDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (picked != null) notifier.setTransactionDate(picked);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM yyyy').format(formState.transactionDate),
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const Icon(Icons.calendar_today,
                size: 18, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ─────────────────────────────────────────────────────

  void _showBarcodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: AppTheme.primaryBlue),
            const SizedBox(width: 10),
            Text('Scan / Input Barcode',
                style: GoogleFonts.outfit(fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Scan barcode atau ketik nomor series...',
              prefixIcon: Icon(Icons.qr_code),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                ref
                    .read(transactionFormProvider.notifier)
                    .addManualBarcode(val.trim());
                controller.clear();
              }
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(transactionFormProvider.notifier)
                    .addManualBarcode(controller.text.trim());
                controller.clear();
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.keyboard, color: AppTheme.primaryBlue),
            const SizedBox(width: 10),
            Text('Input Series Manual', style: GoogleFonts.outfit(fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Masukkan nomor series tabung...',
              prefixIcon: Icon(Icons.numbers),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                ref
                    .read(transactionFormProvider.notifier)
                    .addManualBarcode(val.trim());
                Navigator.pop(ctx);
              }
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(transactionFormProvider.notifier)
                    .addManualBarcode(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showUnauditedDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
            const SizedBox(width: 10),
            Text('Tabung Non-Barcode', style: GoogleFonts.outfit(fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Item ini belum diaudit / belum memiliki barcode. Masukkan deskripsi item.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.textLight),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Oksigen 6m3 tanpa label',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    ref
                        .read(transactionFormProvider.notifier)
                        .addUnauditedItem(val.trim());
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(transactionFormProvider.notifier)
                    .addUnauditedItem(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
