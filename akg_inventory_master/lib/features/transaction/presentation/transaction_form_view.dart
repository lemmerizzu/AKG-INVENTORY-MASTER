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
    final items = ref.watch(itemListProvider);

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
                        Row(
                          children: [
                            Text('Warehouse Transaction',
                                style: GoogleFonts.outfit(
                                    fontSize: 22, fontWeight: FontWeight.w700)),
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

              // ── Inventory Log Input (Active Entry) ────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note, color: AppTheme.primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        Text('Inventory Log Input',
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => notifier.addLine(),
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text('New Entry'),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // Logic: for simplicity, we manage the LAST line as the "active" input in this view
                    if (formState.lines.isNotEmpty) ...[
                      _buildInventoryLogForm(context, formState, notifier, items),
                    ] else
                      Center(
                        child: TextButton(
                          onPressed: () => notifier.addLine(),
                          child: const Text('Klik "New Entry" untuk mulai input item'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryLogForm(BuildContext context, TransactionFormState formState, TransactionFormNotifier notifier, List<Item> items) {
    final activeIndex = formState.lines.length - 1;
    final line = formState.lines[activeIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SKU Selection
            Expanded(
              flex: 2,
              child: _buildField('Produk (SKU)', isRequired: true, child: LayoutBuilder(
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
            ),
            const SizedBox(width: 16),
            // Reserved Qty (if applicable)
            if (formState.inputMode == InputMode.reserve)
              Expanded(
                flex: 1,
                child: _buildField('Target Qty', isRequired: true, child: TextFormField(
                  initialValue: line.reservedQty > 0 ? line.reservedQty.toString() : '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                  ),
                  onChanged: (val) => notifier.updateReservedQty(activeIndex, int.tryParse(val) ?? 0),
                )),
              ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Serial Number Multi-Select Dropdown
        _buildField('Serial Number Tabung (EnumList)', isRequired: true, child: _buildMultiSelectSerials(activeIndex, line, notifier)),
        
        const SizedBox(height: 20),
        
        // Admin Note
        _buildField('Admin Note', child: TextFormField(
          initialValue: line.adminNote,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Catatan tambahan untuk item ini...',
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          ),
          onChanged: (val) => notifier.updateLineAdminNote(activeIndex, val),
        )),
        
        const SizedBox(height: 24),
        
        // Confirm Button (Adds a new entry)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (line.selectedSku == null || line.serialNumbers.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih SKU dan minimal 1 Serial Number!')));
                return;
              }
              notifier.addLine();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item ${line.selectedSku?.itemCode} berhasil ditambahkan ke summary.'),
                  backgroundColor: const Color(0xFF00C853),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text('Confirm & Save Line', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSerials(int index, TransactionLineState line, TransactionFormNotifier notifier) {
    final availableSerials = notifier.getAvailableSerials(line.selectedSku?.id);
    
    return MenuAnchor(
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
            if (line.selectedSku == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih SKU terlebih dahulu!')));
              return;
            }
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
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
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(sn, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
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
            width: 250,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        dropdownMenuEntries: customers
            .map((c) => DropdownMenuEntry(
                  value: c.id,
                  label: c.name,
                ))
            .toList(),
        onSelected: (id) {
          if (id != null) {
            final customer = customers.firstWhere((c) => c.id == id);
            notifier.selectCustomer(customer);
          }
        },
      );
    });
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

  Widget _buildDateTimePicker(BuildContext context,
      TransactionFormState formState, TransactionFormNotifier notifier) {
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
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(formState.transactionDate),
          );
          if (time != null) {
            notifier.setTransactionDate(DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            ));
          }
        }
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
              DateFormat('MM/dd/yyyy hh:mm a').format(formState.transactionDate),
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const Icon(Icons.calendar_today,
                size: 18, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildInputModeToggle(
      TransactionFormState formState, TransactionFormNotifier notifier) {
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
                  mode.name.toUpperCase(),
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
}
