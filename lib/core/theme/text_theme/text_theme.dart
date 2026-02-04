import 'package:flutter/material.dart';

abstract class AppTextTheme {
  AppTextTheme._();

  static const String defaultFontFamily = 'Manrope';
  static const String montserratFontFamily = 'Montserrat';

  static final TextStyle displaySuper = TextStyle(
    fontSize: 96,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.montserratFontFamily,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayLabel = TextStyle(
    fontSize: 60,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display3XLSB = TextStyle(
    fontSize: 44,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display3XLR = TextStyle(
    fontSize: 44,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display2XLSB = TextStyle(
    fontSize: 36,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display2XLR = TextStyle(
    fontSize: 36,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayXLSB = TextStyle(
    fontSize: 32,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayXLR = TextStyle(
    fontSize: 32,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayLSB = TextStyle(
    fontSize: 26,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayLR = TextStyle(
    fontSize: 26,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayMSB = TextStyle(
    fontSize: 22,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayMR = TextStyle(
    fontSize: 22,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displaySSB = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displaySR = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayXSSB = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayXSS = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.montserratFontFamily,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle displayXSR = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display2XSSB = TextStyle(
    fontSize: 14,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display2XSR = TextStyle(
    fontSize: 14,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display3XSSB = TextStyle(
    fontSize: 12,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle display3XSR = TextStyle(
    fontSize: 12,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle summary = TextStyle(
    fontSize: 46,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w300,
  );
  static final TextStyle heading1a = TextStyle(
    fontSize: 14,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w300,
  );

  static final TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w300,
  );

  static final TextStyle heading2r = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle heading2m = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle heading2mm = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle heading2b = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle heading2bxl = TextStyle(
    fontSize: 20,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w800,
  );

  static final TextStyle body3XXLr = TextStyle(
    fontSize: 54,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle body3XLr = TextStyle(
    fontSize: 24,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle body3XLm = TextStyle(
    fontSize: 24,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle body3XLm1 = TextStyle(
    fontSize: 24,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle body3XLb = TextStyle(
    fontSize: 24,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle body2XLr = TextStyle(
    fontSize: 22,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle body2XLm = TextStyle(
    fontSize: 22,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle body2XLb = TextStyle(
    fontSize: 22,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodyXLr = TextStyle(
    fontSize: 18,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyXLm = TextStyle(
    fontSize: 18,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle bodyXLmm = TextStyle(
    fontSize: 18,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyXLb = TextStyle(
    fontSize: 18,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodyLr = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyLm = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle bodyLmm1 = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle heading = TextStyle(
    fontSize: 64,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodyLb = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodyLb1 = TextStyle(
    fontSize: 16,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w800,
  );

  static final TextStyle bodyMr = TextStyle(
    fontSize: 14,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyMm = TextStyle(
    fontSize: 14,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle bodyMm1 = TextStyle(
    fontSize: 14,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyMb = TextStyle(
    fontSize: 14,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodySr = TextStyle(
    fontSize: 12,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodySm = TextStyle(
    fontSize: 12,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle bodySmm1 = TextStyle(
    fontSize: 12,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodySb = TextStyle(
    fontSize: 12,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodyXSr = TextStyle(
    fontSize: 10,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyXSm = TextStyle(
    fontSize: 10,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyXSm1 = TextStyle(
    fontSize: 10,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle bodySm1 = TextStyle(
    fontSize: 32,
    fontFamily: AppTextTheme.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );
}
