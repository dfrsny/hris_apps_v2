import 'package:material_ui/material_ui.dart';

abstract final class AppTextStyles {
  static const String headingFont = 'PlusJakartaSans';
  static const String bodyFont = 'Inter';

  static TextTheme buildTextTheme({
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primaryTextColor,
      ),
      titleLarge: TextStyle(
        fontFamily: headingFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontFamily: headingFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: primaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: primaryTextColor,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: secondaryTextColor,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryTextColor,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: secondaryTextColor,
      ),
    );
  }
}
