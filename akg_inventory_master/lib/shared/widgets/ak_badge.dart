import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AkBadge — Reusable badge widget
/// Phase 0 — Grand Refactor
///
/// Usage:
///   AkBadge.mutation(MutationCode.inbound)
///   AkBadge.docStatus(DocStatus.completed)
///   AkBadge.reason('EMPTY')
///   AkBadge.invoiceStatus('PAID')
///   AkBadge.tag('MP')
/// ─────────────────────────────────────────────────────────────────────────────

enum BadgeType { mutation, docStatus, reason, invoiceStatus, tag, custom }

class AkBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;
  final bool outlined;

  const AkBadge._({
    required this.label,
    required this.textColor,
    required this.bgColor,
    this.outlined = false,
  });

  // ── Factory: Mutation (IN / OUT / OTHER) ────────────────────────────────────
  factory AkBadge.mutation(String code) {
    switch (code.toUpperCase()) {
      case 'IN':
        return AkBadge._(
          label: 'IN',
          textColor: AppColors.mutationInColor,
          bgColor: AppColors.mutationInBg,
        );
      case 'OUT':
        return AkBadge._(
          label: 'OUT',
          textColor: AppColors.mutationOutColor,
          bgColor: AppColors.mutationOutBg,
        );
      default:
        return AkBadge._(
          label: code.toUpperCase(),
          textColor: AppColors.mutationOtherColor,
          bgColor: AppColors.mutationOtherBg,
        );
    }
  }

  // ── Factory: Document Status (DRAFT / COMPLETED / VOID) ────────────────────
  factory AkBadge.docStatus(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return AkBadge._(
          label: 'COMPLETED',
          textColor: AppColors.statusDoneColor,
          bgColor: AppColors.statusDoneBg,
        );
      case 'VOID':
        return AkBadge._(
          label: 'VOID',
          textColor: AppColors.statusVoidColor,
          bgColor: AppColors.statusVoidBg,
        );
      default: // DRAFT
        return AkBadge._(
          label: 'DRAFT',
          textColor: AppColors.statusDraftColor,
          bgColor: AppColors.statusDraftBg,
        );
    }
  }

  // ── Factory: Reason (EMPTY / RETUR / NORMAL / etc.) ────────────────────────
  factory AkBadge.reason(String reason) {
    switch (reason.toUpperCase()) {
      case 'EMPTY':
        return AkBadge._(
          label: 'EMPTY',
          textColor: AppColors.reasonEmptyColor,
          bgColor: AppColors.reasonEmptyBg,
          outlined: true,
        );
      case 'RETUR':
        return AkBadge._(
          label: 'RETUR',
          textColor: AppColors.reasonReturColor,
          bgColor: AppColors.reasonReturBg,
          outlined: true,
        );
      default:
        return AkBadge._(
          label: reason.toUpperCase(),
          textColor: AppColors.reasonNormalColor,
          bgColor: AppColors.filterBg,
        );
    }
  }

  // ── Factory: Invoice Status ─────────────────────────────────────────────────
  factory AkBadge.invoiceStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return AkBadge._(
          label: 'PAID',
          textColor: AppColors.invoicePaidColor,
          bgColor: AppColors.invoicePaidBg,
        );
      case 'PARTIAL_PAID':
        return AkBadge._(
          label: 'PARTIAL',
          textColor: AppColors.invoicePartialColor,
          bgColor: AppColors.invoicePartialBg,
        );
      case 'OVERDUE':
        return AkBadge._(
          label: 'OVERDUE',
          textColor: AppColors.invoiceOverdueColor,
          bgColor: AppColors.invoiceOverdueBg,
        );
      case 'VOID':
        return AkBadge._(
          label: 'VOID',
          textColor: AppColors.statusVoidColor,
          bgColor: AppColors.statusVoidBg,
        );
      default: // DRAFT / SENT / UNPAID
        return AkBadge._(
          label: status.toUpperCase(),
          textColor: AppColors.invoiceUnpaidColor,
          bgColor: AppColors.invoiceUnpaidBg,
        );
    }
  }

  // ── Factory: Asset Tags (MP / MR) ──────────────────────────────────────────
  factory AkBadge.tag(String tag) {
    switch (tag.toUpperCase()) {
      case 'MR':
        return AkBadge._(
          label: 'MR',
          textColor: AppColors.tagMrColor,
          bgColor: AppColors.tagMrBg,
        );
      default: // MP
        return AkBadge._(
          label: 'MP',
          textColor: AppColors.tagMpColor,
          bgColor: AppColors.tagMpBg,
        );
    }
  }

  // ── Factory: Asset Status (READY / RENTED / MAINT / etc.) ─────────────────
  factory AkBadge.assetStatus(String status) {
    switch (status.toUpperCase()) {
      case 'READY':
        return AkBadge._(
          label: 'READY',
          textColor: AppColors.googleGreen,
          bgColor: const Color(0xFFE6F9EF),
        );
      case 'RENTED':
        return AkBadge._(
          label: 'RENTED',
          textColor: AppColors.googleBlue,
          bgColor: AppColors.mutationInBg,
        );
      case 'MAINT':
      case 'MAINTENANCE':
        return AkBadge._(
          label: 'MAINT',
          textColor: AppColors.googleYellow,
          bgColor: AppColors.warningBg,
        );
      case 'LOST':
        return AkBadge._(
          label: 'LOST',
          textColor: AppColors.errorRed,
          bgColor: AppColors.errorBg,
        );
      case 'SOLD':
        return AkBadge._(
          label: 'SOLD',
          textColor: const Color(0xFF7B4397),
          bgColor: const Color(0xFFF3E5F5),
        );
      default:
        return AkBadge._(
          label: status.toUpperCase(),
          textColor: AppColors.textSecondary,
          bgColor: AppColors.filterBg,
        );
    }
  }


  // ── Factory: Custom ─────────────────────────────────────────────────────────
  factory AkBadge.custom({
    required String label,
    required Color textColor,
    required Color bgColor,
    bool outlined = false,
  }) {
    return AkBadge._(
      label: label,
      textColor: textColor,
      bgColor: bgColor,
      outlined: outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: outlined
            ? Border.all(color: textColor.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
