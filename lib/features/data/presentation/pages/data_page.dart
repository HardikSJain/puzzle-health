import 'package:flutter/material.dart';

import '../../../../core/theme/color_theme/app_colors.dart';

/// Data Page - Read-only rolling baselines
/// Confidence repair when users doubt the system
class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Data',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryTextColor,
                  height: 1.2,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Rolling baselines and trends',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondaryColor.withValues(alpha: 0.6),
                  letterSpacing: 0.1,
                ),
              ),

              const SizedBox(height: 48),

              // TODO: Replace with actual baseline data
              _buildBaselineCard(
                'Current baseline',
                '2,000 steps/day',
                'Last 30 days',
              ),

              const SizedBox(height: 16),

              _buildBaselineCard(
                'Pattern',
                'Weekday-focused',
                'Weekend activity drops sharply',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBaselineCard(String label, String value, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.5),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColor.primaryTextColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColor.primaryTextColor.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
