import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../domain/transaction_document.dart';
import '../../customer/domain/customer.dart';
import '../../customer/presentation/customer_provider.dart';
import '../../inventory/domain/item.dart';
import '../../inventory/presentation/item_master_provider.dart';
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
  final _driverNameController = TextEditingController();
  final _policeNumberController = TextEditingController();
  final _serialInputController = TextEditingController();
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
    _driverNameController.dispose();
    _policeNumberController.dispose();
    _serialInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);
    final customers = ref.watch(customerListProvider).value ?? [];
    final items = ref.watch(itemListProvider).value ?? [];

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
    
    // Sync driver/vehicle controllers
    if (_driverNameController.text != (formState.driverName ?? '')) {
      _driverNameController.text = formState.driverName ?? '';
    }
    if (_policeNumberController.text != (formState.policeNumber ?? '')) {
      _policeNumberController.text = formState.policeNumber ?? '';
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            // ── Main Content Area ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page header
                    _buildHeader(context, formState, notifier),
                    const SizedBox(height: 28),

                    // ── Transaction Header (Customer & Doc Info) ──────
                    _buildTransactionHeaderCard(formState, notifier, customers),
                    const SizedBox(height: 28),

                    // ── Summary Table ────────────────────────────────
                    _buildSummaryTable(formState, notifier),
                    const SizedBox(height: 40),

                    // ── Global Action Buttons ────────────────────────
                    _buildGlobalActions(formState, notifier),
                  ],
                ),
              ),
            ),

            // ── Right Sidebar (Active Line Editor) ───────────────
            if (formState.isSidebarOpen)
              _buildSidebar(context, formState, notifier, items),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransactionFormState formState, TransactionFormNotifier notifier) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.description_outlined, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Warehouse Transaction',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.3)),
                  ),
                  child: Text('OPEN (DRAFT)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF00C853))),
                ),
              ],
            ),
            Text('Buat transaksi keluar/masuk tabung',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
          ],
        ),
        const Spacer(),
        // Begin Scan Button
        ElevatedButton.icon(
          onPressed: () => notifier.toggleScanner(),
          icon: Icon(formState.isScannerEnabled ? Icons.qr_code_scanner : Icons.scanner_outlined, size: 18),
          label: Text(formState.isScannerEnabled ? 'Scanner ON' : 'Begin Scan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: formState.isScannerEnabled ? const Color(0xFF00C853) : AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(width: 12),
        // New Entry Button
        OutlinedButton.icon(
          onPressed: () => notifier.addLine(),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('New Entry'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryBlue,
            side: const BorderSide(color: AppTheme.primaryBlue),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(width: 12),
        // Reset button
        OutlinedButton.icon(
          onPressed: () {
            notifier.resetForm();
            _docNumberController.clear();
            _addressController.clear();
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textLight,
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHeaderCard(TransactionFormState formState, TransactionFormNotifier notifier, List<Customer> customers) {
    return Container(
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
                      hintText: 'Kosongkan u/ Auto-Generate...',
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
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 20),
                suffixIcon: formState.selectedCustomer != null
                    ? IconButton(
                        icon: const Icon(Icons.sync, size: 18, color: AppTheme.primaryBlue),
                        tooltip: 'Gunakan alamat customer',
                        onPressed: () {
                          notifier.setShippingAddress(formState.selectedCustomer!.address);
                          _addressController.text = formState.selectedCustomer!.address;
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  'Driver Name',
                  child: TextFormField(
                    controller: _driverNameController,
                    onChanged: (val) => notifier.setDriverInfo(val, _policeNumberController.text),
                    decoration: const InputDecoration(
                      hintText: 'Nama pengemudi...',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildField(
                  'No. Polisi / Kendaraan',
                  child: TextFormField(
                    controller: _policeNumberController,
                    onChanged: (val) => notifier.setDriverInfo(_driverNameController.text, val),
                    decoration: const InputDecoration(
                      hintText: 'L XXXX XX',
                      prefixIcon: Icon(Icons.local_shipping_outlined, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTable(TransactionFormState formState, TransactionFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Summary of Log Entries',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${formState.lines.length} items added',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: formState.lines.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('Belum ada item ditambahkan', style: GoogleFonts.inter(color: AppTheme.textLight)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => notifier.addLine(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                        child: const Text('Add First Item'),
                      ),
                    ],
                  ),
                )
              : DataTable(
                  headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.textLight, fontSize: 13),
                  dataTextStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark),
                  columns: const [
                    DataColumn(label: Text('SKU & PRODUCT')),
                    DataColumn(label: Text('SERIAL NUMBERS')),
                    DataColumn(label: Text('QTY', textAlign: TextAlign.center)),
                    DataColumn(label: Text('NOTE')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: formState.lines.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final line = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text(line.selectedSku?.itemCode ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(
                          SizedBox(
                            width: 250,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: line.serialNumbers.map((sn) => Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(sn, style: const TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                                )).toList(),
                              ),
                            ),
                          ),
                        ),
                        DataCell(Center(child: Text(line.qty.toString(), style: const TextStyle(fontWeight: FontWeight.bold)))),
                        DataCell(Text(line.adminNote, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryBlue),
                                onPressed: () => notifier.editLine(idx),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                                onPressed: () => notifier.removeLine(idx),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildGlobalActions(TransactionFormState formState, TransactionFormNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => notifier.saveTransaction(actionStatus: DocStatus.draft),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save as Draft'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => notifier.saveTransaction(actionStatus: DocStatus.completed),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Confirm & Post Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, TransactionFormState formState, TransactionFormNotifier notifier, List<Item> items) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Text('Line Detail Editor',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => notifier.closeSidebar(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildInventoryLogEditor(context, formState, notifier, items),
            ),
          ),
          
          // Sidebar Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.closeSidebar(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      notifier.closeSidebar();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Keep & Close'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryLogEditor(BuildContext context, TransactionFormState formState, TransactionFormNotifier notifier, List<Item> items) {
    if (formState.activeLineIndex == -1 || formState.activeLineIndex >= formState.lines.length) {
      return const Center(child: Text('No active line'));
    }
    
    final activeIndex = formState.activeLineIndex;
    final line = formState.lines[activeIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SKU Selection
        _buildField('Produk (SKU)', isRequired: true, child: LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<String>(
              width: constraints.maxWidth,
              initialSelection: line.selectedSku?.id,
              hintText: 'Pilih SKU...',
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              textStyle: GoogleFonts.inter(fontSize: 14),
              inputDecorationTheme: InputDecorationTheme(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                filled: true,
                fillColor: AppTheme.background,
              ),
              dropdownMenuEntries: items.map((t) => DropdownMenuEntry(
                value: t.id,
                label: '${t.itemCode} - ${t.name}',
              )).toList(),
              onSelected: (val) {
                if (val != null) {
                  final sku = items.firstWhere((i) => i.id == val);
                  notifier.updateLineSku(activeIndex, sku);
                }
              },
            );
          }
        )),
        const SizedBox(height: 20),

        // Serial Number Toggle (EnumList)
        _buildField('Serial Number Tabung', child: _buildMultiSelectSerials(activeIndex, line, notifier)),
        const SizedBox(height: 12),

        // Manual Serial Input (Keyboard)
        if (!formState.isScannerEnabled)
          _buildField('Manual Keyboard Input Serial', child: TextFormField(
            controller: _serialInputController,
            decoration: InputDecoration(
              hintText: 'Type SN then Enter...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                onPressed: () {
                  if (_serialInputController.text.isNotEmpty) {
                    notifier.addLineSerialNumber(activeIndex, _serialInputController.text);
                    _serialInputController.clear();
                  }
                },
              ),
              filled: true,
              fillColor: AppTheme.background,
            ),
            onFieldSubmitted: (val) {
              if (val.isNotEmpty) {
                notifier.addLineSerialNumber(activeIndex, val);
                _serialInputController.clear();
              }
            },
          )),
        const SizedBox(height: 20),

        // Manual Qty (Locked if SN is present, or for bulk/non-serialized)
        Row(
          children: [
            Expanded(
              child: _buildField('Qty (Manual Input)', child: TextFormField(
                key: ValueKey('qty-$activeIndex-${line.manualQty}'),
                initialValue: line.manualQty.toString(),
                keyboardType: TextInputType.number,
                enabled: line.serialNumbers.isEmpty,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: line.serialNumbers.isNotEmpty ? Colors.grey.withValues(alpha: 0.1) : AppTheme.background,
                  prefixIcon: const Icon(Icons.numbers, size: 18),
                  hintText: '0',
                ),
                onChanged: (val) => notifier.updateManualQty(activeIndex, int.tryParse(val) ?? 0),
              )),
            ),
            if (formState.inputMode == InputMode.reserve) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildField('Target Reserve', child: TextFormField(
                  key: ValueKey('res-$activeIndex-${line.reservedQty}'),
                  initialValue: line.reservedQty.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: AppTheme.background,
                    prefixIcon: Icon(Icons.flag_outlined, size: 18),
                  ),
                  onChanged: (val) => notifier.updateReservedQty(activeIndex, int.tryParse(val) ?? 0),
                )),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        
        // Admin Note
        _buildField('Admin Note', child: TextFormField(
          key: ValueKey('note-$activeIndex'),
          initialValue: line.adminNote,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Catatan tambahan untuk item ini...',
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          ),
          onChanged: (val) => notifier.updateLineAdminNote(activeIndex, val),
        )),
      ],
    );
  }

  Widget _buildMultiSelectSerials(int index, TransactionLineState line, TransactionFormNotifier notifier) {
    if (line.selectedSku == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
        child: const Text('Pilih SKU terlebih dahulu', style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontStyle: FontStyle.italic)),
      );
    }

    final availableSerials = notifier.getAvailableSerials(line.selectedSku?.id);
    
    return MenuAnchor(
      builder: (context, controller, child) {
        return InkWell(
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: line.serialNumbers.isEmpty
                      ? Text('Pilih Serial Number...', style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: line.serialNumbers.map((sn) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(sn, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => notifier.toggleSerialNumber(index, sn),
                                  child: const Icon(Icons.close, size: 14, color: AppTheme.primaryBlue),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppTheme.textLight),
              ],
            ),
          ),
        );
      },
      menuChildren: availableSerials.map((sn) {
        final isSelected = line.serialNumbers.contains(sn);
        return MenuItemButton(
          closeOnActivate: false,
          onPressed: () => notifier.toggleSerialNumber(index, sn),
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => notifier.toggleSerialNumber(index, sn),
                  activeColor: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(sn, style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Field helpers ───────────────────────────────────────────────

  Widget _buildField(String label, {bool isRequired = false, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark)),
            if (isRequired) Text(' *', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildCustomerDropdown(TransactionFormState formState, TransactionFormNotifier notifier, List<Customer> customers) {
    return LayoutBuilder(builder: (context, constraints) {
      return DropdownMenu<String>(
        width: constraints.maxWidth,
        initialSelection: formState.selectedCustomer?.id,
        hintText: 'Pilih customer...',
        enableFilter: true,
        enableSearch: true,
        requestFocusOnTap: true,
        textStyle: GoogleFonts.inter(fontSize: 14),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          filled: true,
          fillColor: Colors.white,
        ),
        dropdownMenuEntries: customers.map((c) => DropdownMenuEntry(value: c.id, label: c.name)).toList(),
        onSelected: (id) {
          if (id != null) {
            final customer = customers.firstWhere((c) => c.id == id);
            notifier.selectCustomer(customer);
          }
        },
      );
    });
  }

  Widget _buildMutationToggle(TransactionFormState formState, TransactionFormNotifier notifier) {
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
                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  code.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildDateTimePicker(BuildContext context, TransactionFormState formState, TransactionFormNotifier notifier) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: formState.transactionDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          if (!context.mounted) return;
          final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(formState.transactionDate));
          if (time != null) {
            notifier.setTransactionDate(DateTime(date.year, date.month, date.day, time.hour, time.minute));
          }
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MM/dd/yyyy hh:mm a').format(formState.transactionDate), style: GoogleFonts.inter(fontSize: 14)),
            const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildInputModeToggle(TransactionFormState formState, TransactionFormNotifier notifier) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: InputMode.values.map((mode) {
          final isSelected = formState.inputMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => notifier.setInputMode(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  mode.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
}

