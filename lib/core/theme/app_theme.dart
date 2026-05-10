import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Plus Jakarta Sans — UI display font
  static TextTheme get _textTheme => GoogleFonts.plusJakartaSansTextTheme(
    ThemeData.light().textTheme.copyWith(
      displayLarge:  const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: AppColors.ink),
      displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: AppColors.ink),
      headlineLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: AppColors.ink),
      headlineMedium:const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.ink),
      titleLarge:    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: AppColors.ink),
      titleMedium:   const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: AppColors.ink),
      titleSmall:    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
      bodyLarge:     const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink),
      bodyMedium:    const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.ink2),
      bodySmall:     const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.ink3),
      labelLarge:    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: AppColors.ink),
      labelMedium:   const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink2),
      labelSmall:    const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.6, color: AppColors.ink3),
    ),
  );

  // JetBrains Mono — prices, codes, numerics
  static TextStyle price({double size = 16, Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color ?? AppColors.primary, letterSpacing: -0.4);

  static TextStyle mono({double size = 11, Color? color}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, color: color ?? AppColors.ink3, letterSpacing: 0.4);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.card,
      onPrimary: Colors.white,
      onSurface: AppColors.ink,
    ),
    scaffoldBackgroundColor: AppColors.paper,
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.ink,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: AppColors.ink,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.ink3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.primary,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
      side: const BorderSide(color: AppColors.line),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.ink3,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w500),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.ink,
      elevation: 4,
    ),
  );
}
