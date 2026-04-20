import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/ak_badge.dart';
import '../../../../shared/widgets/ak_detail_field.dart';
import '../../../../shared/widgets/ak_data_table.dart';
import '../../../../shared/widgets/ak_section_header.dart';
import '../customer_provider.dart';
import '../../domain/customer.dart';

class CustomerDetailPanel extends ConsumerWidget {
  final Customer customer;
  final VoidCallback? onClose;

  const CustomerDetailPanel({
    super.key,
    required this.customer,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.panelBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Detail Header ──────────────────────────────────────────────
          _DetailHeader(
            customer: customer,
            onClose: onClose,
            onEdit: () => ref
                .read(customerOverlayProvider.notifier)
                .openEdit(customer),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Customer Info Grid ───────────────────────────────────
                  _buildCustomerInfoGrid(customer),
                  const SizedBox(height: 32),

                  // ── Related Sections ──────────────────────────────────────
                  _buildPricelistSection(context, ref, customer.id),
                  const SizedBox(height: 32),

                  _buildAssetsSection(context, ref, customer.id),
                  const SizedBox(height: 32),

                  _buildTransactionsSection(context, ref, customer.id),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoGrid(Customer customer) {
    return AkDetailGrid(
      children: [
        AkDetailField(
          label: 'CUSTOMER CODE',
          value: customer.customerCode,
          isCode: true,
        ),
        AkDetailField(
          label: 'STATUS',
          badgeChild: customer.isActive
              ? AkBadge.custom(
                  label: 'AKTIF',
                  textColor: AppColors.successGreen,
                  bgColor: AppColors.successBg,
                )
              : AkBadge.custom(
                  label: 'NONAKTIF',
                  textColor: AppColors.errorRed,
                  bgColor: AppColors.errorBg,
                ),
        ),
        AkDetailField(
          label: 'NAMA CUSTOMER',
          value: customer.name,
        ),
        AkDetailField(
          label: 'NO. TELEPON',
          value: customer.phone ?? '—',
        ),
        AkDetailField(
          label: 'NPWP',
          value: customer.npwp ?? '—',
        ),
        AkDetailField(
          label: 'TERMIN (HARI)',
          value: '${customer.termDays} Hari',
        ),
        AkDetailField(
          label: 'PAJAK (PPN)',
          value: customer.isPpnEnabled ? 'INCLUDE PPN (TAX)' : 'EXCLUDE PPN',
        ),
        AkDetailField(
          label: 'ALAMAT LENGKAP',
          value: customer.address.isEmpty ? '—' : customer.address,
          fullWidth: true,
        ),
      ],
    );
  }

  // ── Related Sections Builders ──────────────────────────────────────────────

  Widget _buildPricelistSection(
      BuildContext context, WidgetRef ref, String customerId) {
    final pricelistAsync = ref.watch(customerPricelistProvider(customerId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AkSectionHeader(
          title: 'HARGA KHUSUS',
          count: pricelistAsync.value?.length,
          padding: EdgeInsets.zero,
          actions: [
            AkSectionAction(
              label: 'KELOLA HARGA',
              onTap: () {}, // Future feature
            ),
          ],
        ),
        const SizedBox(height: 12),
        pricelistAsync.when(
          loading: () => const Center(child: LinearProgressIndicator()),
          error: (e, _) => Text('Error loading pricelist: $e'),
          data: (pricelists) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: AkDataTable(
              columns: const [
                AkTableColumn(label: 'ITEM', flex: 4),
                AkTableColumn(label: 'HARGA KHUSUS', flex: 3, align: TextAlign.right),
                AkTableColumn(label: 'DSR / SELISIH', flex: 3, align: TextAlign.right),
              ],
              rows: pricelists.map((pl) {
                final delta = pl.deltaPercent;
                final deltaColor =
                    delta >= 0 ? AppColors.successGreen : AppColors.errorRed;

                return AkTableRow(cells: [
                  AkTableCell.text(pl.itemName, weight: FontWeight.w600),
                  AkTableCell.text(
                    _formatCurrency(pl.customPrice),
                    align: TextAlign.right,
                    color: AppColors.googleBlue,
                    weight: FontWeight.w700,
                  ),
                  AkTableCell.text(
                    '${_formatCurrency(pl.basePrice.toDouble())} (${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}%)',
                    align: TextAlign.right,
                    color: deltaColor,
                  ),
                ]);
              }).toList(),
              emptyMessage: 'Belum ada harga khusus untuk customer ini.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsSection(
      BuildContext context, WidgetRef ref, String customerId) {
    final assetsAsync = ref.watch(customerAssetsProvider(customerId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AkSectionHeader(
          title: 'ASET DI CUSTOMER',
          count: assetsAsync.value?.length,
          padding: EdgeInsets.zero,
          actions: [
            AkSectionAction(
              label: 'DETAIL ASET',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        assetsAsync.when(
          loading: () => const Center(child: LinearProgressIndicator()),
          error: (e, _) => Text('Error loading assets: $e'),
          data: (assets) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: AkDataTable(
              columns: const [
                AkTableColumn(label: 'NO. SERI / BARCODE', flex: 5),
                AkTableColumn(label: 'ITEM', flex: 3),
                AkTableColumn(label: 'STATUS', flex: 2, align: TextAlign.center),
              ],
              rows: assets.map((a) {
                return AkTableRow(cells: [
                  AkTableCell.text(
                    '${a['serial_number'] ?? '—'} / ${a['barcode'] ?? '—'}',
                    isCode: true,
                  ),
                  AkTableCell.text(a['item_name']?.toString() ?? '—'),
                  AkTableCell.text(
                    a['status']?.toString().split('_').last ?? '—',
                    align: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
                ]);
              }).toList(),
              emptyMessage: 'Tidak ada aset yang sedang disewa customer ini.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(
      BuildContext context, WidgetRef ref, String customerId) {
    final txnAsync = ref.watch(customerTransactionsProvider(customerId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AkSectionHeader(
          title: 'RIWAYAT TRANSAKSI',
          count: txnAsync.value?.length,
          padding: EdgeInsets.zero,
          actions: [
            AkSectionAction(
              label: 'LIHAT SEMUA',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        txnAsync.when(
          loading: () => const Center(child: LinearProgressIndicator()),
          error: (e, _) => Text('Error loading transactions: $e'),
          data: (txns) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: AkDataTable(
              columns: const [
                AkTableColumn(label: 'DOC NUMBER', flex: 4),
                AkTableColumn(label: 'TIPE', flex: 2),
                AkTableColumn(label: 'TANGGAL', flex: 3),
                AkTableColumn(label: 'STATUS', flex: 2, align: TextAlign.right),
              ],
              rows: txns.map((tx) {
                final dateStr = tx['transaction_date'] != null
                    ? DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(tx['transaction_date']))
                    : '—';
                return AkTableRow(cells: [
                  AkTableCell.text(tx['sys_doc_number']?.toString() ?? '—',
                      isCode: true),
                  AkTableCell.text(tx['mutation']?.toString() ?? '—',
                      color: AppColors.textSecondary),
                  AkTableCell.text(dateStr),
                  AkTableCell.text(tx['status']?.toString() ?? '—',
                      align: TextAlign.right),
                ]);
              }).toList(),
              emptyMessage: 'Belum ada riwayat transaksi.',
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}

class _DetailHeader extends ConsumerWidget {
  final Customer customer;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;

  const _DetailHeader({
    required this.customer,
    this.onClose,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(customerListProvider);

    return AkPanelHeader(
      title: customer.name,
      titleWidget: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.filterBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customer.name,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  customer.customerCode,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: [
        // ── Edit Button ──────────────────────────────────────────────
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded, size: 14),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.googleBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minimumSize: const Size(0, 32),
            elevation: 0,
            textStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),

        const SizedBox(width: 12),

        // ── Navigation ────────────────────────────────────────────────
        AkIconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Sebelumnya',
          onTap: () {
            if (listAsync.hasValue) {
              final list = listAsync.value!;
              final idx = list.indexWhere((c) => c.id == customer.id);
              if (idx > 0) {
                ref.read(selectedCustomerProvider.notifier).select(list[idx - 1]);
              }
            }
          },
        ),
        AkIconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Berikutnya',
          onTap: () {
            if (listAsync.hasValue) {
              final list = listAsync.value!;
              final idx = list.indexWhere((c) => c.id == customer.id);
              if (idx != -1 && idx < list.length - 1) {
                ref.read(selectedCustomerProvider.notifier).select(list[idx + 1]);
              }
            }
          },
        ),

        const SizedBox(width: 4),

        // ── Close ────────────────────────────────────────────────────
        AkIconButton(
          icon: Icons.close_rounded,
          tooltip: 'Tutup',
          onTap: onClose,
        ),
      ],
    );
  }
}
