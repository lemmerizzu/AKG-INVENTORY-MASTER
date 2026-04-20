import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AkFilterChip — Dropdown filter chip sesuai Figma design
/// Phase 0 — Grand Refactor
///
/// Usage:
///   `AkFilterChip<String>`(
///     label: 'Mutation',
///     value: selectedMutation,
///     options: ['Semua', 'IN', 'OUT', 'OTHER'],
///     onChanged: (v) => setState(() => selectedMutation = v),
///   )
/// ─────────────────────────────────────────────────────────────────────────────
class AkFilterChip<T> extends StatefulWidget {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T)? optionLabel;
  final ValueChanged<T> onChanged;
  final bool isActive; // override active state manually

  const AkFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    this.optionLabel,
    required this.onChanged,
    this.isActive = false,
  });

  @override
  State<AkFilterChip<T>> createState() => _AkFilterChipState<T>();
}

class _AkFilterChipState<T> extends State<AkFilterChip<T>> {
  bool _hovering = false;

  String _getLabel(T val) {
    if (widget.optionLabel != null) return widget.optionLabel!(val);
    return val.toString();
  }

  bool get _isActive =>
      widget.isActive ||
      (widget.options.isNotEmpty && widget.value != widget.options.first);

  @override
  Widget build(BuildContext context) {
    final activeColor = _isActive ? AppColors.googleBlue : AppColors.textSecondary;
    final bg = _isActive ? AppColors.selectedBg : AppColors.filterBg;
    final border = _isActive
        ? const BorderSide(color: AppColors.googleBlue, width: 1)
        : BorderSide(color: AppColors.borderColor.withValues(alpha: 0.6), width: 1);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: _showMenu,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovering && !_isActive
                ? AppColors.dividerColor
                : bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.fromBorderSide(border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isActive
                    ? '${widget.label}: ${_getLabel(widget.value)}'
                    : widget.label,
                style: GoogleFonts.inter(
                  color: activeColor,
                  fontSize: 12,
                  fontWeight: _isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.expand_more_rounded,
                size: 16,
                color: activeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu() async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final result = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy + size.height + 4 + 200,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      elevation: 4,
      color: AppColors.panelBg,
      items: widget.options.map((opt) {
        final selected = opt == widget.value;
        return PopupMenuItem<T>(
          value: opt,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getLabel(opt),
                  style: GoogleFonts.inter(
                    color: selected
                        ? AppColors.googleBlue
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded,
                    size: 16, color: AppColors.googleBlue),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null && result != widget.value) {
      widget.onChanged(result);
    }
  }
}

/// ─── Date Range Filter Chip ──────────────────────────────────────────────────
/// Chip khusus untuk filter tanggal (Rentang Tanggal)
class AkDateRangeChip extends StatefulWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;

  const AkDateRangeChip({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AkDateRangeChip> createState() => _AkDateRangeChipState();
}

class _AkDateRangeChipState extends State<AkDateRangeChip> {
  bool _hovering = false;

  bool get _isActive => widget.value != null;

  String get _displayLabel {
    if (widget.value == null) return 'Rentang Tanggal';
    final s = widget.value!.start;
    final e = widget.value!.end;
    return '${s.day}/${s.month} — ${e.day}/${e.month}';
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isActive ? AppColors.googleBlue : AppColors.textSecondary;
    final bg = _isActive ? AppColors.selectedBg : AppColors.filterBg;
    final border = _isActive
        ? const BorderSide(color: AppColors.googleBlue, width: 1)
        : BorderSide(color: AppColors.borderColor.withValues(alpha: 0.6), width: 1);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: _pickDate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovering && !_isActive ? AppColors.dividerColor : bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.fromBorderSide(border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: activeColor),
              const SizedBox(width: 6),
              Text(
                _displayLabel,
                style: GoogleFonts.inter(
                  color: activeColor,
                  fontSize: 12,
                  fontWeight: _isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (_isActive) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => widget.onChanged(null),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: AppColors.googleBlue),
                ),
              ] else ...[
                const SizedBox(width: 6),
                Icon(Icons.expand_more_rounded, size: 16, color: activeColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: widget.value,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.googleBlue),
        ),
        child: child!,
      ),
    );
    widget.onChanged(result);
  }
}
