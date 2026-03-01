import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/color_theme/app_colors.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double alpha;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = 12,
    this.alpha = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: AppColor.primaryTextColor.withValues(alpha: alpha),
            border: Border.all(
              color: AppColor.primaryTextColor.withValues(alpha: 0.08),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
