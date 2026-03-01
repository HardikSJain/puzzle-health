import 'package:flutter/material.dart';

import '../../../../core/models/current_focus.dart';
import '../../../../core/services/local_store_service.dart';
import '../../../../core/services/progress_service.dart';
import '../../../../core/services/weekly_cycle_service.dart';
import '../../../../core/theme/color_theme/app_colors.dart';

/// Home Page - The decision surface
/// Answers: What am I supposed to do right now, and am I on track?
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
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final focus = _focus!;
    final progress = _progress!;

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // The Focus - one weekly action
                Text(
                  '${_formatNumber(focus.targetSteps)} steps every day this week.',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryTextColor,
                    height: 1.2,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 16),

                // Justification
                Text(
                  _shortReason(focus.reason),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColor.primaryTextColor.withValues(alpha: 0.5),
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),

                const SizedBox(height: 36),

                Text(
                  '${progress.daysCompleted} of ${progress.totalDays} days completed',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryTextColor,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 18),

                _buildWeeklyChart(progress),

                const SizedBox(height: 24),

                _buildTodayRelevance(progress),

                const SizedBox(height: 32),

                _buildRatingPrompt(),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(WeekProgress progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: AppColor.primaryTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.7),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: _WeeklyBars(
              dailySteps: progress.dailySteps,
              targetSteps: progress.targetSteps,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRelevance(WeekProgress progress) {
    final todayStatus = progress.isOnTrackToday
        ? 'Today complete.'
        : 'Today counts if you reach ${_formatNumber(progress.targetSteps)} steps.';

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
              color: progress.isOnTrackToday
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
                  '$todayStatus (${_formatNumber(progress.todaySteps)} steps)',
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

  Widget _buildRatingPrompt() {
    final rating = LocalStoreService.getWeeklyRating();
    if (rating != null) {
      return Text(
        rating
            ? 'You marked this goal as a good fit.'
            : 'You marked this goal as not a fit.',
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
          'Is this week\'s goal right for you?',
          style: TextStyle(
            fontSize: 14,
            color: AppColor.secondaryColor.withValues(alpha: 0.8),
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
    const maxLen = 88;
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
    final maxValue = [...dailySteps, targetSteps].reduce((a, b) => a > b ? a : b);
    final targetRatio = maxValue == 0 ? 0.0 : (targetSteps / maxValue).clamp(0.0, 1.0);
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
                  color: AppColor.accentTeal.withValues(alpha: 0.5),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = dailySteps[index];
                  final ratio = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
                  final isToday = index == todayIndex;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: FractionallySizedBox(
                        heightFactor: ratio == 0 ? 0.04 : ratio,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColor.primaryTextColor.withValues(alpha: 0.9)
                                : AppColor.primaryTextColor.withValues(alpha: 0.28),
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
                    color: AppColor.secondaryColor.withValues(alpha: index == todayIndex ? 0.9 : 0.55),
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
