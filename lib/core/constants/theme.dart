import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/core/constants/theme_extensions.dart';

class AppTheme {
  // Define main application colors
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Colors.white;
  static const Color cardColorLight = Color(0xFFF4F4F5); // Zinc 100
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Lucide red
  static const Color textColor = Color(0xFF18181B); // Zinc 900
  static const Color textSecondaryColor = Color(0xFF71717A); // Zinc 500
  static const Color borderColor = Color(0xFFE4E4E7); // Zinc 200
  static const Color cardColorDark = Color(0xFF27272A); // Zinc 800
  static const Color borderColorDark = Color(0xFF3F3F46); // Zinc 700

  // Define the light theme
  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColorLight,
    dividerColor: borderColor,
    hintColor: const Color(0xFFA1A1AA), // Zinc 400
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textColor,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: textColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textColor),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 48.0,
        fontWeight: FontWeight.w800,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16.0, color: textColor),
      bodyMedium: GoogleFonts.inter(fontSize: 14.0, color: textSecondaryColor),
      labelLarge: GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: surfaceColor,
        side: const BorderSide(color: borderColor, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    iconTheme: const IconThemeData(color: textSecondaryColor, size: 24),
    extensions: const [CustomColors(aiIconColor: Colors.amber)],
  );

  // Define the dark theme
  static ThemeData get darkTheme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF18181B), // Zinc 900
    cardColor: cardColorDark,
    dividerColor: borderColorDark,
    hintColor: const Color(0xFFA1A1AA), // Zinc 400
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF18181B), // Zinc 900
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Color(0xFFFAFAFA), // Zinc 50
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF18181B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 48.0,
        fontWeight: FontWeight.w800,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16.0, color: Colors.white),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14.0,
        color: const Color(0xFFA1A1AA), // Zinc 400
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: cardColorDark,
        side: const BorderSide(color: borderColorDark, width: 2), // Zinc 700
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFA1A1AA), // Zinc 400
      size: 24,
    ),
    extensions: const [CustomColors(aiIconColor: primaryColor)],
  );
}
