import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:akg_inventory_master/core/app_colors.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_history_provider.dart';
import 'package:akg_inventory_master/shared/widgets/ak_badge.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TransactionListItem — AppSheet-style single row in the master list
/// Phase 2 — Grand Refactor
///
/// Layout (Figma pola):
///   [LEFT: Customer name bold, doc number italic grey]  [RIGHT: date + mutation badge]
/// ─────────────────────────────────────────────────────────────────────────────
class TransactionListItem extends ConsumerStatefulWidget {
  final TransactionDocument doc;
  final String customerName;
  final bool isSelected;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.doc,
    required this.customerName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  ConsumerState<TransactionListItem> createState() =>
      _TransactionListItemState();
}

class _TransactionListItemState extends ConsumerState<TransactionListItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isVoid = widget.doc.status == DocStatus.void_;
    final editedAsync = ref.watch(docHasEditedIconProvider(widget.doc.id));

    Color bg;
    if (widget.isSelected) {
      bg = AppColors.selectedBg;
    } else if (_hovering) {
      bg = AppColors.dividerColor;
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.dividerColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              // ── Left: Text info ──────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer name
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.customerName,
                            style: GoogleFonts.inter(
                              color: isVoid
                                  ? AppColors.textDisabled
                                  : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Edited icon (subtle)
                        if (editedAsync.value ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Tooltip(
                              message: 'Dokumen pernah diedit',
                              child: Icon(
                                Icons.history_edu_rounded,
                                size: 13,
                                color: AppColors.warningOrange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Doc number
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.doc.sysDocNumber,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Right: Date + Badge ──────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd MMM').format(widget.doc.transactionDate),
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Mutation badge or VOID badge
                  isVoid
                      ? AkBadge.docStatus('VOID')
                      : AkBadge.mutation(
                          _mutationLabel(widget.doc.mutation)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
