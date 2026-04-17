import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../core/scanner_service.dart';
import '../domain/transaction_document.dart';
import 'transaction_form_view.dart';
import 'transaction_history_provider.dart';
import 'transaction_form_provider.dart';

/// Implements a 3-Column Split-Pane layout mirroring advanced AppSheet views.
/// 1. Left Panel: Document History List.
/// 2. Center Panel: Document Header (Customer, Date, etc).
/// 3. Right Panel: Item Summary & Scan Actions.
class TransactionPageLayout extends ConsumerWidget {
  const TransactionPageLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyDocs = ref.watch(transactionHistoryProvider);
    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);

    // Watch scanner service to ensure it's initialized
    ref.watch(scannerServiceProvider(notifier.processBarcode));

    // Listen for messages/notifications from provider
    ref.listen(transactionFormProvider.select((s) => s.savedMessage), (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            behavior: SnackBarBehavior.floating,
            backgroundColor: next.startsWith('!') ? AppTheme.error : (next.contains('✓') ? const Color(0xFF00C853) : AppTheme.primaryBlue),
            duration: const Duration(seconds: 2),
          ),
        );
        // Clear message after showing? 
        // Notifier should ideally clear it, but for now we just show.
      }
    });
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Left Panel (History List) ─────────────────────────
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              children: [
                // Header List
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.1))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 12),
                      Text('Riwayat',
                          style: GoogleFonts.outfit(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (formState.isScannerEnabled)
                        const _ScannerStatusBadge(),
                    ],
                  ),
                ),
                // Expanded List
                Expanded(
                  child: historyDocs.isEmpty
                      ? Center(
                          child: Text('Belum ada dokumen',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textLight, fontSize: 13)),
                        )
                      : ListView.separated(
                          itemCount: historyDocs.length,
                          separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.1)),
                          itemBuilder: (context, index) {
                            final doc = historyDocs[index];
                            final isDelivery =
                                doc.mutation == MutationCode.outbound;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              leading: Icon(
                                isDelivery
                                    ? Icons.local_shipping
                                    : Icons.description_outlined,
                                color: AppTheme.textLight,
                                size: 18,
                              ),
                              title: Text(
                                doc.customerId,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, fontSize: 12.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                doc.sysDocNumber,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.w500),
                              ),
                              onTap: () {},
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ── 2. Center Panel (Document Header) ─────────────────────
          const Expanded(
            flex: 3,
            child: TransactionFormView(),
          ),

          // ── 3. Right Panel (Items Summary) ────────────────────────
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: const TransactionSidePanel(),
          ),
        ],
      ),
    );
  }
}

class TransactionSidePanel extends ConsumerWidget {
  const TransactionSidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Side Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: AppTheme.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Item Summary',
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => notifier.toggleScanner(),
                      icon: Icon(
                        formState.isScannerEnabled ? Icons.stop_circle : Icons.qr_code_scanner, 
                        size: 16
                      ),
                      label: Text(
                        formState.isScannerEnabled ? 'Stop Scan' : 'Begin Scan', 
                        style: const TextStyle(fontSize: 12)
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: formState.isScannerEnabled ? AppTheme.error : AppTheme.primaryBlue
                        ),
                        foregroundColor: formState.isScannerEnabled ? AppTheme.error : AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => notifier.addLine(),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add SKU', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Items List
        Expanded(
          child: formState.lines.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: formState.lines.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final line = formState.lines[index];
                    return _SummaryItemCard(
                      line: line,
                      index: index,
                      onDelete: () => notifier.removeLine(index),
                    );
                  },
                ),
        ),

        // Final Actions
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Tabung:',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppTheme.textLight)),
                  Text(
                    '${formState.lines.fold(0, (sum, l) => sum + l.serialNumbers.length)} Items',
                    style: GoogleFonts.outfit(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: formState.isSaving
                    ? null
                    : () => notifier.saveTransaction(actionStatus: DocStatus.completed),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF164E63),
                ),
                child: Text(
                  formState.isSaving ? 'Processing...' : 'Post & Lock Transaction',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 48, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('Belum ada item ditambahkan',
              style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SummaryItemCard extends StatelessWidget {
  final TransactionLineState line;
  final int index;
  final VoidCallback onDelete;

  const _SummaryItemCard({
    required this.line,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.selectedSku?.name ?? '(No SKU Selected)',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${line.serialNumbers.length} SNs • ${line.selectedSku?.itemCode ?? '-'}',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppTheme.textLight),
                ),
                if (line.adminNote.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Note: ${line.adminNote}',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryBlue),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

final scannerServiceProvider = Provider.family<ScannerService, Function(String)>((ref, onScan) {
  final service = ScannerService(
    onScan: onScan,
    isEnabled: () => ref.read(transactionFormProvider).isScannerEnabled,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

class _ScannerStatusBadge extends StatelessWidget {
  const _ScannerStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'SCANNING',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00C853),
            ),
          ),
        ],
      ),
    );
  }
}
