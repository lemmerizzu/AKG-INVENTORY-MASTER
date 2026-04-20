import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AkSectionHeader — Section header dengan title, count badge, dan action buttons
/// Phase 0 — Grand Refactor
///
/// Sesuai Figma: header untuk "ITEM LIST", "REV HISTORY" sections.
///
/// Usage:
///   AkSectionHeader(
///     title: 'ITEM LIST',
///     count: 2,
///     actions: [
///       AkSectionAction(label: 'EXPAND', icon: Icons.open_in_full, onTap: () {}),
///       AkSectionAction(label: 'ADD ITEM', icon: Icons.add, onTap: () {}),
///     ],
///   )
/// ─────────────────────────────────────────────────────────────────────────────

class AkSectionAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const AkSectionAction({
    required this.label,
    this.icon,
    this.onTap,
    this.isDestructive = false,
  });
}

class AkSectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final List<AkSectionAction> actions;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const AkSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.actions = const [],
    this.showDivider = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // ── Title ──────────────────────────────────────────────────────
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),

              // ── Count Badge ───────────────────────────────────────────────
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.filterBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // ── Action Buttons ────────────────────────────────────────────
              ...actions.map((action) => _ActionChip(action: action)),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.borderColor),
      ],
    );
  }
}

class _ActionChip extends StatefulWidget {
  final AkSectionAction action;
  const _ActionChip({required this.action});

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.action.isDestructive
        ? AppColors.errorRed
        : AppColors.googleBlue;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: widget.action.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.action.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _hovering
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _hovering
                    ? color.withValues(alpha: 0.4)
                    : AppColors.borderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.action.icon != null) ...[
                  Icon(widget.action.icon, size: 13, color: color),
                  const SizedBox(width: 5),
                ],
                Text(
                  widget.action.label,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ─── AkPanelHeader ──────────────────────────────────────────────────────────
/// Header untuk keseluruhan panel (left master list / right detail panel)
///
/// Usage:
///   AkPanelHeader(
///     title: 'Transactions',
///     trailing: [
///       IconButton(icon: Icon(Icons.add), onPressed: () {}),
///       IconButton(icon: Icon(Icons.sort), onPressed: () {}),
///     ],
///   )
class AkPanelHeader extends StatelessWidget {
  final String title;
  final Widget? titleWidget; // Added this
  final List<Widget> trailing;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  const AkPanelHeader({
    super.key,
    required this.title,
    this.titleWidget,
    this.trailing = const [],
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(
                child: titleWidget ??
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
              ),
              ...trailing,
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderColor),
      ],
    );
  }
}

/// ─── AkIconButton ────────────────────────────────────────────────────────────
/// Compact icon button AppSheet-style (no ripple wave, just bg color change)
class AkIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? color;
  final double size;

  const AkIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.color,
    this.size = 20,
  });

  @override
  State<AkIconButton> createState() => _AkIconButtonState();
}

class _AkIconButtonState extends State<AkIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final btn = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovering ? AppColors.filterBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color ?? AppColors.textSecondary,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}
