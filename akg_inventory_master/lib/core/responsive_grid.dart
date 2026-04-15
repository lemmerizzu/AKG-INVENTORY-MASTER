import 'package:flutter/material.dart';

/// Membantu layout merespon ke grid secara otomatis
/// Terinspirasi dari Bootstrap/Material Grid System yang membagi layar ke 12 kolom
class ResponsiveGrid extends StatelessWidget {
  final List<ResponsiveGridItem> children;
  
  /// Jarak antar kolom (horizontal)
  final double crossAxisSpacing;
  
  /// Jarak antar baris (vertical)
  final double mainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        
        List<Widget> rows = [];
        List<Widget> currentRowChildren = [];
        int currentFlex = 0;

        for (var item in children) {
          final int span = item.getSpanForWidth(maxWidth);

          // If adding this item exceeds the 12-column limit, wrap to next row
          if (currentFlex + span > 12) {
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.from(currentRowChildren),
            ));
            rows.add(SizedBox(height: mainAxisSpacing));
            currentRowChildren.clear();
            currentFlex = 0;
          }

          currentRowChildren.add(
            Expanded(
              flex: span,
              child: Padding(
                padding: EdgeInsets.only(
                  right: (currentFlex + span < 12) ? crossAxisSpacing : 0,
                ),
                child: item.child,
              ),
            ),
          );
          currentFlex += span;
        }

        // Add remaining items
        if (currentRowChildren.isNotEmpty) {
           // Fill empty space if the row is not completely filled (less than 12)
          if (currentFlex < 12) {
             currentRowChildren.add(Spacer(flex: 12 - currentFlex));
          }
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: currentRowChildren,
          ));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }
}

class ResponsiveGridItem {
  final Widget child;
  // Span out of 12 columns
  final int xs; // Pnones
  final int sm; // Tablets
  final int md; // Destops/Windows
  final int lg; // Large Windows

  ResponsiveGridItem({
    required this.child,
    this.xs = 12,
    this.sm = 12, // Default to full width on smaller screens
    int? md,
    int? lg,
  })  : md = md ?? sm,
        lg = lg ?? (md ?? sm);

  int getSpanForWidth(double width) {
    if (width >= 1200) return lg;
    if (width >= 900) return md;
    if (width >= 600) return sm;
    return xs;
  }
}
