import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_history_provider.dart';
import 'package:akg_inventory_master/features/customer/presentation/customer_provider.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/customer/domain/customer.dart';
import 'package:akg_inventory_master/core/theme.dart';

class TransactionLogPage extends ConsumerStatefulWidget {
  const TransactionLogPage({super.key});

  @override
  ConsumerState<TransactionLogPage> createState() => _TransactionLogPageState();
}

class _TransactionLogPageState extends ConsumerState<TransactionLogPage> {
  MutationCode? _selectedMutation;
  
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(transactionHistoryProvider);
    final customers = ref.watch(customerListProvider).value ?? [];

    final filteredHistory = _selectedMutation == null
        ? history
        : history.where((doc) => doc.mutation == _selectedMutation).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          _buildHeader(),

          // ── Filters ──────────────────────────────────────────────
          _buildFilters(),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: filteredHistory.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final doc = filteredHistory[index];
                      final customer = customers.firstWhere(
                        (c) => c.id == doc.customerId,
                        orElse: () => const Customer(
                          id: '',
                          customerCode: '?',
                          name: 'Unknown Customer',
                          address: '',
                        ),
                      );
                      return _TransactionCard(doc: doc, customer: customer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
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
                child: const Icon(Icons.receipt_long, color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Log Transaksi',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF164E63),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.check_box_outlined, color: Color(0xFF164E63)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Color(0xFF164E63)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Documents',
                  isSelected: _selectedMutation == null,
                  onSelected: () => setState(() => _selectedMutation = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'IN',
                  isSelected: _selectedMutation == MutationCode.inbound,
                  onSelected: () => setState(() => _selectedMutation = MutationCode.inbound),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'OUT',
                  isSelected: _selectedMutation == MutationCode.outbound,
                  onSelected: () => setState(() => _selectedMutation = MutationCode.outbound),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'OTHER',
                  isSelected: _selectedMutation == MutationCode.other,
                  onSelected: () => setState(() => _selectedMutation = MutationCode.other),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi diinput.',
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004D64) : const Color(0xFFE6E8EF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF3F484D),
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionDocument doc;
  final Customer customer;

  const _TransactionCard({required this.doc, required this.customer});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Placeholder
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF181C21),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  doc.sysDocNumber,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, HH:mm').format(doc.transactionDate),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (doc.mutation) {
      case MutationCode.inbound:
        return const Color(0xFF006684);
      case MutationCode.outbound:
        return const Color(0xFF006684);
      case MutationCode.other:
        return const Color(0xFF885116);
    }
  }

  String _getStatusLabel() {
    switch (doc.mutation) {
      case MutationCode.inbound:
        return 'IN';
      case MutationCode.outbound:
        return 'DO';
      case MutationCode.other:
        return 'RTC';
    }
  }

  IconData _getIcon() {
    switch (doc.mutation) {
      case MutationCode.inbound:
        return Icons.local_shipping_outlined;
      case MutationCode.outbound:
        return Icons.local_shipping_outlined;
      case MutationCode.other:
        return Icons.description_outlined;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
