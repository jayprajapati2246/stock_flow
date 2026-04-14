import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumTheme {
  // Brand Colors
  static const primaryColor = Color(0xFF6366F1); // Indigo
  static const secondaryColor = Color(0xFFF43F5E); // Rose
  static const accentColor = Color(0xFF8B5CF6); // Violet
  
  // Light Mode Colors
  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Colors.white;
  static const lightTextPrimary = Color(0xFF1E293B);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);

  // Dark Mode Colors
  static const darkBg = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);

  static ThemeData get light {
    return _base(
      brightness: Brightness.light,
      bg: lightBg,
      surface: lightSurface,
      text: lightTextPrimary,
      textSec: lightTextSecondary,
      border: lightBorder,
    );
  }

  static ThemeData get dark {
    return _base(
      brightness: Brightness.dark,
      bg: darkBg,
      surface: darkSurface,
      text: darkTextPrimary,
      textSec: darkTextSecondary,
      border: darkBorder,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color textSec,
    required Color border,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surface,
      error: const Color(0xFFEF4444),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      dividerColor: border,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: text,
        displayColor: text,
      ).copyWith(
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: text),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: text),
        bodyLarge: GoogleFonts.inter(color: text),
        bodyMedium: GoogleFonts.inter(color: textSec),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        iconTheme: IconThemeData(color: text),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }
}
