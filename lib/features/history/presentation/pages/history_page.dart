import 'package:flutter/material.dart';

import '../../../../core/theme/color_theme/app_colors.dart';

/// History Page - Past focuses and outcomes
/// Shows where meaning accumulates over time
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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
                'History',
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
                'Past focuses and outcomes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondaryColor.withValues(alpha: 0.6),
                  letterSpacing: 0.1,
                ),
              ),

              const SizedBox(height: 48),

              // TODO: Replace with actual historical data
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Text(
                    'No history yet.\nComplete your first week to see results.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColor.primaryTextColor.withValues(alpha: 0.5),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
