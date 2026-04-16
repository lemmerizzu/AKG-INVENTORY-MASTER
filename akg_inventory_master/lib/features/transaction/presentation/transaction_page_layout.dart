import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../domain/transaction_document.dart';
import 'transaction_form_view.dart';
import 'transaction_history_provider.dart';

/// Implements a Split-Pane layout mirroring the AppSheet split view.
/// Left Panel: Document History List.
/// Right Panel: Transaction Form Detail.
class TransactionPageLayout extends ConsumerWidget {
  const TransactionPageLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyDocs = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left Panel (History List) ─────────────────────────
          Container(
            width: 320,
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
                      const Icon(Icons.history, color: AppTheme.primaryBlue),
                      const SizedBox(width: 12),
                      Text('Dokumen',
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.w600)),
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
                                size: 20,
                              ),
                              title: Text(
                                doc.customerId, // Should resolve customer name in real app based on ID
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              subtitle: Text(
                                doc.sysDocNumber,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textLight,
                                    fontWeight: FontWeight.w500),
                              ),
                              onTap: () {
                                // Logic to load and edit document (coming soon)
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ── Right Panel (Form Detail) ─────────────────────────
          const Expanded(
            // TransactionFormView handles its own scroll and inner padding
            child: TransactionFormView(),
          ),
        ],
      ),
    );
  }
}
