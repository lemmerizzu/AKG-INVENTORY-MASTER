import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AkDetailField — Label + Value field untuk detail panel grid
/// Phase 0 — Grand Refactor
///
/// Sesuai Figma `Detail Grid`: label uppercase kecil di atas, value di bawah.
///
/// Usage:
///   AkDetailField(label: 'DOC NUMBER', value: '1261547', isCode: true)
///   AkDetailField(label: 'CUSTOMER NAME', value: 'Flashtech Machinery')
///   AkDetailField(label: 'MUTATION', badgeChild: AkBadge.mutation('IN'))
///   AkDetailField(label: 'SHIPPING ADDRESS', value: 'Jl. ...', fullWidth: true)
/// ─────────────────────────────────────────────────────────────────────────────
class AkDetailField extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? badgeChild; // jika value adalah badge/custom widget
  final bool isCode;        // monospace + border overlay (untuk DOC NUMBER)
  final bool fullWidth;     // span 2 kolom
  final bool isEditable;    // tampilkan edit underline
  final VoidCallback? onEditTap;

  const AkDetailField({
    super.key,
    required this.label,
    this.value,
    this.badgeChild,
    this.isCode = false,
    this.fullWidth = false,
    this.isEditable = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ────────────────────────────────────────────────────────────
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),

          // ── Value ─────────────────────────────────────────────────────────
          if (badgeChild != null)
            badgeChild!
          else if (isCode)
            _buildCodeValue()
          else
            _buildTextValue(),
        ],
      ),
    );
  }

  Widget _buildTextValue() {
    final display = (value == null || value!.isEmpty) ? '—' : value!;
    return GestureDetector(
      onTap: isEditable ? onEditTap : null,
      child: Text(
        display,
        style: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          decoration: isEditable ? TextDecoration.underline : null,
          decorationColor: AppColors.googleBlue,
          decorationStyle: TextDecorationStyle.dashed,
        ),
      ),
    );
  }

  Widget _buildCodeValue() {
    // Style khusus untuk DOC NUMBER: box dengan border tipis
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tag_rounded, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            value ?? '—',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── AkDetailGrid ───────────────────────────────────────────────────────────
/// Grid wrapper: membungkus field-field dalam 2-kolom layout sesuai Figma
///
/// Usage:
///   AkDetailGrid(
///     children: [
///       AkDetailField(label: 'DOC NUMBER', value: doc.sysDocNumber, isCode: true),
///       AkDetailField(label: 'DATETIME', value: formatted),
///       AkDetailField(label: 'CUSTOMER NAME', value: customer.name),
///       AkDetailField(label: 'MUTATION', badgeChild: AkBadge.mutation('IN')),
///       AkDetailField(label: 'SHIPPING ADDRESS', value: doc.shippingAddress, fullWidth: true),
///     ],
///   )
class AkDetailGrid extends StatelessWidget {
  final List<AkDetailField> children;
  final int columns;

  const AkDetailGrid({
    super.key,
    required this.children,
    this.columns = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Split children into rows, respecting fullWidth
    final List<Widget> rows = [];
    int i = 0;
    while (i < children.length) {
      final field = children[i];
      if (field.fullWidth) {
        rows.add(field);
        i++;
      } else {
        // Try to pair with next
        if (i + 1 < children.length && !children[i + 1].fullWidth) {
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 24),
              Expanded(child: children[i + 1]),
            ],
          ));
          i += 2;
        } else {
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              const Expanded(child: SizedBox()),
            ],
          ));
          i++;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}
