import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';

/// Premium styled DataTable inside a card container.
/// Features: alternating row colors, hover effects, styled headers.
class DataTableCard extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showBorder;

  const DataTableCard({
    super.key,
    required this.columns,
    required this.rows,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(color: Colors.grey.withValues(alpha: 0.12))
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.5,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppTheme.primaryBlue.withValues(alpha: 0.04),
              ),
              headingTextStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
              dataTextStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textDark,
              ),
              columnSpacing: 24,
              horizontalMargin: 16,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to create a styled DataColumn with label text.
DataColumn styledColumn(String label, {bool numeric = false}) {
  return DataColumn(
    numeric: numeric,
    label: Text(label),
  );
}

/// Helper to format Rupiah price.
String formatRupiah(int amount) {
  final str = amount.toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    buffer.write(str[i]);
    count++;
    if (count % 3 == 0 && i > 0) buffer.write('.');
  }
  return 'Rp ${buffer.toString().split('').reversed.join()}';
}

/// Status chip for asset/document status.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  factory StatusChip.fromAssetStatus(String status) {
    final map = {
      'AVAILABLE_FULL': ('Tersedia', AppTheme.success),
      'AVAILABLE_EMPTY': ('Kosong', AppTheme.warning),
      'RENTED': ('Disewa', AppTheme.primaryBlue),
      'SOLD': ('Terjual', Colors.purple),
      'LOST': ('Hilang', AppTheme.error),
      'MAINTENANCE': ('Perawatan', AppTheme.warning),
      'RETIRED': ('Pensiun', Colors.grey),
    };
    final entry = map[status] ?? ('Unknown', Colors.grey);
    return StatusChip(label: entry.$1, color: entry.$2);
  }

  factory StatusChip.fromDocStatus(String status) {
    final map = {
      'DRAFT': ('Draft', AppTheme.warning),
      'COMPLETED': ('Selesai', AppTheme.success),
      'VOID': ('Void', AppTheme.error),
    };
    final entry = map[status] ?? ('Unknown', Colors.grey);
    return StatusChip(label: entry.$1, color: entry.$2);
  }

  factory StatusChip.fromMutation(String mutation) {
    final map = {
      'IN': ('Masuk', AppTheme.success),
      'OUT': ('Keluar', AppTheme.error),
      'OTHER': ('Lainnya', AppTheme.warning),
    };
    final entry = map[mutation] ?? ('Unknown', Colors.grey);
    return StatusChip(label: entry.$1, color: entry.$2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
