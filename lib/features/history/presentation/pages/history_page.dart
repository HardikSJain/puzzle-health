import 'package:flutter/material.dart';

import '../../../../core/models/fitness_state.dart';
import '../../../../core/services/local_store_service.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../core/widgets/glass_surface.dart';

/// History Page - Past focuses and outcomes
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = LocalStoreService.getFocusHistory();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
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
                'Previous goals and outcomes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondaryColor.withValues(alpha: 0.6),
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 24),
              if (history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Text(
                      'No completed weeks yet.\nFinish this week to unlock history.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.primaryTextColor.withValues(alpha: 0.5),
                        height: 1.6,
                      ),
                    ),
                  ),
                )
              else
                ...history.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassSurface(
                      radius: 10,
                      alpha: 0.04,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.goalType == 'run_frequency'
                              ? '${item.targetRunsPerWeek ?? 2} runs weekly goal'
                              : '${item.targetSteps} steps daily goal',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Week of ${item.weekStartIso}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColor.secondaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'State: ${item.fitnessState.label}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColor.secondaryColor.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.completionRate != null
                              ? '${(item.completionRate! * 100).round()}% on target'
                              : 'On-target rate: n/a',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColor.primaryTextColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
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
