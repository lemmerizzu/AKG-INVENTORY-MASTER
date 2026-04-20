import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_history_provider.dart';
import 'package:akg_inventory_master/features/transaction/data/transaction_repository.dart';
import 'package:akg_inventory_master/features/transaction/domain/transaction_document.dart';
import 'package:akg_inventory_master/features/customer/presentation/customer_provider.dart';
import 'package:akg_inventory_master/features/customer/domain/customer.dart';
import 'package:akg_inventory_master/core/theme.dart';
import 'package:akg_inventory_master/features/transaction/presentation/transaction_form_provider.dart';

class TransactionDetailView extends ConsumerWidget {
  final String documentId;

  const TransactionDetailView({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(transactionDetailProvider(documentId));
    final history = ref.watch(transactionHistoryProvider).value ?? [];
    
    final doc = history.firstWhere((d) => d.id == documentId);
    final customers = ref.watch(customerListProvider).value ?? [];
    final customer = customers.firstWhere((c) => c.id == doc.customerId, orElse: () => const Customer(id: '', customerCode: '?', name: 'Unknown', address: ''));

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (detail) {
        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Toolbar ───────────────────────────────────────────
              _buildToolbar(context, ref, doc, detail, customer),

              // ── Content ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeaderSection(doc, customer),
                      const SizedBox(height: 32),
                      
                      // Tabs or Sections
                      DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelColor: AppTheme.primaryBlue,
                              unselectedLabelColor: AppTheme.textLight,
                              indicatorColor: AppTheme.primaryBlue,
                              dividerColor: Colors.transparent,
                              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                              tabs: const [
                                Tab(text: 'Items List'),
                                Tab(text: 'Audit History'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 600, // Fixed height for tab content
                              child: TabBarView(
                                children: [
                                  _buildItemsList(detail.items),
                                  _buildAuditLogs(detail.auditLogs),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, TransactionDocument doc, TransactionDetailState detail, Customer customer) {
    final isVoid = doc.status == DocStatus.void_;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Text(doc.sysDocNumber, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const Spacer(),
          if (!isVoid) ...[
            _ActionButton(
              icon: Icons.print_outlined,
              label: 'Print SJ',
              onPressed: () {
                // TODO: Integrate with existing print module
              },
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.receipt_outlined,
              label: 'Invoice',
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            if (doc.status == DocStatus.draft)
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onPressed: () {
                  ref.read(transactionFormProvider(doc.id).notifier).loadFromDocument(doc, detail.items, customer);
                  // Optional: if there's a navigation provider, use it here.
                  // For now, loading the state is the priority.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document loaded into Input Form for editing.'))
                  );
                },
              ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.block,
              label: 'Void',
              isDanger: true,
              onPressed: () => _showVoidDialog(context, ref, doc),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('VOIDED', style: GoogleFonts.inter(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(TransactionDocument doc, Customer customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CUSTOMER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(customer.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                Text(customer.address, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('DATE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, MMM dd yyyy').format(doc.transactionDate), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(DateFormat('hh:mm a').format(doc.transactionDate), style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(16)),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _InfoTile(label: 'MUTATION', value: doc.mutation.name.toUpperCase()),
                const VerticalDivider(width: 40),
                _InfoTile(label: 'REFERENCE', value: doc.poReference ?? '-'),
                const VerticalDivider(width: 40),
                _InfoTile(label: 'MODE', value: doc.inputMode.name.toUpperCase()),
                const VerticalDivider(width: 40),
                _InfoTile(label: 'STATUS', value: doc.status.name.toUpperCase()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<InventoryLedgerEntry> items) {
    if (items.isEmpty) return const Center(child: Text('No items in this transaction.'));
    
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(4),
            2: FixedColumnWidth(80),
          },
          children: [
            TableRow(
              children: [
                _TableCell(Text('ITEM SKU', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12))),
                _TableCell(Text('SERIAL NUMBERS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12))),
                _TableCell(Text('QTY', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)), isRight: true),
              ],
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final sns = item.cylinderBarcode?.split(',') ?? [];
              
              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(4),
                  2: FixedColumnWidth(80),
                },
                children: [
                  TableRow(
                    children: [
                      _TableCell(Text(item.itemId ?? '-', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600))),
                      _TableCell(
                        sns.isEmpty 
                          ? Text('-', style: TextStyle(color: Colors.grey.withValues(alpha: 0.5)))
                          : Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: sns.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
                                child: Text(s, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                              )).toList(),
                            )
                      ),
                      _TableCell(Text(item.qty.toString(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)), isRight: true),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogs(List<dynamic> logs) {
    if (logs.isEmpty) return const Center(child: Text('No history found.'));
    
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getLogIcon(log.action),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(log.action, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(DateFormat('MMM dd, HH:mm').format(log.createdAt), style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
                      ],
                    ),
                    if (log.note != null) ...[
                      const SizedBox(height: 4),
                      Text(log.note!, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getLogIcon(String action) {
    IconData icon;
    Color color;
    switch (action) {
      case 'CREATE':
        icon = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case 'EDIT':
        icon = Icons.edit_note;
        color = Colors.orange;
        break;
      case 'VOID':
        icon = Icons.block;
        color = AppTheme.error;
        break;
      case 'PRINT':
        icon = Icons.print_outlined;
        color = AppTheme.primaryBlue;
        break;
      default:
        icon = Icons.history;
        color = Colors.grey;
    }
    return Icon(icon, color: color, size: 20);
  }

  void _showVoidDialog(BuildContext context, WidgetRef ref, TransactionDocument doc) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Void Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to void this transaction? This action is irreversible.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Reason for voiding', hintText: 'e.g., Wrong quantity...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(transactionRepositoryProvider).voidTransaction(doc.id, controller.text);
              if (context.mounted) Navigator.pop(context);
              ref.read(transactionHistoryProvider.notifier).refresh();
            },
            child: const Text('Void Document'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDanger;

  const _ActionButton({required this.icon, required this.label, required this.onPressed, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: isDanger ? AppTheme.error : AppTheme.primaryBlue),
      label: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDanger ? AppTheme.error : AppTheme.primaryBlue)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: (isDanger ? AppTheme.error : AppTheme.primaryBlue).withValues(alpha: 0.05),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;
  final bool isRight;
  const _TableCell(this.child, {this.isRight = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Align(alignment: isRight ? Alignment.centerRight : Alignment.centerLeft, child: child),
    );
  }
}
