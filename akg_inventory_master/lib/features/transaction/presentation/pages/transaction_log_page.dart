import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_history_provider.dart';
import 'package:akg_inventory_master/features/customer/presentation/customer_provider.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/customer/domain/customer.dart';
import 'package:akg_inventory_master/core/theme.dart';
import 'package:akg_inventory_master/features/transaction/presentation/pages/transaction_detail_view.dart';

class TransactionLogPage extends ConsumerStatefulWidget {
  const TransactionLogPage({super.key});

  @override
  ConsumerState<TransactionLogPage> createState() => _TransactionLogPageState();
}

class _TransactionLogPageState extends ConsumerState<TransactionLogPage> {
  MutationCode? _selectedMutation;
  
  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(transactionHistoryProvider);
    final selectedId = ref.watch(selectedTransactionIdProvider);
    final customers = ref.watch(customerListProvider).value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Row(
        children: [
          // ── Sidebar List (Left) ───────────────────────────────────
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(
                  child: historyAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (history) {
                      final filteredHistory = _selectedMutation == null
                          ? history
                          : history.where((doc) => doc.mutation == _selectedMutation).toList();

                      if (filteredHistory.isEmpty) return _buildEmptyState();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final doc = filteredHistory[index];
                          final customer = customers.firstWhere(
                            (c) => c.id == doc.customerId,
                            orElse: () => const Customer(id: '', customerCode: '?', name: 'Unknown', address: ''),
                          );
                          return _TransactionCard(
                            doc: doc, 
                            customer: customer,
                            isSelected: selectedId == doc.id,
                            onTap: () => ref.read(selectedTransactionIdProvider.notifier).select(doc.id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Detail View (Right) ──────────────────────────────────
          Expanded(
            child: selectedId == null
                ? _buildNoSelection()
                : TransactionDetailView(documentId: selectedId),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Log Transaksi',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF164E63),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => ref.read(transactionHistoryProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh, size: 20, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'ALL',
              isSelected: _selectedMutation == null,
              onSelected: () => setState(() => _selectedMutation = null),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'IN',
              isSelected: _selectedMutation == MutationCode.inbound,
              onSelected: () => setState(() => _selectedMutation = MutationCode.inbound),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'OUT',
              isSelected: _selectedMutation == MutationCode.outbound,
              onSelected: () => setState(() => _selectedMutation = MutationCode.outbound),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'RTC',
              isSelected: _selectedMutation == MutationCode.other,
              onSelected: () => setState(() => _selectedMutation = MutationCode.other),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('No transactions found', style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNoSelection() {
    return Container(
      color: const Color(0xFFF8F9FF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
              child: const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFE2E8F0)),
            ),
            const SizedBox(height: 24),
            Text('Select a document', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 8),
            Text('Select a transaction from the list to view details', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF164E63) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF64748B)),
        ),
      ),
    );
  }
}

class _TransactionCard extends ConsumerWidget {
  final TransactionDocument doc;
  final Customer customer;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransactionCard({required this.doc, required this.customer, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor();
    final editIconAsync = ref.watch(docHasEditedIconProvider(doc.id));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(_getIcon(), color: statusColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (editIconAsync.value ?? false)
                        const Icon(Icons.history_edu, size: 14, color: Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(doc.sysDocNumber, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textLight)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(DateFormat('MMM dd').format(doc.transactionDate), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                Text(DateFormat('HH:mm').format(doc.transactionDate), style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (doc.mutation) {
      case MutationCode.inbound: return const Color(0xFF006684);
      case MutationCode.outbound: return const Color(0xFF006684);
      case MutationCode.other: return const Color(0xFF885116);
    }
  }

  IconData _getIcon() {
    switch (doc.mutation) {
      case MutationCode.inbound: return Icons.login;
      case MutationCode.outbound: return Icons.logout;
      case MutationCode.other: return Icons.swap_horiz;
    }
  }
}
