import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// DashboardShell — Phase 1 Grand Refactor
/// Figma: "transaction_view" (node 23:338)
///
/// Layout:
/// ┌──────────────── Top Navigation Bar (62px) ─────────────────────┐
/// │ [Logo+AKG MASTER]   [Search 418px]   [+][🔔][⋮]│[Avatar]      │
/// ├──────┬─────────────────────────────────────────────────────────┤
/// │ 56px │                                                         │
/// │ Icon │              Content Area                               │
/// │ Side │                                                         │
/// └──────┴─────────────────────────────────────────────────────────┘
/// ─────────────────────────────────────────────────────────────────────────────

/// Sidebar navigation item definition
class NavItem {
  final IconData icon;
  final String label;   // Used for tooltip
  final Widget page;

  const NavItem({required this.icon, required this.label, required this.page});
}

/// State: which nav item is selected (Riverpod v3)
class SelectedNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final selectedNavIndexProvider =
    NotifierProvider<SelectedNavNotifier, int>(SelectedNavNotifier.new);

/// AppSheet-style shell with top bar + icon sidebar
class DashboardShell extends ConsumerWidget {
  final List<NavItem> navItems;

  const DashboardShell({super.key, required this.navItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Column(
        children: [
          // ── Top Navigation Bar ────────────────────────────────────
          _TopNavBar(),

          // ── Body: Sidebar + Content ──────────────────────────────
          Expanded(
            child: Row(
              children: [
                // Icon Sidebar (56px)
                _IconSidebar(
                  navItems: navItems,
                  selectedIndex: selectedIndex,
                  onSelect: (i) =>
                      ref.read(selectedNavIndexProvider.notifier).select(i),
                ),

                // Content Area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(selectedIndex),
                      child: navItems[selectedIndex].page,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Navigation Bar ────────────────────────────────────────────────────────
class _TopNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.topBarBg,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // ── Logo ──────────────────────────────────────────────────
          SizedBox(
            width: 199,
            child: Row(
              children: [
                // Water drop icon (AKG brand)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.water_drop_outlined,
                    size: 20,
                    color: AppColors.googleBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AKG MASTER',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Search Bar (418px) ────────────────────────────────────
          Container(
            width: 418,
            height: 36,
            padding: const EdgeInsets.only(left: 40, right: 16),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                // Search icon
                Positioned(
                  left: -29,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                // Placeholder text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Search Transactions',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Right Actions ─────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // + button
              _TopBarIconBtn(
                icon: Icons.add_rounded,
                tooltip: 'Tambah Transaksi',
                filled: true,
                onTap: () {},
              ),
              const SizedBox(width: 10),

              // Notification bell with badge
              Stack(
                children: [
                  _TopBarIconBtn(
                    icon: Icons.notifications_outlined,
                    tooltip: 'Notifikasi',
                    onTap: () {},
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Kebab menu
              _TopBarIconBtn(
                icon: Icons.more_vert_rounded,
                tooltip: 'Menu',
                onTap: () {},
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 1,
                  height: 24,
                  child: const ColoredBox(color: AppColors.borderColor),
                ),
              ),

              // User Avatar
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.googleBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small icon button for the top bar
class _TopBarIconBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool filled;
  final VoidCallback onTap;

  const _TopBarIconBtn({
    required this.icon,
    required this.tooltip,
    this.filled = false,
    required this.onTap,
  });

  @override
  State<_TopBarIconBtn> createState() => _TopBarIconBtnState();
}

class _TopBarIconBtnState extends State<_TopBarIconBtn> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              color: widget.filled
                  ? AppColors.inputBg
                  : _hovering
                      ? AppColors.dividerColor
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Icon Sidebar (56px) ───────────────────────────────────────────────────────
class _IconSidebar extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _IconSidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Hamburger menu at top
          _SidebarIcon(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            isSelected: false,
            onTap: () {},
          ),

          // Nav items
          ...List.generate(navItems.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _SidebarIcon(
                icon: navItems[i].icon,
                tooltip: navItems[i].label,
                isSelected: selectedIndex == i,
                onTap: () => onSelect(i),
              ),
            );
          }),

          const Spacer(),

          // Grid/apps icon at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SidebarIcon(
              icon: Icons.apps_rounded,
              tooltip: 'Apps',
              isSelected: false,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// Single icon in the 56px sidebar
class _SidebarIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarIcon({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarIcon> createState() => _SidebarIconState();
}

class _SidebarIconState extends State<_SidebarIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;

    if (widget.isSelected) {
      bgColor = AppColors.selectedBg;
      iconColor = AppColors.googleBlue;
    } else if (_hovering) {
      bgColor = AppColors.dividerColor;
      iconColor = AppColors.textSecondary;
    } else {
      bgColor = Colors.transparent;
      iconColor = AppColors.textSecondary;
    }

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 20,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
