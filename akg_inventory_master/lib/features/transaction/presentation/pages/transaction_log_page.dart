import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:akg_inventory_master/core/app_colors.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_history_provider.dart';
import 'package:akg_inventory_master/features/customer/presentation/customer_provider.dart';
import 'package:akg_inventory_master/features/customer/domain/customer.dart';
import 'package:akg_inventory_master/shared/widgets/ak_filter_chip.dart';
import 'package:akg_inventory_master/shared/widgets/ak_section_header.dart';
import 'package:akg_inventory_master/features/transaction/presentation/widgets/transaction_list_item.dart';
import 'package:akg_inventory_master/features/transaction/presentation/widgets/transaction_detail_panel.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_form_provider.dart';
import 'package:akg_inventory_master/shared/providers/overlay_manager.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TransactionLogPage — 3-pane AppSheet-style layout
/// Phase 2 — Grand Refactor
///
/// [Left 640px: Master List] | [Right: Detail Panel]
/// ─────────────────────────────────────────────────────────────────────────────
class TransactionLogPage extends ConsumerWidget {
  const TransactionLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTransactionIdProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── LEFT: Master List ──────────────────────────────────────────────
          Container(
            width: 480,
            decoration: const BoxDecoration(
              color: AppColors.panelBg,
              border: Border(
                right: BorderSide(color: AppColors.borderColor, width: 1),
              ),
            ),
            child: const _TransactionMasterList(),
          ),

          // ── RIGHT: Detail Panel or Empty ───────────────────────────────────
          Expanded(
            child: selectedId == null
                ? const _EmptyDetailPlaceholder()
                : _SelectedDetailPanel(documentId: selectedId),
          ),
        ],
      ),
    );
  }
}

// ── Master List (Left Panel) ──────────────────────────────────────────────────

class _TransactionMasterList extends ConsumerWidget {
  const _TransactionMasterList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredTransactionProvider);
    final filter = ref.watch(transactionFilterProvider);
    final customers = ref.watch(customerListProvider).value ?? [];
    final allAsync = ref.watch(transactionHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Panel Header ───────────────────────────────────────────────
        AkPanelHeader(
          title: 'Transactions',
          trailing: [
            // Total count badge
            if (allAsync.hasValue)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.filterBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${allAsync.value?.length ?? 0}',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            AkIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh',
              onTap: () =>
                  ref.read(transactionHistoryProvider.notifier).refresh(),
            ),
            AkIconButton(
              icon: Icons.add_rounded,
              tooltip: 'Tambah Transaksi',
              color: AppColors.googleBlue,
              onTap: () {}, // TODO: Phase 2 - form
            ),
          ],
        ),

        // ── Filter Row ─────────────────────────────────────────────────
        _FilterRow(filter: filter),
        const Divider(height: 1, color: AppColors.borderColor),

        // ── List ───────────────────────────────────────────────────────
        Expanded(
          child: filteredAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text('Error: $err',
                  style: GoogleFonts.inter(color: AppColors.errorRed)),
            ),
            data: (docs) {
              if (docs.isEmpty) return _buildEmpty(filter.hasActiveFilter);

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final customer = _resolveCustomer(customers, doc.customerId);
                  return _SelectableListItem(
                    doc: doc,
                    customerName: customer.name,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Customer _resolveCustomer(List<Customer> customers, String customerId) {
    return customers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => const Customer(
        id: '',
        customerCode: '?',
        name: 'Unknown Customer',
        address: '',
      ),
    );
  }

  Widget _buildEmpty(bool hasFilter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilter
                ? Icons.filter_list_off_rounded
                : Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilter ? 'Tidak ada hasil filter' : 'Belum ada transaksi',
            style: GoogleFonts.inter(
              color: AppColors.textDisabled,
              fontSize: 13,
            ),
          ),
          if (hasFilter) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {}, // handled by _FilterRow's clear button
              icon: const Icon(Icons.clear_rounded, size: 14),
              label: const Text('Reset filter'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Selectable wrapper (reads+writes selectedId) ──────────────────────────────
class _SelectableListItem extends ConsumerWidget {
  final TransactionDocument doc;
  final String customerName;

  const _SelectableListItem({required this.doc, required this.customerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedTransactionIdProvider);
    return TransactionListItem(
      doc: doc,
      customerName: customerName,
      isSelected: selectedId == doc.id,
      onTap: () =>
          ref.read(selectedTransactionIdProvider.notifier).select(doc.id),
    );
  }
}

// ── Filter Row ────────────────────────────────────────────────────────────────
class _FilterRow extends ConsumerWidget {
  final TransactionFilter filter;
  const _FilterRow({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Mutation filter
          AkFilterChip<String>(
            label: 'Mutasi',
            value: _mutLabel(filter.mutation),
            options: const ['Semua', 'IN', 'OUT', 'OTHER'],
            onChanged: (v) {
              notifier.setMutation(v == 'Semua' ? null : _mutCode(v));
            },
            isActive: filter.mutation != null,
          ),
          const SizedBox(width: 8),

          // Date range filter
          AkDateRangeChip(
            value: filter.dateRange,
            onChanged: notifier.setDateRange,
          ),

          const Spacer(),

          // Clear all (only if active)
          if (filter.hasActiveFilter)
            AkIconButton(
              icon: Icons.clear_all_rounded,
              tooltip: 'Reset semua filter',
              color: AppColors.googleBlue,
              onTap: notifier.clearAll,
            ),
        ],
      ),
    );
  }

  String _mutLabel(MutationCode? code) {
    switch (code) {
      case MutationCode.inbound:
        return 'IN';
      case MutationCode.outbound:
        return 'OUT';
      case MutationCode.other:
        return 'OTHER';
      case null:
        return 'Semua';
    }
  }

  MutationCode? _mutCode(String label) {
    switch (label) {
      case 'IN':
        return MutationCode.inbound;
      case 'OUT':
        return MutationCode.outbound;
      case 'OTHER':
        return MutationCode.other;
      default:
        return null;
    }
  }
}

// ── Detail Panel Wrapper ──────────────────────────────────────────────────────
class _SelectedDetailPanel extends ConsumerWidget {
  final String documentId;
  const _SelectedDetailPanel({required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerListProvider).value ?? [];
    final history = ref.watch(transactionHistoryProvider).value ?? [];
    final docList = history.where((d) => d.id == documentId).toList();

    if (docList.isEmpty) return const _EmptyDetailPlaceholder();

    final doc = docList.first;
    final customer = customers.firstWhere(
      (c) => c.id == doc.customerId,
      orElse: () => const Customer(
        id: '',
        customerCode: '?',
        name: 'Unknown Customer',
        address: '',
      ),
    );

    return TransactionDetailPanel(
      documentId: documentId,
      customer: customer,
      onClose: () =>
          ref.read(selectedTransactionIdProvider.notifier).clear(),
      onEdit: () {
        // Trigger loading data into the form family
        final detailAsync = ref.read(transactionDetailProvider(documentId));
        detailAsync.whenData((details) {
          ref.read(transactionFormProvider(documentId).notifier).loadFromDocument(
                doc,
                details.items,
                customer,
              );
        });
      },
    );
  }
}

// ── Empty State (no selection) ────────────────────────────────────────────────
class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pageBg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.panelBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih dokumen',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Klik transaksi di sebelah kiri\nuntuk melihat detail dokumen',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
