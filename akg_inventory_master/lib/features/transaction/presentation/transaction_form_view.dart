import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../domain/transaction_document.dart';
import '../../customer/domain/customer.dart';
import '../../customer/presentation/customer_provider.dart';
import '../../inventory/domain/item.dart';
import '../../inventory/presentation/item_master_provider.dart';
import 'transaction_form_provider.dart';
import '../../../shared/widgets/ak_data_table.dart';
import '../../../shared/widgets/ak_section_header.dart';
import '../../../shared/widgets/ak_detail_field.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TransactionFormOverlay — Modular form that fits inside AkFloatingWindow
/// Strictly obeys AKG UI components & style
/// ─────────────────────────────────────────────────────────────────────────────

class TransactionFormOverlay extends ConsumerStatefulWidget {
  final String documentId;
  const TransactionFormOverlay({super.key, required this.documentId});

  @override
  ConsumerState<TransactionFormOverlay> createState() => _TransactionFormOverlayState();
}

class _TransactionFormOverlayState extends ConsumerState<TransactionFormOverlay> {
  final _docNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _policeNumberController = TextEditingController();
  final _serialInputController = TextEditingController();
  final _revisionNoteController = TextEditingController();

  int _activeTab = 0; // 0: ITEM LIST, 1: HEADER INFO

  @override
  void dispose() {
    _docNumberController.dispose();
    _addressController.dispose();
    _driverNameController.dispose();
    _policeNumberController.dispose();
    _serialInputController.dispose();
    _revisionNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider(widget.documentId));
    final notifier = ref.read(transactionFormProvider(widget.documentId).notifier);
    final customers = ref.watch(customerListProvider).value ?? [];
    final items = ref.watch(itemListProvider).value ?? [];

    // Sync controllers
    if (_addressController.text != formState.shippingAddress) {
      _addressController.text = formState.shippingAddress;
    }
    if (_docNumberController.text != formState.sysDocNumber) {
      _docNumberController.text = formState.sysDocNumber;
    }
    if (_revisionNoteController.text != formState.revisionNote) {
      _revisionNoteController.text = formState.revisionNote;
    }

    // Listen for saved messages/errors
    ref.listen<TransactionFormState>(transactionFormProvider(widget.documentId), (prev, next) {
      if (next.savedMessage != null && prev?.savedMessage != next.savedMessage) {
        final isError = next.savedMessage!.startsWith('!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.savedMessage!),
            backgroundColor: isError ? AppColors.errorRed : const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
        );
        notifier.clearMessage();
      }
    });

    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _activeTab,
            children: [
              _buildItemListTab(formState, notifier, items),
              _buildHeaderInfoTab(formState, notifier, customers),
            ],
          ),
        ),

        // Bottom Banner / Actions
        _buildBottomActions(formState, notifier),
      ],
    );
  }

  Widget _buildItemListTab(TransactionFormState formState, TransactionFormNotifier notifier, List<Item> items) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              AkSectionHeader(
                title: 'ITEMS',
                count: formState.lines.length,
                actions: [
                  AkSectionAction(
                    label: 'ADD ITEM',
                    icon: Icons.add_rounded,
                    onTap: () => notifier.addLine(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildItemsDataTable(formState, notifier),
                ),
              ),
            ],
          ),
        ),
        if (formState.isSidebarOpen)
          Container(
            width: 320,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.borderColor)),
              color: Colors.white,
            ),
            child: _buildSidebar(formState, notifier, items),
          ),
      ],
    );
  }

  Widget _buildItemsDataTable(TransactionFormState formState, TransactionFormNotifier notifier) {
    return AkDataTable(
      columns: const [
        AkTableColumn(label: 'SKU & PRODUCT', flex: 3),
        AkTableColumn(label: 'QTY', flex: 1, align: TextAlign.center),
        AkTableColumn(label: 'SERIAL NUMBERS', flex: 4),
        AkTableColumn(label: 'ACTIONS', flex: 2, align: TextAlign.right),
      ],
      rows: formState.lines.asMap().entries.map((entry) {
        final idx = entry.key;
        final line = entry.value;
        return AkTableRow(
          cells: [
            AkTableCell.text(line.selectedSku?.itemCode ?? 'Select...', 
              weight: FontWeight.w600),
            AkTableCell.text(line.qty.toString(), align: TextAlign.center, weight: FontWeight.w700),
            AkTableCell.text(line.serialNumbers.join(', '), isCode: true),
            AkTableCell.custom(
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AkIconButton(
                    icon: Icons.edit_outlined,
                    onTap: () => notifier.editLine(idx),
                    size: 16,
                  ),
                  AkIconButton(
                    icon: Icons.delete_outline_rounded,
                    onTap: () => notifier.removeLine(idx),
                    color: AppColors.errorRed,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
      emptyMessage: 'Belum ada item ditambahkan',
    );
  }

  Widget _buildHeaderInfoTab(TransactionFormState formState, TransactionFormNotifier notifier, List<Customer> customers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AkSectionHeader(title: 'HEADER INFORMATION', showDivider: true, padding: EdgeInsets.zero),
          const SizedBox(height: 20),
          
          // ── Revision Section (If editing completed doc) ──
          if (formState.isEditMode && formState.originalStatus == DocStatus.completed) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REVISION NOTE REQUIRED', 
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.errorRed)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _revisionNoteController,
                    onChanged: notifier.setRevisionNote,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Alasan revisi dokumen ini...',
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          AkDetailGrid(
            children: [
              AkDetailField(
                label: 'CUSTOMER',
                badgeChild: _buildCustomerDropdown(formState, notifier, customers),
                fullWidth: true,
              ),
              AkDetailField(
                label: 'MUTATION TYPE',
                badgeChild: _buildMutationToggle(formState, notifier),
              ),
              AkDetailField(
                label: 'DATE & TIME',
                badgeChild: _buildDateTimePicker(context, formState, notifier),
              ),
              AkDetailField(
                label: 'DOC NUMBER',
                badgeChild: TextFormField(
                  controller: _docNumberController,
                  onChanged: notifier.setDocNumber,
                  decoration: const InputDecoration(hintText: 'Auto-generate...'),
                ),
              ),
              AkDetailField(
                label: 'SHIPPING ADDRESS',
                fullWidth: true,
                badgeChild: TextFormField(
                  controller: _addressController,
                  onChanged: notifier.setShippingAddress,
                  decoration: const InputDecoration(hintText: 'Alamat pengiriman...'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(TransactionFormState formState, TransactionFormNotifier notifier, List<Item> items) {
    final idx = formState.activeLineIndex;
    if (idx == -1) return const SizedBox.shrink();
    final line = formState.lines[idx];

    return Column(
      children: [
        AkPanelHeader(
          title: 'Line Editor',
          trailing: [
            AkIconButton(icon: Icons.close_rounded, onTap: () => notifier.closeSidebar()),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildField('PRODUK / SKU', child: _buildSkuDropdown(line, notifier, items, idx)),
              const SizedBox(height: 20),
              _buildField('QUANTITY', child: TextFormField(
                initialValue: line.manualQty.toString(),
                onChanged: (v) => notifier.updateManualQty(idx, int.tryParse(v) ?? 0),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.numbers_rounded, size: 18)),
              )),
              const SizedBox(height: 20),
              _buildField('SERIAL NUMBERS', child: _buildMultiSelectSerials(idx, line, notifier)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(TransactionFormState formState, TransactionFormNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.panelBg,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          // Tab Toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.filterBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _MiniTab(label: 'ITEM LIST', isSelected: _activeTab == 0, onTap: () => setState(() => _activeTab = 0)),
                _MiniTab(label: 'HEADER INFO', isSelected: _activeTab == 1, onTap: () => setState(() => _activeTab = 1)),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: formState.isSaving ? null : () => notifier.saveTransaction(),
            icon: formState.isSaving 
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(formState.originalStatus == DocStatus.completed ? 'UPDATE REVISION' : 'SAVE TRANSACTION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.googleBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildField(String label, {required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 8),
        child,
    ]);
  }

  Widget _buildCustomerDropdown(TransactionFormState formState, TransactionFormNotifier notifier, List<Customer> customers) {
    return LayoutBuilder(builder: (context, constraints) {
      return DropdownMenu<String>(
        width: constraints.maxWidth,
        initialSelection: formState.selectedCustomer?.id,
        enableSearch: true,
        enableFilter: true,
        requestFocusOnTap: true,
        hintText: 'Pilih customer...',
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderColor)),
        ),
        dropdownMenuEntries: customers.map((c) => DropdownMenuEntry(value: c.id, label: c.name)).toList(),
        onSelected: (id) {
          if (id != null) {
            final c = customers.firstWhere((cust) => cust.id == id);
            notifier.selectCustomer(c);
          }
        },
      );
    });
  }

  Widget _buildMutationToggle(TransactionFormState formState, TransactionFormNotifier notifier) {
    return Row(
      children: [
        _CompactToggle(label: 'INBOUND', value: MutationCode.inbound, current: formState.mutationCode, onSelect: notifier.setMutationCode),
        const SizedBox(width: 8),
        _CompactToggle(label: 'OUTBOUND', value: MutationCode.outbound, current: formState.mutationCode, onSelect: notifier.setMutationCode),
      ],
    );
  }

  Widget _buildDateTimePicker(BuildContext context, TransactionFormState formState, TransactionFormNotifier notifier) {
    final fmt = DateFormat('dd MMM yyyy, HH:mm').format(formState.transactionDate);
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: formState.transactionDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (date != null) {
           if (!context.mounted) return;
           final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(formState.transactionDate));
           if (time != null) {
             notifier.setTransactionDate(DateTime(date.year, date.month, date.day, time.hour, time.minute));
           }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(fmt, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildSkuDropdown(TransactionLineState line, TransactionFormNotifier notifier, List<Item> items, int idx) {
    return LayoutBuilder(builder: (context, constraints) {
      return DropdownMenu<String>(
        width: constraints.maxWidth,
        initialSelection: line.selectedSku?.id,
        enableSearch: true,
        enableFilter: true,
        requestFocusOnTap: true,
        hintText: 'Pilih SKU...',
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderColor)),
        ),
        dropdownMenuEntries: items.map((i) => DropdownMenuEntry(value: i.id, label: i.itemCode)).toList(),
        onSelected: (id) {
          if (id != null) {
            final sku = items.firstWhere((i) => i.id == id);
            notifier.updateLineSku(idx, sku);
          }
        },
      );
    });
  }

  Widget _buildMultiSelectSerials(int idx, TransactionLineState line, TransactionFormNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(8), color: AppColors.pageBg),
      child: Text(line.serialNumbers.isEmpty ? 'Tap to manage serials...' : line.serialNumbers.join(', '), 
        style: GoogleFonts.inter(fontSize: 12, color: line.serialNumbers.isEmpty ? AppColors.textDisabled : AppColors.textPrimary)),
    );
  }
}

class _MiniTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _MiniTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? AppColors.googleBlue : AppColors.textSecondary)),
      ),
    );
  }
}

class _CompactToggle extends StatelessWidget {
  final String label;
  final MutationCode value;
  final MutationCode current;
  final ValueChanged<MutationCode> onSelect;
  const _CompactToggle({required this.label, required this.value, required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.googleBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.googleBlue : AppColors.borderColor),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? AppColors.googleBlue : AppColors.textSecondary)),
      ),
    );
  }
}

