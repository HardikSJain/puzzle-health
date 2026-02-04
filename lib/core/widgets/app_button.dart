import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/color_theme/app_colors.dart';

/// A reusable primary button with consistent styling across the app.
///
/// Supports:
/// - Text, icon, or both
/// - Loading state
/// - Disabled state
/// - Secondary (outline) variant
/// - Haptic feedback
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 56,
    this.borderRadius = 14,
    this.haptic = true,
  }) : assert(
         text != null || icon != null,
         'Either text or icon must be provided',
       );

  /// Button label text
  final String? text;

  /// Optional icon (shown before text if both provided)
  final IconData? icon;

  /// Callback when pressed. If null, button is disabled.
  final VoidCallback? onPressed;

  /// Shows loading spinner instead of content
  final bool isLoading;

  /// If true, renders as outline button
  final bool isSecondary;

  /// Custom background color (defaults to accentTeal)
  final Color? backgroundColor;

  /// Custom foreground/text color
  final Color? foregroundColor;

  /// Custom width (defaults to full width)
  final double? width;

  /// Button height (defaults to 56)
  final double height;

  /// Border radius (defaults to 14)
  final double borderRadius;

  /// Whether to trigger haptic on press
  final bool haptic;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColor.accentTeal;
    final fgColor = foregroundColor ?? AppColor.backgroundColor;

    final isDisabled = onPressed == null || isLoading;

    void handlePress() {
      if (haptic) HapticFeedback.selectionClick();
      onPressed?.call();
    }

    final buttonChild = _buildChild(fgColor);

    if (isSecondary) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isDisabled ? null : handlePress,
          style: OutlinedButton.styleFrom(
            foregroundColor: bgColor,
            side: BorderSide(color: bgColor.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 0,
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: isDisabled ? null : handlePress,
        style: FilledButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
          disabledForegroundColor: fgColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: buttonChild,
      ),
    );
  }

  Widget _buildChild(Color fgColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: fgColor),
      );
    }

    // Icon only
    if (text == null && icon != null) {
      return Icon(icon, size: 24);
    }

    // Text only
    if (text != null && icon == null) {
      return Text(
        text!,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      );
    }

    // Both icon and text
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(
          text!,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
