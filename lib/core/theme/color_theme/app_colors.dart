import 'package:flutter/material.dart';

abstract class AppColor {
  AppColor._();

  // ============================================================================
  // DARK MINIMALIST PALETTE
  // ============================================================================

  /// Deep black background (Primary)
  static const Color backgroundColor = Color(0xFF0A0A0A);

  /// Slightly elevated surface for cards
  static const Color surfaceColor = Color(0xFF141414);

  /// Card/Container elevated surface
  static const Color cardColor = Color(0xFF1A1A1A);

  /// Pure white as primary accent (minimalist)
  static const Color primaryColor = Color(0xFFFFFFFF);

  /// Muted gray for secondary elements
  static const Color secondaryColor = Color(0xFF8A8A8A);

  /// Silver accent for premium feel
  static const Color accentColor = Color(0xFFC0C0C0);

  /// Feedback & status colors (muted, premium)
  static const Color successColor = Color(0xFF14B8A6);
  static const Color warningColor = Color(0xFFFBBF24);
  static const Color errorColor = Color(0xFFEF4444);

  /// Text colors - high contrast on dark
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFFA3A3A3);
  static const Color tertiaryTextColor = Color(0xFF6B6B6B);

  /// Subtle borders and dividers
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color dividerColor = Color(0xFF1F1F1F);

  /// Visible outline for buttons (lighter than borderColor)
  static const Color outlineColor = Color(0xFF525252);

  /// Gray scale
  static const Color lightGray = Color(0xFF262626);
  static const Color mediumGray = Color(0xFF404040);
  static const Color darkGray = Color(0xFF171717);

  /// Premium accents
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentPurple = Color(0xFFA855F7);
}
