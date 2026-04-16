import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import 'customer_provider.dart';
import 'customer_form_view.dart';

/// Implements a Split-Pane layout for Customer Management.
/// Left Panel: Customer List.
/// Right Panel: Customer Form Detail.
class CustomerPageLayout extends ConsumerWidget {
  const CustomerPageLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerListProvider);
    final selectedCustomer = ref.watch(selectedCustomerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left Panel (Customer List) ─────────────────────────
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
                      const Icon(Icons.people_alt_outlined,
                          color: AppTheme.primaryBlue),
                      const SizedBox(width: 12),
                      Text('Daftar Customer',
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // Search Box
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari customer...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 13, color: AppTheme.textLight),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppTheme.background,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // Expanded List
                Expanded(
                  child: customers.isEmpty
                      ? Center(
                          child: Text('Belum ada data customer',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textLight, fontSize: 13)),
                        )
                      : ListView.separated(
                          itemCount: customers.length,
                          separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.1)),
                          itemBuilder: (context, index) {
                            final cust = customers[index];
                            final isSelected =
                                selectedCustomer?.id == cust.id;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              selected: isSelected,
                              selectedTileColor:
                                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.grey.withValues(alpha: 0.1),
                                child: Text(
                                  cust.name.characters.first.toUpperCase(),
                                  style: GoogleFonts.inter(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textDark,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                cust.name,
                                style: GoogleFonts.inter(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : AppTheme.textDark),
                              ),
                              subtitle: Text(
                                cust.customerCode,
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppTheme.textLight),
                              ),
                              onTap: () {
                                ref
                                    .read(selectedCustomerProvider.notifier)
                                    .select(cust);
                              },
                            );
                          },
                        ),
                ),
                // Add button at bottom of list
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.1))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(selectedCustomerProvider.notifier)
                            .select(null);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Customer Baru'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right Panel (Form Detail) ─────────────────────────
          const Expanded(
            child: CustomerFormView(),
          ),
        ],
      ),
    );
  }
}
