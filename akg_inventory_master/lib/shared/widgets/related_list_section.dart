import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';

/// Reusable Related List section widget — AppSheet-style.
/// Shows a tabbed header with count badge, and renders content below.
class RelatedListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Widget child;
  final VoidCallback? onAddPressed;

  const RelatedListSection({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.child,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const Spacer(),
            if (onAddPressed != null)
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: AppTheme.primaryBlue,
                tooltip: 'Tambah',
                onPressed: onAddPressed,
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Content
        child,
      ],
    );
  }
}

/// Loading shimmer for related list content.
class RelatedListLoading extends StatelessWidget {
  const RelatedListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _shimmerBlock(80, 14),
                const SizedBox(width: 16),
                _shimmerBlock(120, 14),
                const Spacer(),
                _shimmerBlock(60, 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBlock(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Empty state for related lists.
class RelatedListEmpty extends StatelessWidget {
  final String message;
  final IconData icon;

  const RelatedListEmpty({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.grey.withValues(alpha: 0.35)),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(
                color: AppTheme.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
