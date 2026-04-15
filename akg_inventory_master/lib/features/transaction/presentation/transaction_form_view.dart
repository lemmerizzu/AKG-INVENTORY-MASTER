import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../domain/transaction_document.dart';

class TransactionFormView extends StatefulWidget {
  const TransactionFormView({super.key});

  @override
  State<TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<TransactionFormView>
    with SingleTickerProviderStateMixin {
  MutationCode _mCode = MutationCode.outbound;
  final TextEditingController _docNumberController = TextEditingController();
  DateTime _transactionDate = DateTime.now();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _transactionDate) {
      setState(() => _transactionDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.cardColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
            onPressed: () {},
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description,
                    color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Warehouse Transaction',
                  style: AppTheme.lightTheme.textTheme.titleLarge),
            ],
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Customer Name', isRequired: true),
                const SizedBox(height: 8),
                _buildCustomerSelector(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Mutation Code', isRequired: true),
                          const SizedBox(height: 8),
                          _buildMutationToggle(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Doc Date (Editable)'),
                          const SizedBox(height: 8),
                          _buildDateSelector(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_mCode == MutationCode.outbound) ...[
                  _buildSectionLabel('System Doc Number', isRequired: true),
                  const SizedBox(height: 8),
                  _buildDocNumberInput(),
                  const SizedBox(height: 24),
                ],
                _buildSectionLabel('Shipping Address', isRequired: true),
                const SizedBox(height: 8),
                _buildAddressSelector(),
                const SizedBox(height: 32),
                _buildItemSection(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────────

  Widget _buildSectionLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(text,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textDark)),
        if (isRequired)
          Text(' *',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.error)),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMM yyyy').format(_transactionDate),
                style: AppTheme.lightTheme.textTheme.bodyLarge),
            const Icon(Icons.calendar_today,
                size: 20, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: 'Bpk. Sukirno (Bejo)',
          icon: const Icon(Icons.arrow_drop_down_rounded,
              color: AppTheme.textLight),
          items: ['Bpk. Sukirno (Bejo)', 'PT Gemilang']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child:
                        Text(e, style: AppTheme.lightTheme.textTheme.bodyLarge),
                  ))
              .toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildMutationToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: MutationCode.values.map((code) {
          final isSelected = _mCode == code;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mCode = code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  code.name.toUpperCase(),
                  style: GoogleFonts.inter(
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

  Widget _buildDocNumberInput() {
    return TextFormField(
      controller: _docNumberController,
      decoration: const InputDecoration(
        hintText: 'Auto-generated...',
        filled: true,
        fillColor: AppTheme.cardColor,
      ),
    );
  }

  Widget _buildAddressSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.textLight),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Krajan I, Wringinanom...',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.arrow_drop_down_rounded,
              color: AppTheme.textLight),
        ],
      ),
    );
  }

  Widget _buildItemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kelola Item Logistik',
            style: AppTheme.lightTheme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            // Fixed: removed BorderStyle.dash (unsupported), using solid border
            border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Tabung (Barcode)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Input Series Manual (Insidental)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: BorderSide(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.warning_amber),
                  label: const Text('Tabung Non-Barcode'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor:
                        AppTheme.warning.withValues(alpha: 0.1),
                    foregroundColor: AppTheme.warning,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan Transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
