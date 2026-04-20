import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AkDataTable — High-density table component sesuai Figma design
/// Phase 0 — Grand Refactor
///
/// Usage:
///   AkDataTable(
///     columns: [
///       AkTableColumn(label: 'ITEM ID', flex: 2),
///       AkTableColumn(label: 'QTY', flex: 1, align: TextAlign.center),
///       AkTableColumn(label: 'SERIES', flex: 2),
///       AkTableColumn(label: 'REASON', flex: 1),
///     ],
///     rows: [
///       AkTableRow(cells: [
///         AkTableCell.text('Nitrogen 6m3'),
///         AkTableCell.text('4'),
///         AkTableCell.text('14001, 14002'),
///         AkTableCell.badge(AkBadge.reason('EMPTY')),
///       ]),
///     ],
///   )
/// ─────────────────────────────────────────────────────────────────────────────

// ── Column Definition ──────────────────────────────────────────────────────────
class AkTableColumn {
  final String label;
  final int flex;
  final TextAlign align;
  final double? minWidth;

  const AkTableColumn({
    required this.label,
    this.flex = 1,
    this.align = TextAlign.left,
    this.minWidth,
  });
}

// ── Cell Variants ─────────────────────────────────────────────────────────────
enum AkTableCellType { text, badge, icon, custom }

class AkTableCell {
  final AkTableCellType type;
  final String? text;
  final Widget? widget;
  final TextAlign align;
  final Color? textColor;
  final FontWeight? fontWeight;
  final bool isCode; // monospace code style

  const AkTableCell._({
    required this.type,
    this.text,
    this.widget,
    this.align = TextAlign.left,
    this.textColor,
    this.fontWeight,
    this.isCode = false,
  });

  factory AkTableCell.text(
    String value, {
    TextAlign align = TextAlign.left,
    Color? color,
    FontWeight? weight,
    bool isCode = false,
  }) {
    return AkTableCell._(
      type: AkTableCellType.text,
      text: value,
      align: align,
      textColor: color,
      fontWeight: weight,
      isCode: isCode,
    );
  }

  factory AkTableCell.badge(Widget badgeWidget) {
    return AkTableCell._(
      type: AkTableCellType.badge,
      widget: badgeWidget,
    );
  }

  factory AkTableCell.custom(Widget child) {
    return AkTableCell._(
      type: AkTableCellType.custom,
      widget: child,
    );
  }
}

// ── Row Definition ────────────────────────────────────────────────────────────
class AkTableRow {
  final List<AkTableCell> cells;
  final VoidCallback? onTap;
  final bool isSelected;

  const AkTableRow({
    required this.cells,
    this.onTap,
    this.isSelected = false,
  });
}

// ── Main Widget ───────────────────────────────────────────────────────────────
class AkDataTable extends StatelessWidget {
  final List<AkTableColumn> columns;
  final List<AkTableRow> rows;
  final bool showHeader;
  final double rowHeight;
  final String? emptyMessage;
  final bool shrinkWrap;

  const AkDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showHeader = true,
    this.rowHeight = 46,
    this.emptyMessage,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) _buildHeader(),
        const Divider(
          height: 1,
          color: AppColors.borderColor,
        ),
        if (shrinkWrap)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.map(_buildRow).toList(),
          )
        else
          ListView.builder(
            itemCount: rows.length,
            itemBuilder: (_, i) => _buildRow(rows[i]),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.pageBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: columns.map((col) {
          return Expanded(
            flex: col.flex,
            child: Text(
              col.label,
              textAlign: col.align,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(AkTableRow row) {
    return _HoverableRow(
      onTap: row.onTap,
      isSelected: row.isSelected,
      child: Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.dividerColor, width: 1),
          ),
        ),
        child: Row(
          children: List.generate(columns.length, (i) {
            final col = columns[i];
            final cell = i < row.cells.length
                ? row.cells[i]
                : AkTableCell.text('—');

            return Expanded(
              flex: col.flex,
              child: _buildCell(cell, col.align),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCell(AkTableCell cell, TextAlign defaultAlign) {
    switch (cell.type) {
      case AkTableCellType.badge:
      case AkTableCellType.custom:
        return Align(
          alignment: _toAlignment(defaultAlign),
          child: cell.widget ?? const SizedBox.shrink(),
        );
      case AkTableCellType.text:
        return Text(
          cell.text ?? '—',
          textAlign: cell.align != TextAlign.left ? cell.align : defaultAlign,
          overflow: TextOverflow.ellipsis,
          style: cell.isCode
              ? TextStyle(
                  fontFamily: 'monospace',
                  color: cell.textColor ?? AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: cell.fontWeight ?? FontWeight.w400,
                )
              : GoogleFonts.inter(
                  color: cell.textColor ?? AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: cell.fontWeight ?? FontWeight.w400,
                ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Alignment _toAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.table_rows_outlined,
              size: 32, color: AppColors.textDisabled),
          const SizedBox(height: 8),
          Text(
            emptyMessage ?? 'Tidak ada data',
            style: GoogleFonts.inter(
              color: AppColors.textDisabled,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hoverable row wrapper ─────────────────────────────────────────────────────
class _HoverableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;

  const _HoverableRow({
    required this.child,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.isSelected) {
      bg = AppColors.selectedBg;
    } else if (_hovering && widget.onTap != null) {
      bg = AppColors.dividerColor;
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: bg,
          child: widget.child,
        ),
      ),
    );
  }
}
