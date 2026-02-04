import 'package:flutter/material.dart';

import '../../../../core/theme/color_theme/app_colors.dart';

/// Home Page - The decision surface
/// Answers: What am I supposed to do right now, and am I on track?
///
/// CRITICAL RULES - DO NOT ADD:
/// - Tips, encouragement, or motivational language
/// - Educational content or explanations
/// - Visuals, graphs, or celebratory states
/// - Multiple goals or alternatives
/// - Interactive elements beyond navigation
///
/// This page is a status display. The system speaks; the user complies or doesn't.
/// Adaptation happens across weeks, not within the page.
///
/// STATE PRESERVATION:
/// ShellRoute preserves widget tree when switching tabs.
/// For scroll position preservation (if needed later), add PageStorageKey.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // TODO: Replace with actual data from backend
  static const int _weeklyGoal = 3000;
  static const int _daysCompleted = 3;
  static const int _totalDays = 7;
  static const int _todaySteps = 1247;
  static const String _focusStatement = "3,000 steps every day this week.";
  static const String _focusReason =
      "Your weekend drop limits weekly consistency.";

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
              const SizedBox(height: 8),

              // The Focus - Declarative state, not imperative command
              Text(
                _focusStatement,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryTextColor,
                  height: 1.2,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 16),

              // Justification - Metadata explaining constraint
              Text(
                _focusReason,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColor.primaryTextColor.withValues(alpha: 0.5),
                  height: 1.5,
                  letterSpacing: -0.1,
                ),
              ),

              const SizedBox(height: 36),

              // Progress state - Automatically derived, coarse
              _buildProgressState(),

              const SizedBox(height: 24),

              // Today's relevance - What counts today?
              _buildTodayRelevance(),

              // Silence - Intentional empty space
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressState() {
    return Text(
      '$_daysCompleted of $_totalDays days completed',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColor.primaryTextColor,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildTodayRelevance() {
    final isOnTrack = _todaySteps >= _weeklyGoal;
    final todayStatus = isOnTrack
        ? 'Today complete.'
        : 'Today counts if you reach ${_formatNumber(_weeklyGoal)} steps.';

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 32,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: isOnTrack
                  ? AppColor.accentTeal.withValues(alpha: 0.4)
                  : AppColor.primaryTextColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.secondaryColor.withValues(alpha: 0.4),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayStatus,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColor.primaryTextColor.withValues(alpha: 0.7),
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
