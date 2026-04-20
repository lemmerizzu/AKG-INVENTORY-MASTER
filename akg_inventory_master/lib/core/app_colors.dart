import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppColors — Centralized Design Token
/// Referensi: Figma `transaction_view` (Node 23:338), AppSheet UI/UX pattern
/// Phase 0 — Grand Refactor
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color googleBlue     = Color(0xFF1A73E8); // Primary action / CTA
  static const Color googleBlueDark = Color(0xFF1557B0); // Hover/pressed state
  static const Color selectedBg     = Color(0xFFE8F0FE); // Selected list item bg

  // ── Page Structure ─────────────────────────────────────────────────────────
  static const Color pageBg         = Color(0xFFF8F9FA); // App background
  static const Color panelBg        = Color(0xFFFFFFFF); // Panel / card bg
  static const Color topBarBg       = Color(0xFFFFFFFF); // Top bar bg
  static const Color sidebarBg      = Color(0xFFFFFFFF); // Icon sidebar bg

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF202124); // Body / heading
  static const Color textSecondary  = Color(0xFF5F6368); // Subtitle / label
  static const Color textDisabled   = Color(0xFFBDC1C6); // Disabled / placeholder
  static const Color textLink       = Color(0xFF1A73E8); // Hyperlink

  // ── Borders & Dividers ─────────────────────────────────────────────────────
  static const Color borderColor    = Color(0xFFDADCE0); // Input / card border
  static const Color dividerColor   = Color(0xFFE8EAED); // Subtle divider

  // ── Input ──────────────────────────────────────────────────────────────────
  static const Color inputBg        = Color(0xFFF1F3F4); // Search bar / input bg
  static const Color filterBg       = Color(0xFFF2F3F7); // Filter chip bg

  // ── Semantic / Status ──────────────────────────────────────────────────────
  static const Color successGreen   = Color(0xFF188038); // PAID / COMPLETED
  static const Color successBg      = Color(0xFFE6F4EA); // Success badge bg
  static const Color warningOrange  = Color(0xFFE37400); // PARTIAL / OVERDUE
  static const Color warningBg      = Color(0xFFFEF7E0); // Warning badge bg
  static const Color errorRed       = Color(0xFFBA1A1A); // VOID / Error
  static const Color errorBg        = Color(0xFFFCE8E6); // Error badge bg
  static const Color infoPurple     = Color(0xFF7B4397); // DRAFT badge

  // ── Google-hue Accent Colors (Asset Status Indicators) ─────────────────────
  static const Color googleGreen    = Color(0xFF00C853); // AVAILABLE/READY
  static const Color googleYellow   = Color(0xFFF9AB00); // MAINTENANCE
  static const Color googleOrange   = Color(0xFFE37400); // UNAUDITED / WARNING


  // ── Mutation Badges ────────────────────────────────────────────────────────
  /// Mutation IN → Blue
  static const Color mutationInColor  = Color(0xFF1A73E8);
  static const Color mutationInBg     = Color(0xFFE8F0FE);

  /// Mutation OUT → Orange
  static const Color mutationOutColor = Color(0xFFE37400);
  static const Color mutationOutBg    = Color(0xFFFEF7E0);

  /// Mutation OTHER → Grey
  static const Color mutationOtherColor = Color(0xFF5F6368);
  static const Color mutationOtherBg    = Color(0xFFF1F3F4);

  // ── Reason Badges (Inventory Ledger) ───────────────────────────────────────
  /// NORMAL / default
  static const Color reasonNormalColor = Color(0xFF5F6368);

  /// EMPTY — tabung kosong dikembalikan
  static const Color reasonEmptyColor  = Color(0xFF1A73E8);
  static const Color reasonEmptyBg     = Color(0xFFE8F0FE);

  /// RETUR — barang dikembalikan
  static const Color reasonReturColor  = Color(0xFFBA1A1A);
  static const Color reasonReturBg     = Color(0xFFFCE8E6);

  // ── Doc Status Badges ──────────────────────────────────────────────────────
  /// DRAFT → grey
  static const Color statusDraftColor  = Color(0xFF5F6368);
  static const Color statusDraftBg     = Color(0xFFF1F3F4);

  /// COMPLETED → green
  static const Color statusDoneColor   = Color(0xFF188038);
  static const Color statusDoneBg      = Color(0xFFE6F4EA);

  /// VOID → red
  static const Color statusVoidColor   = Color(0xFFBA1A1A);
  static const Color statusVoidBg      = Color(0xFFFCE8E6);

  // ── Invoice Status Badges ──────────────────────────────────────────────────
  static const Color invoiceUnpaidColor   = Color(0xFFE37400);
  static const Color invoiceUnpaidBg      = Color(0xFFFEF7E0);
  static const Color invoicePaidColor     = Color(0xFF188038);
  static const Color invoicePaidBg        = Color(0xFFE6F4EA);
  static const Color invoicePartialColor  = Color(0xFF1A73E8);
  static const Color invoicePartialBg     = Color(0xFFE8F0FE);
  static const Color invoiceOverdueColor  = Color(0xFFBA1A1A);
  static const Color invoiceOverdueBg     = Color(0xFFFCE8E6);

  // ── Tags / Asset Badges ────────────────────────────────────────────────────
  /// MP = Milik Pabrik (owned)
  static const Color tagMpColor = Color(0xFF1A73E8);
  static const Color tagMpBg    = Color(0xFFE8F0FE);

  /// MR = Milik Relasi (borrowed)
  static const Color tagMrColor = Color(0xFF7B4397);
  static const Color tagMrBg    = Color(0xFFF3E5F5);
}
