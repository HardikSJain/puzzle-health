import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_theme/app_colors.dart';

/// App Theme Configuration
class AppTheme {
  AppTheme._();

  // ============================================================================
  // LIGHT THEME (Inverted minimalist - white bg, black accents)
  // ============================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ---- Color Scheme ----
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0A0A0A),
        onPrimary: Colors.white,
        secondary: Color(0xFF6B6B6B),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF0A0A0A),
        error: AppColor.errorColor,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: const Color(0xFFFAFAFA),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF0A0A0A),
        unselectedItemColor: Color(0xFFA3A3A3),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A0A0A),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF0A0A0A)),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0A0A0A),
          side: const BorderSide(color: Color(0xFF0A0A0A), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A0A0A), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E5E5),
        thickness: 1,
      ),

      iconTheme: const IconThemeData(color: Color(0xFF0A0A0A)),
    );
  }

  // ============================================================================
  // DARK THEME (Primary)
  // ============================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ---- Color Scheme ----
      colorScheme: const ColorScheme.dark(
        primary: AppColor.primaryColor,
        onPrimary: AppColor.backgroundColor,
        secondary: AppColor.secondaryColor,
        onSecondary: Colors.white,
        surface: AppColor.surfaceColor,
        onSurface: AppColor.primaryTextColor,
        error: AppColor.errorColor,
        onError: Colors.white,
      ),

      // ---- Scaffold ----
      scaffoldBackgroundColor: AppColor.backgroundColor,

      // ---- AppBar ----
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.backgroundColor,
        foregroundColor: AppColor.primaryTextColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // ---- Bottom Navigation ----
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColor.surfaceColor,
        selectedItemColor: AppColor.primaryColor,
        unselectedItemColor: AppColor.tertiaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ---- Elevated Button (White on black) ----
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          foregroundColor: AppColor.backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ---- Text Button ----
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColor.primaryColor),
      ),

      // ---- Outlined Button ----
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primaryColor,
          side: const BorderSide(color: AppColor.outlineColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ---- Input Decoration ----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.cardColor,
        hintStyle: const TextStyle(color: AppColor.tertiaryTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),

      // ---- Card ----
      cardTheme: CardThemeData(
        color: AppColor.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ---- Divider ----
      dividerTheme: const DividerThemeData(
        color: AppColor.dividerColor,
        thickness: 1,
      ),

      // ---- Floating Action Button ----
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: AppColor.backgroundColor,
        elevation: 0,
      ),

      // ---- Icon ----
      iconTheme: const IconThemeData(color: AppColor.primaryTextColor),

      // ---- Text Theme ----
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColor.primaryTextColor,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryTextColor,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryTextColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryTextColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryTextColor,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColor.secondaryTextColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColor.primaryTextColor,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColor.secondaryTextColor,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColor.tertiaryTextColor,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryTextColor,
          letterSpacing: 0.5,
        ),
      ),

      // ---- Chip Theme ----
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.cardColor,
        labelStyle: const TextStyle(color: AppColor.primaryTextColor),
        side: const BorderSide(color: AppColor.borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ---- Dialog Theme ----
      dialogTheme: DialogThemeData(
        backgroundColor: AppColor.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ---- Bottom Sheet Theme ----
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColor.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ---- Snackbar Theme ----
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.cardColor,
        contentTextStyle: const TextStyle(color: AppColor.primaryTextColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
