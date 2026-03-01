import 'package:flutter/material.dart';

import '../../../../core/models/current_focus.dart';
import '../../../../core/services/local_store_service.dart';
import '../../../../core/services/progress_service.dart';
import '../../../../core/services/weekly_cycle_service.dart';
import '../../../../core/theme/color_theme/app_colors.dart';

/// Home Page - Command center
/// Primary question: What should I do today, and how close am I?
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CurrentFocus? _focus;
  WeekProgress? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final focus = await WeeklyCycleService.initializeOrRefresh();
    final progress = await ProgressService.getWeekProgress(focus);

    if (!mounted) return;
    setState(() {
      _focus = focus;
      _progress = progress;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _focus == null || _progress == null) {
      return const Scaffold(
        backgroundColor: AppColor.backgroundColor,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final focus = _focus!;
    final progress = _progress!;
    final remainingToday = (focus.targetSteps - progress.todaySteps).clamp(
      0,
      focus.targetSteps,
    );

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodayHeader(progress, remainingToday),
                const SizedBox(height: 24),
                _buildWeeklyGoalBlock(focus),
                const SizedBox(height: 18),
                _buildWeeklyChart(progress),
                const SizedBox(height: 20),
                _buildWeekStatus(progress),
                const SizedBox(height: 24),
                _buildRatingPrompt(),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayHeader(WeekProgress progress, int remainingToday) {
    final progressRatio =
        progress.targetSteps == 0
            ? 0.0
            : (progress.todaySteps / progress.targetSteps).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.75),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatNumber(progress.todaySteps)} / ${_formatNumber(progress.targetSteps)} steps',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColor.primaryTextColor,
              letterSpacing: -0.7,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progressRatio,
              backgroundColor: AppColor.primaryTextColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress.isOnTrackToday
                    ? AppColor.accentTeal
                    : AppColor.primaryTextColor.withValues(alpha: 0.85),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progress.isOnTrackToday
                ? 'Today complete.'
                : '${_formatNumber(remainingToday)} steps to go today.',
            style: TextStyle(
              fontSize: 14,
              color: AppColor.primaryTextColor.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalBlock(CurrentFocus focus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal: ${_formatNumber(focus.targetSteps)} steps daily this week',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryTextColor,
            letterSpacing: -0.35,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _shortReason(focus.reason),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.primaryTextColor.withValues(alpha: 0.62),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(WeekProgress progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly progress',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: _WeeklyBars(
              dailySteps: progress.dailySteps,
              targetSteps: progress.targetSteps,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStatus(WeekProgress progress) {
    return Text(
      '${progress.daysCompleted}/7 days complete',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColor.primaryTextColor.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildRatingPrompt() {
    final rating = LocalStoreService.getWeeklyRating();
    if (rating != null) {
      return Text(
        rating
            ? 'You marked this week\'s goal as a good fit.'
            : 'You marked this week\'s goal as not a fit.',
        style: TextStyle(
          fontSize: 13,
          color: AppColor.secondaryColor.withValues(alpha: 0.7),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Was this week\'s goal right for you?',
          style: TextStyle(
            fontSize: 14,
            color: AppColor.secondaryColor.withValues(alpha: 0.82),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton(
              onPressed: () async {
                await LocalStoreService.saveWeeklyRating(true);
                if (mounted) setState(() {});
              },
              child: const Text('👍'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () async {
                await LocalStoreService.saveWeeklyRating(false);
                if (mounted) setState(() {});
              },
              child: const Text('👎'),
            ),
          ],
        ),
      ],
    );
  }

  String _shortReason(String reason) {
    final firstSentence = reason.split('.').first.trim();
    final clean = firstSentence.isEmpty ? reason.trim() : '$firstSentence.';
    const maxLen = 84;
    if (clean.length <= maxLen) return clean;
    return '${clean.substring(0, maxLen - 1).trimRight()}…';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  final List<int> dailySteps;
  final int targetSteps;

  const _WeeklyBars({required this.dailySteps, required this.targetSteps});

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxValue = [
      ...dailySteps,
      targetSteps,
    ].reduce((a, b) => a > b ? a : b);
    final targetRatio =
        maxValue == 0 ? 0.0 : (targetSteps / maxValue).clamp(0.0, 1.0);
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Align(
                alignment: Alignment(0, 1 - (targetRatio * 2)),
                child: Container(
                  height: 1,
                  color: AppColor.accentTeal.withValues(alpha: 0.45),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = dailySteps[index];
                  final ratio =
                      maxValue == 0
                          ? 0.0
                          : (value / maxValue).clamp(0.0, 1.0);
                  final isToday = index == todayIndex;
                  final isComplete = value >= targetSteps;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: FractionallySizedBox(
                        heightFactor: ratio == 0 ? 0.04 : ratio,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isComplete
                                    ? AppColor.accentTeal.withValues(alpha: 0.75)
                                    : isToday
                                    ? AppColor.primaryTextColor.withValues(
                                      alpha: 0.88,
                                    )
                                    : AppColor.primaryTextColor.withValues(
                                      alpha: 0.26,
                                    ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            7,
            (index) => Expanded(
              child: Center(
                child: Text(
                  days[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColor.secondaryColor.withValues(
                      alpha: index == todayIndex ? 0.9 : 0.55,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
