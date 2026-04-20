import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:akg_inventory_master/core/app_colors.dart';
import 'package:akg_inventory_master/shared/widgets/ak_badge.dart';
import 'package:akg_inventory_master/shared/widgets/ak_section_header.dart';
import 'customer_provider.dart';
import 'customer_form_view.dart';
import 'widgets/customer_detail_panel.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CustomerPageLayout — AppSheet 3-pane layout
/// Phase 3 — Grand Refactor
/// [Left 480px: Customer Master List] | [Right: Detail Panel] + [Overlay: Form]
/// ─────────────────────────────────────────────────────────────────────────────
class CustomerPageLayout extends ConsumerWidget {
  const CustomerPageLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCustomerProvider);
    final overlay = ref.watch(customerOverlayProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Stack(
        children: [
          // ── Bottom Layer: Split Pane ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT: Master List ─────────────────────────────────────────
              Container(
                width: 480,
                decoration: const BoxDecoration(
                  color: AppColors.panelBg,
                  border: Border(
                    right: BorderSide(color: AppColors.borderColor, width: 1),
                  ),
                ),
                child: const _CustomerMasterList(),
              ),

              // ── RIGHT: Detail Panel ────────────────────────────────────────
              Expanded(
                child: selected == null
                    ? const _EmptyCustomerPlaceholder()
                    : CustomerDetailPanel(
                        customer: selected,
                        onClose: () => ref
                            .read(selectedCustomerProvider.notifier)
                            .select(null),
                      ),
              ),
            ],
          ),

          // ── Top Layer: Right Overlay Form ──────────────────────────────────
          if (overlay.isOpen)
            _CustomerFormOverlay(
              isVisible: overlay.isOpen,
              onClose: () =>
                  ref.read(customerOverlayProvider.notifier).close(),
            ),
        ],
      ),
    );
  }
}

// ── Overlay Component ────────────────────────────────────────────────────────
class _CustomerFormOverlay extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const _CustomerFormOverlay({
    required this.isVisible,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        // Sliding Panel
        Align(
          alignment: Alignment.centerRight,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(600 * value, 0),
                child: child,
              );
            },
            child: Container(
              width: 600,
              decoration: const BoxDecoration(
                color: AppColors.panelBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(-5, 0),
                  ),
                ],
                border: Border(
                  left: BorderSide(color: AppColors.borderColor, width: 1),
                ),
              ),
              child: CustomerFormView(onClose: onClose),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Master List ───────────────────────────────────────────────────────────────
class _CustomerMasterList extends ConsumerStatefulWidget {
  const _CustomerMasterList();

  @override
  ConsumerState<_CustomerMasterList> createState() =>
      _CustomerMasterListState();
}

class _CustomerMasterListState extends ConsumerState<_CustomerMasterList> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(customerListProvider);
    final selected = ref.watch(selectedCustomerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Panel Header ─────────────────────────────────────────────
        AkPanelHeader(
          title: 'Customers',
          trailing: [
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
                  ref.read(customerListProvider.notifier).refresh(),
            ),
            AkIconButton(
              icon: Icons.person_add_rounded,
              tooltip: 'Customer Baru',
              color: AppColors.googleBlue,
              onTap: () =>
                  ref.read(customerOverlayProvider.notifier).openAdd(),
            ),
          ],
        ),

        // ── Search Box ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderColor, width: 1),
            ),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(fontSize: 13),
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Cari nama, kode, atau alamat...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textDisabled,
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 18, color: AppColors.textDisabled),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          size: 16, color: AppColors.textDisabled),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.pageBg,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    const BorderSide(color: AppColors.googleBlue, width: 1.5),
              ),
            ),
          ),
        ),

        // ── List ─────────────────────────────────────────────────────
        Expanded(
          child: allAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style: GoogleFonts.inter(color: AppColors.errorRed)),
            ),
            data: (all) {
              final q = _searchQuery.toLowerCase();
              final filtered = q.isEmpty
                  ? all
                  : all
                      .where((c) =>
                          c.name.toLowerCase().contains(q) ||
                          c.customerCode.toLowerCase().contains(q) ||
                          c.address.toLowerCase().contains(q))
                      .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded,
                          size: 36, color: AppColors.textDisabled),
                      const SizedBox(height: 10),
                      Text(
                        q.isEmpty
                            ? 'Belum ada customer'
                            : 'Tidak ada hasil "$_searchQuery"',
                        style: GoogleFonts.inter(
                          color: AppColors.textDisabled,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final cust = filtered[i];
                  final isSelected = selected?.id == cust.id;
                  return _CustomerListItem(
                    name: cust.name,
                    code: cust.customerCode,
                    isPpn: cust.isPpnEnabled,
                    termDays: cust.termDays,
                    address: cust.address,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(selectedCustomerProvider.notifier)
                        .select(cust),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Single Customer Row ───────────────────────────────────────────────────────
class _CustomerListItem extends StatefulWidget {
  final String name;
  final String code;
  final bool isPpn;
  final int termDays;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomerListItem({
    required this.name,
    required this.code,
    required this.isPpn,
    required this.termDays,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CustomerListItem> createState() => _CustomerListItemState();
}

class _CustomerListItemState extends State<_CustomerListItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.dividerColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.googleBlue
                      : AppColors.filterBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.name.isNotEmpty
                      ? widget.name[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.inter(
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.code,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (widget.address.isNotEmpty) ...[
                          Text(
                            ' · ',
                            style: GoogleFonts.inter(
                              color: AppColors.textDisabled,
                              fontSize: 11,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.address,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textDisabled,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right side: PPN badge + termin
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.isPpn) AkBadge.tag('PPN'),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.termDays}h',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textDisabled,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyCustomerPlaceholder extends StatelessWidget {
  const _EmptyCustomerPlaceholder();

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
              child: const Icon(Icons.people_alt_outlined,
                  size: 48, color: AppColors.textDisabled),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih atau buat customer baru',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih dari daftar kiri atau tekan ikon\n+ untuk menambah customer baru',
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
