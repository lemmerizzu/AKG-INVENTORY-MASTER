import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';

/// Sidebar navigation item definition
class NavItem {
  final IconData icon;
  final String label;
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

/// Windows-optimized shell with persistent sidebar + content area
class DashboardShell extends ConsumerWidget {
  final List<NavItem> navItems;

  const DashboardShell({super.key, required this.navItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────
          _Sidebar(
            navItems: navItems,
            selectedIndex: selectedIndex,
            onSelect: (i) =>
                ref.read(selectedNavIndexProvider.notifier).select(i),
          ),

          // ── Divider ──────────────────────────────────────────────
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.grey.withValues(alpha: 0.15),
          ),

          // ── Content Area ─────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(selectedIndex),
                child: navItems[selectedIndex].page,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF0F1123),
      child: Column(
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.inventory_2, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AKG Master',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Nav items
          ...List.generate(navItems.length, (i) {
            final item = navItems[i];
            final isSelected = selectedIndex == i;
            return _NavTile(
              icon: item.icon,
              label: item.label,
              isSelected: isSelected,
              onTap: () => onSelect(i),
            );
          }),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v1.0.0-dev',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSelected
        ? AppTheme.primaryBlue.withValues(alpha: 0.15)
        : _hovering
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.transparent;

    final fgColor = widget.isSelected
        ? AppTheme.secondaryBlue
        : Colors.white.withValues(alpha: 0.6);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: widget.isSelected
                ? Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: fgColor, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 13,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
