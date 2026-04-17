import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color primary = Color(0xFFFF4500); // Orange
  static const Color secondary = Color(0xFFFF69B4); // Pink
  static const Color accent = Color(0xFFFFD700); // Gold
  static const Color hint = Color(0xFF800080); // Purple
  static const Color success = Color(0xFF008080); // Teal
  static const Color error = Color(0xFFEF4444);
  
  static const Color primaryText = Color(0xFFF1F5F9);
  static const Color secondaryText = Color(0xFF94A3B8);
  
  static const Color glassBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassSurface = Color(0x331A1A1A); // 20% opacity surface
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryText,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.primaryText,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: TextStyle(
            color: AppColors.primaryText,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
          titleLarge: TextStyle(
            color: AppColors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
