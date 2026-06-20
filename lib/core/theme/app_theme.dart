import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Shared Brand Colors ---
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color accentColor = Color(0xFFFF6584);
  static const Color accentGreen = Color(0xFF43D9AD);
  static const Color accentOrange = Color(0xFFFFB347);

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF1E2040);
  static const Color darkBorder = Color(0xFF2E3060);
  static const Color darkTextPrimary = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFF8A8AB0);

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0E0F0);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B8A);

  // --- Legacy aliases for backward compat ---
  static const Color secondaryColor = darkSurface;
  static const Color backgroundColor = darkBackground;
  static const Color surfaceColor = darkSurface;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;

  // --- Note card accent colors ---
  static const List<Color> noteAccents = [
    Color(0xFF6C63FF),
    Color(0xFF43D9AD),
    Color(0xFFFFB347),
    Color(0xFFFF6584),
    Color(0xFF64B5F6),
    Color(0xFFBA68C8),
    Color(0xFFFF8A65),
    Color(0xFF4DB6AC),
  ];

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentGreen,
        surface: darkSurface,
        error: accentColor,
        onPrimary: Colors.white,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      textTheme: _buildTextTheme(darkTextPrimary, darkTextSecondary),
      inputDecorationTheme: _buildInputTheme(darkSurface, darkBorder, darkTextSecondary),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Colors.white),
      cardTheme: _buildCardTheme(darkCard),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: darkTextSecondary),
      dividerColor: darkBorder,
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentGreen,
        surface: lightSurface,
        error: accentColor,
        onPrimary: Colors.white,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      textTheme: _buildTextTheme(lightTextPrimary, lightTextSecondary),
      inputDecorationTheme: _buildInputTheme(lightSurface, lightBorder, lightTextSecondary),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(primaryColor),
      cardTheme: _buildCardTheme(lightCard),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: lightTextSecondary),
      dividerColor: lightBorder,
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      shadowColor: primaryColor.withValues(alpha: 0.08),
    );
  }

  // ==================== SHARED BUILDERS ====================
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.w800, letterSpacing: -1),
      displayMedium: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.outfit(color: primary),
      bodyMedium: GoogleFonts.outfit(color: secondary),
      bodySmall: GoogleFonts.outfit(color: secondary, fontSize: 12),
      labelLarge: GoogleFonts.outfit(color: primary, fontWeight: FontWeight.w600),
    );
  }

  static InputDecorationTheme _buildInputTheme(Color fill, Color border, Color labelColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      labelStyle: TextStyle(color: labelColor),
      hintStyle: TextStyle(color: labelColor.withValues(alpha: 0.5)),
      prefixIconColor: labelColor,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryColor.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: primaryColor.withValues(alpha: 0.4),
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Color fgColor) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }

  static CardThemeData _buildCardTheme(Color color) {
    return CardThemeData(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      margin: EdgeInsets.zero,
    );
  }
}
