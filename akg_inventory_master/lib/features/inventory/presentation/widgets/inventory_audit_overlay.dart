import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/ak_data_table.dart';
import '../inventory_audit_provider.dart';
import '../../domain/inventory_audit.dart';

class InventoryAuditOverlay extends ConsumerStatefulWidget {
  final String auditId;
  const InventoryAuditOverlay({super.key, required this.auditId});

  @override
  ConsumerState<InventoryAuditOverlay> createState() => _InventoryAuditOverlayState();
}

class _InventoryAuditOverlayState extends ConsumerState<InventoryAuditOverlay> {
  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(inventoryAuditDetailProvider(widget.auditId));
    final notifier = ref.read(inventoryAuditDetailProvider(widget.auditId).notifier);

    if (detailState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (detailState.error != null) {
      return Center(child: Text('Error: ${detailState.error}', style: const TextStyle(color: Colors.red)));
    }

    final audit = detailState.audit;
    if (audit == null) return const Center(child: Text('Audit not found'));

    final isCompleted = audit.status == AuditStatus.completed;

    return Column(
      children: [
        // --- Header Stats ---
        _buildHeaderStats(detailState),

        // --- Table Body ---
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildAuditTable(detailState, notifier, isCompleted),
          ),
        ),

        // --- Bottom Actions ---
        _buildBottomActions(detailState, notifier, isCompleted),
      ],
    );
  }

  Widget _buildHeaderStats(InventoryAuditDetailState state) {
    final totalSystem = state.lines.fold<int>(0, (sum, l) => sum + l.systemQty);
    final totalPhysical = state.lines.fold<int>(0, (sum, l) => sum + l.physicalQty);
    final totalVariance = totalPhysical - totalSystem;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.panelBg,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'TOTAL SYSTEM', value: totalSystem.toString(), color: AppColors.textSecondary),
          _StatItem(label: 'TOTAL PHYSICAL', value: totalPhysical.toString(), color: AppColors.googleBlue),
          _StatItem(
            label: 'VARIANCE', 
            value: (totalVariance > 0 ? '+' : '') + totalVariance.toString(), 
            color: totalVariance == 0 ? Colors.green : (totalVariance < 0 ? AppColors.errorRed : Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTable(InventoryAuditDetailState state, InventoryAuditDetailNotifier notifier, bool isCompleted) {
    return AkDataTable(
      columns: const [
        AkTableColumn(label: 'ITEM / SKU', flex: 4),
        AkTableColumn(label: 'SYSTEM', flex: 1, align: TextAlign.center),
        AkTableColumn(label: 'PHYSICAL', flex: 2, align: TextAlign.center),
        AkTableColumn(label: 'DIFF', flex: 1, align: TextAlign.center),
        AkTableColumn(label: 'NOTES', flex: 3),
      ],
      rows: state.lines.asMap().entries.map((entry) {
        final idx = entry.key;
        final line = entry.value;
        final diff = line.discrepancy;

        return AkTableRow(
          cells: [
            AkTableCell.custom(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(line.itemCode ?? '', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.googleBlue)),
                  Text(line.itemName ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            AkTableCell.text(line.systemQty.toString(), align: TextAlign.center, weight: FontWeight.w600),
            AkTableCell.custom(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: isCompleted 
                  ? Text(line.physicalQty.toString(), textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.bold))
                  : TextFormField(
                      initialValue: line.physicalQty.toString(),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => notifier.updatePhysicalQty(idx, int.tryParse(v) ?? 0),
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
              ),
            ),
            AkTableCell.custom(
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: diff == 0 ? Colors.green.withValues(alpha: 0.1) : (diff < 0 ? AppColors.errorRed.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (diff > 0 ? '+' : '') + diff.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 12, 
                      fontWeight: FontWeight.w800, 
                      color: diff == 0 ? Colors.green : (diff < 0 ? AppColors.errorRed : Colors.orange)
                    ),
                  ),
                ),
              ),
            ),
            AkTableCell.custom(
              isCompleted 
                ? Text(line.note ?? '-', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))
                : TextFormField(
                    initialValue: line.note,
                    onChanged: (v) => notifier.updateLineNote(idx, v),
                    style: GoogleFonts.inter(fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Add note...',
                      isDense: true,
                    ),
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBottomActions(InventoryAuditDetailState state, InventoryAuditDetailNotifier notifier, bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.panelBg,
          border: Border(top: BorderSide(color: AppColors.borderColor)),
        ),
        child: Center(
          child: Text('AUDIT COMPLETED & LOCKED', 
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.green, fontSize: 12, letterSpacing: 1)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.panelBg,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Text('All variances will be logged.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          const Spacer(),
          TextButton(
            onPressed: state.isSaving ? null : () => notifier.saveDraft(),
            child: Text(state.isSaving ? 'SAVING...' : 'SAVE DRAFT'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: state.isSaving ? null : () => _confirmComplete(context, notifier),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('FINALIZE AUDIT'),
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

  Future<void> _confirmComplete(BuildContext context, InventoryAuditDetailNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalize Audit?'),
        content: const Text('Once completed, this audit will be locked and discrepancies will be permanently recorded based on this count.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('YES, FINALIZE')),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.completeAudit();
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
