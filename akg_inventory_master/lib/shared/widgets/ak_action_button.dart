import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AkActionButton — Vertical icon+label button sesuai Figma action row
/// Phase 0 — Grand Refactor
///
/// Sesuai Figma: icon box biru (44x44, radius 12) + label semibold di bawah
///
/// Usage:
///   AkActionButton(
///     icon: Icons.qr_code_scanner,
///     label: 'BEGIN SCAN',
///     onTap: () {},
///   )
///   AkActionButton(
///     icon: Icons.receipt_long,
///     label: 'CREATE INVOICE',
///     onTap: () {},
///     color: AppColors.successGreen,
///   )
///   AkActionButton.destructive(
///     icon: Icons.block,
///     label: 'VOID',
///     onTap: () {},
///   )
/// ─────────────────────────────────────────────────────────────────────────────
class AkActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBg;
  final bool isDestructive;
  final bool isDisabled;

  const AkActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor = Colors.white,
    this.iconBg = AppColors.googleBlue,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  factory AkActionButton.destructive({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return AkActionButton(
      icon: icon,
      label: label,
      onTap: onTap,
      iconColor: Colors.white,
      iconBg: AppColors.errorRed,
      isDestructive: true,
    );
  }

  factory AkActionButton.success({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return AkActionButton(
      icon: icon,
      label: label,
      onTap: onTap,
      iconColor: Colors.white,
      iconBg: AppColors.successGreen,
    );
  }

  factory AkActionButton.outlined({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return AkActionButton(
      icon: icon,
      label: label,
      onTap: onTap,
      iconColor: AppColors.googleBlue,
      iconBg: AppColors.selectedBg,
    );
  }

  @override
  State<AkActionButton> createState() => _AkActionButtonState();
}

class _AkActionButtonState extends State<AkActionButton> {
  bool _hovering = false;
  bool _pressing = false;

  bool get _canTap => widget.onTap != null && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.isDisabled
        ? AppColors.filterBg
        : _pressing
            ? widget.iconBg.withValues(alpha: 0.75)
            : _hovering
                ? widget.iconBg.withValues(alpha: 0.85)
                : widget.iconBg;

    final effectiveIconColor =
        widget.isDisabled ? AppColors.textDisabled : widget.iconColor;

    final effectiveLabelColor =
        widget.isDisabled ? AppColors.textDisabled : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() {
        _hovering = false;
        _pressing = false;
      }),
      cursor:
          _canTap ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) => setState(() => _pressing = false),
        onTapCancel: () => setState(() => _pressing = false),
        onTap: _canTap ? widget.onTap : null,
        child: AnimatedScale(
          scale: _pressing ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon Box ─────────────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: (!widget.isDisabled && _hovering)
                      ? [
                          BoxShadow(
                            color: widget.iconBg.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: effectiveIconColor,
                ),
              ),
              const SizedBox(height: 6),

              // ── Label ─────────────────────────────────────────────────────
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: effectiveLabelColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── AkActionButtonRow ───────────────────────────────────────────────────────
/// Row wrapper untuk action buttons dengan spacing sesuai Figma
class AkActionButtonRow extends StatelessWidget {
  final List<AkActionButton> buttons;

  const AkActionButtonRow({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: buttons
            .expand((b) => [b, const SizedBox(width: 20)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}
