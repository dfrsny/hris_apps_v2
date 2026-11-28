import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  // --- Brand Primary & Secondary (Akan diselaraskan dengan aset logo/brand) ---
  static const Color primary = Color(
    0xFF1E3A8A,
  ); // Deep Indigo / Corporate Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  static const Color secondary = Color(0xFF0F766E); // Slate Teal
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondaryContainer = Color(0xFF115E59);

  // --- Neutral Surfaces & Borders ---
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // --- Dark Surfaces ---
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);

  // --- Semantic HRIS Status Colors ---
  static const Color success = Color(0xFF15803D); // Hadir, Disetujui, Aktif
  static const Color successSurface = Color(0xFFDCFCE7);

  static const Color warning = Color(
    0xFFB45309,
  ); // Terlambat, Menunggu (Pending)
  static const Color warningSurface = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFB91C1C); // Ditolak, Alpha, Nonaktif
  static const Color errorSurface = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF0369A1); // Draft Payroll, Info Sistem
  static const Color infoSurface = Color(0xFFE0F2FE);

  // --- Role Badge Colors ---
  static const Color roleSuperAdmin = Color(0xFF6D28D9);
  static const Color roleHr = Color(0xFF1D4ED8);
  static const Color roleFinance = Color(0xFF0F766E);
  static const Color roleEmployee = Color(0xFF334155);
}
