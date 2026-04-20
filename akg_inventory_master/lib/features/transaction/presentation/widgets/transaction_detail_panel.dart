import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:akg_inventory_master/core/app_colors.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/transaction/domain/audit_log.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_history_provider.dart';
import 'package:akg_inventory_master/features/transaction/data/transaction_repository.dart';
import 'package:akg_inventory_master/features/customer/domain/customer.dart';
import 'package:akg_inventory_master/shared/widgets/ak_badge.dart';
import 'package:akg_inventory_master/shared/widgets/ak_action_button.dart';
import 'package:akg_inventory_master/shared/widgets/ak_detail_field.dart';
import 'package:akg_inventory_master/shared/widgets/ak_data_table.dart';
import 'package:akg_inventory_master/shared/widgets/ak_section_header.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TransactionDetailPanel — Right panel showing document detail
/// Phase 2 — Grand Refactor
///
/// Layout (Figma):
///   [DetailHeader: doc number | #N rev | nav icons]
///   [ActionButtonsRow: BEGIN SCAN | CREATE INVOICE]
///   [DetailGrid 2-col: DOC NUMBER, DATETIME, CUSTOMER, MUTATION, MAKER, DRIVER]
///   [SHIPPING ADDRESS full-width]
///   [ITEM LIST section: AkDataTable(ITEM | QTY | SERIES | PRICE)]
///   [REV HISTORY section: AkDataTable(ACTION | NOTE | DATETIME)]
///   [FooterStats: Total Qty | Total Price]
/// ─────────────────────────────────────────────────────────────────────────────
class TransactionDetailPanel extends ConsumerWidget {
  final String documentId;
  final Customer customer;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;

  const TransactionDetailPanel({
    super.key,
    required this.documentId,
    required this.customer,
    this.onClose,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(transactionDetailProvider(documentId));
    final history = ref.watch(transactionHistoryProvider).value ?? [];
    final docList = history.where((d) => d.id == documentId).toList();
    if (docList.isEmpty) return const SizedBox.shrink();
    final doc = docList.first;

    return Container(
      color: AppColors.panelBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Detail Header ──────────────────────────────────────────────
          _DetailHeader(doc: doc, detailAsync: detailAsync, onClose: onClose),
          const Divider(height: 1, color: AppColors.borderColor),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: detailAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style:
                        GoogleFonts.inter(color: AppColors.errorRed)),
              ),
              data: (detail) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Action Buttons ─────────────────────────────────
                    _buildActionButtons(context, ref, doc, detail),
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.dividerColor),
                    const SizedBox(height: 16),

                    // ── Detail Grid ────────────────────────────────────
                    _buildDetailGrid(doc),
                    const SizedBox(height: 24),

                    // ── Item List Section ──────────────────────────────
                    _buildItemListSection(detail.items),
                    const SizedBox(height: 16),

                    // ── Rev History Section ────────────────────────────
                    _buildRevHistorySection(detail.auditLogs),
                    const SizedBox(height: 24),

                    // ── Footer Stats ───────────────────────────────────
                    _buildFooterStats(detail.items),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref,
      TransactionDocument doc, TransactionDetailState detail) {
    final isVoid = doc.status == DocStatus.void_;
    return AkActionButtonRow(
      buttons: [
        AkActionButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'BEGIN SCAN',
          isDisabled: isVoid,
          onTap: isVoid ? null : () {},
        ),
        AkActionButton(
          icon: Icons.receipt_long_rounded,
          label: 'CREATE INVOICE',
          isDisabled: isVoid,
          iconBg: AppColors.successGreen,
          onTap: isVoid ? null : () {},
        ),
        AkActionButton(
          icon: Icons.print_outlined,
          label: 'PRINT SJ',
          isDisabled: isVoid,
          iconBg: AppColors.textSecondary,
          onTap: isVoid ? null : () {},
        ),
        if (!isVoid)
          AkActionButton.destructive(
            icon: Icons.block_rounded,
            label: 'VOID',
            onTap: () => _showVoidDialog(context, ref, doc),
          ),
      ],
    );
  }

  Widget _buildDetailGrid(TransactionDocument doc) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(doc.transactionDate);
    final mutLabel = _mutationLabel(doc.mutation);

    return AkDetailGrid(
      children: [
        AkDetailField(
          label: 'DOC NUMBER',
          value: doc.sysDocNumber,
          isCode: true,
        ),
        AkDetailField(
          label: 'DATETIME',
          value: dateStr,
        ),
        AkDetailField(
          label: 'CUSTOMER NAME',
          value: customer.name,
        ),
        AkDetailField(
          label: 'MUTATION',
          badgeChild: AkBadge.mutation(mutLabel),
        ),
        AkDetailField(
          label: 'MAKER',
          value: doc.makerName ?? '—',
        ),
        AkDetailField(
          label: 'DRIVER',
          value: doc.driverName ?? '—',
        ),
        AkDetailField(
          label: 'MODE',
          value: doc.inputMode == InputMode.bulk ? 'BULK' : 'RESERVE',
        ),
        AkDetailField(
          label: 'STATUS',
          badgeChild: AkBadge.docStatus(doc.status.name.toUpperCase()),
        ),
        if (doc.poReference != null && doc.poReference!.isNotEmpty)
          AkDetailField(
            label: 'PO REFERENCE',
            value: doc.poReference,
            isCode: true,
          ),
        AkDetailField(
          label: 'SHIPPING ADDRESS',
          value: doc.shippingAddress.isEmpty ? '—' : doc.shippingAddress,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildItemListSection(List<InventoryLedgerEntry> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AkSectionHeader(
          title: 'ITEM LIST',
          count: items.length,
          padding: EdgeInsets.zero,
          actions: const [],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: AkDataTable(
            columns: const [
              AkTableColumn(label: 'ITEM', flex: 3),
              AkTableColumn(label: 'QTY', flex: 1, align: TextAlign.center),
              AkTableColumn(label: 'SERIES / BARCODE', flex: 4),
              AkTableColumn(label: 'HARGA', flex: 2, align: TextAlign.right),
            ],
            rows: items.map((entry) {
              final serials = entry.cylinderBarcode
                      ?.split(' ')
                      .where((s) => s.isNotEmpty)
                      .join(', ') ??
                  '—';
              final harga = entry.rentalPrice != null
                  ? NumberFormat.compact(locale: 'id').format(entry.rentalPrice)
                  : '—';
              return AkTableRow(cells: [
                AkTableCell.text(entry.itemId ?? '—'),
                AkTableCell.text(
                  entry.qty.toString(),
                  align: TextAlign.center,
                  weight: FontWeight.w700,
                ),
                AkTableCell.text(
                  serials,
                  color: AppColors.textSecondary,
                  isCode: true,
                ),
                AkTableCell.text(
                  harga,
                  align: TextAlign.right,
                  color: AppColors.textPrimary,
                ),
              ]);
            }).toList(),
            emptyMessage: 'Tidak ada item pada transaksi ini',
          ),
        ),
      ],
    );
  }

  Widget _buildRevHistorySection(List<AuditLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AkSectionHeader(
          title: 'REV HISTORY',
          count: logs.length,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: AkDataTable(
            columns: const [
              AkTableColumn(label: 'ACTION', flex: 2),
              AkTableColumn(label: 'CATATAN', flex: 4),
              AkTableColumn(label: 'DATETIME', flex: 3),
            ],
            rows: logs.map((log) {
              final dateStr =
                  DateFormat('dd MMM, HH:mm').format(log.createdAt);
              return AkTableRow(cells: [
                AkTableCell.badge(_logActionBadge(log.action)),
                AkTableCell.text(log.note ?? '—',
                    color: AppColors.textSecondary),
                AkTableCell.text(dateStr, color: AppColors.textSecondary),
              ]);
            }).toList(),
            emptyMessage: 'Belum ada riwayat perubahan',
          ),
        ),
      ],
    );
  }

  Widget _buildFooterStats(List<InventoryLedgerEntry> items) {
    final totalQty = items.fold<int>(0, (sum, e) => sum + e.qty);
    final totalPrice = items.fold<double>(
        0, (sum, e) => sum + (e.rentalPrice ?? 0) * e.qty);
    final priceStr = totalPrice > 0
        ? 'Rp ${NumberFormat('#,###', 'id').format(totalPrice)}'
        : 'Rp —';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL QTY',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$totalQty unit',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL PRICE',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                priceStr,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logActionBadge(String action) {
    switch (action) {
      case 'CREATE':
        return AkBadge.custom(
          label: 'CREATE',
          textColor: AppColors.successGreen,
          bgColor: AppColors.successBg,
        );
      case 'EDIT':
        return AkBadge.custom(
          label: 'EDIT',
          textColor: AppColors.warningOrange,
          bgColor: AppColors.warningBg,
        );
      case 'VOID':
        return AkBadge.docStatus('VOID');
      case 'PRINT':
        return AkBadge.custom(
          label: 'PRINT',
          textColor: AppColors.googleBlue,
          bgColor: AppColors.selectedBg,
        );
      default:
        return AkBadge.custom(
          label: action,
          textColor: AppColors.textSecondary,
          bgColor: AppColors.filterBg,
        );
    }
  }

  String _mutationLabel(MutationCode code) {
    switch (code) {
      case MutationCode.inbound:
        return 'IN';
      case MutationCode.outbound:
        return 'OUT';
      case MutationCode.other:
        return 'OTHER';
    }
  }

  void _showVoidDialog(
      BuildContext context, WidgetRef ref, TransactionDocument doc) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Void Dokumen',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dokumen ${doc.sysDocNumber} akan di-VOID dan tidak bisa dipulihkan.\nMasukkan alasan pembatalan:',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Alasan void',
                hintText: 'Misal: Qty salah, sudah double-input...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref
                  .read(transactionRepositoryProvider)
                  .voidTransaction(doc.id, controller.text);
              if (ctx.mounted) Navigator.pop(ctx);
              ref.read(transactionHistoryProvider.notifier).refresh();
            },
            child: const Text('Void Dokumen'),
          ),
        ],
      ),
    );
  }
}

// ── Detail Header ─────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  final TransactionDocument doc;
  final AsyncValue<TransactionDetailState> detailAsync;
  final VoidCallback? onClose;

  const _DetailHeader({
    required this.doc,
    required this.detailAsync,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final revCount = detailAsync.value?.auditLogs.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.panelBg,
      child: Row(
        children: [
          // ── Doc number ─────────────────────────────────────────────────
          Text(
            doc.sysDocNumber,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),

          // ── Rev tag ────────────────────────────────────────────────────
          if (revCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#$revCount rev',
                style: GoogleFonts.inter(
                  color: AppColors.warningOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          const Spacer(),

          // ── Action icons ───────────────────────────────────────────────
          AkIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Tutup',
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}
