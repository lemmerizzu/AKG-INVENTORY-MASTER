import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../shared/providers/overlay_manager.dart';
import '../../../shared/widgets/ak_data_table.dart';
import 'inventory_audit_provider.dart';
import '../domain/inventory_audit.dart';

class InventoryAuditView extends ConsumerWidget {
  const InventoryAuditView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditList = ref.watch(inventoryAuditListProvider);

    return Column(
      children: [
        // --- Page Header ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.borderColor)),
          ),
          child: Row(
            children: [
              Text('Inventory Audit', 
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  final newId = 'new-audit-${DateTime.now().millisecondsSinceEpoch}';
                  ref.read(overlayManagerProvider.notifier).open(newId, 'New Inventory Audit');
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('NEW AUDIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.googleBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // --- List Content ---
        Expanded(
          child: auditList.when(
            data: (audits) => _buildAuditList(context, ref, audits),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditList(BuildContext context, WidgetRef ref, List<InventoryAudit> audits) {
    if (audits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text('No audits found.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.read(inventoryAuditListProvider.notifier).refresh(),
              child: const Text('REFRESH'),
            ),
          ],
        ),
      );
    }

    return AkDataTable(
      columns: const [
        AkTableColumn(label: 'AUDIT NUMBER', flex: 2),
        AkTableColumn(label: 'DATE', flex: 2),
        AkTableColumn(label: 'STATUS', flex: 1, align: TextAlign.center),
        AkTableColumn(label: 'NOTE', flex: 3),
      ],
      rows: audits.map((audit) {
        final isCompleted = audit.status == AuditStatus.completed;

        return AkTableRow(
          onTap: () {
            ref.read(overlayManagerProvider.notifier).open(audit.id, 'Inventory Audit: ${audit.auditNumber}');
          },
          cells: [
            AkTableCell.text(audit.auditNumber, weight: FontWeight.w700, color: AppColors.googleBlue),
            AkTableCell.text(DateFormat('dd MMM yyyy, HH:mm').format(audit.auditDate)),
            AkTableCell.custom(
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.withValues(alpha: 0.1) : AppColors.googleBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCompleted ? 'COMPLETED' : 'DRAFT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isCompleted ? Colors.green : AppColors.googleBlue,
                    ),
                  ),
                ),
              ),
            ),
            AkTableCell.text(audit.note ?? '-'),
          ],
        );
      }).toList(),
    );
  }
}
