import 'package:flutter/material.dart';

import '../../../dashboard/presentation/widgets/dashboard_shell.dart';
import '../../../../core/models/current_focus.dart';
import '../../../../core/models/fitness_state.dart';
import '../../../../core/services/local_store_service.dart';
import '../../../../core/services/progress_service.dart';
import '../../../../core/services/weekly_cycle_service.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../core/widgets/glass_surface.dart';

/// Home Page - Command center
/// Primary question: What should I do today, and how close am I?
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  CurrentFocus? _focus;
  WeekProgress? _progress;
  bool _loading = true;
  bool _heroEntered = false;
  late final AnimationController _gradientController;
  late final Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _gradientAnimation = Tween<double>(begin: -1.2, end: 0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeOutCubic),
    );
    _load();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final focus = await WeeklyCycleService.initializeOrRefresh();
    final progress = await ProgressService.getWeekProgress(focus);

    if (!mounted) return;
    _gradientController.reset();
    setState(() {
      _focus = focus;
      _progress = progress;
      _loading = false;
      _heroEntered = false;
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _heroEntered = true);
      _gradientController.forward();
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
    final isRunGoal = focus.goalType == 'run_frequency';

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, DashboardShell.bottomInsetForContent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommandHero(
                  progress,
                  remainingToday,
                  isRunGoal: isRunGoal,
                  targetRunsPerWeek: focus.targetRunsPerWeek,
                  heroEntered: _heroEntered,
                ),
                const SizedBox(height: 24),
                _buildWeeklyGoalBlock(focus),
                const SizedBox(height: 10),
                _buildPathwayPeek(focus),
                const SizedBox(height: 10),
                _buildGoalChangeCard(focus),
                const SizedBox(height: 18),
                _buildWeeklyChart(progress, isRunGoal: isRunGoal),
                const SizedBox(height: 20),
                _buildWeekStatus(progress, isRunGoal: isRunGoal),
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

  Widget _buildCommandHero(
    WeekProgress progress,
    int remainingToday, {
    required bool isRunGoal,
    required int? targetRunsPerWeek,
    required bool heroEntered,
  }) {
    final progressRatio = isRunGoal
        ? ((progress.runsCompleted) / ((targetRunsPerWeek ?? 2).clamp(1, 7)))
              .clamp(0.0, 1.0)
        : progress.targetSteps == 0
        ? 0.0
        : (progress.todaySteps / progress.targetSteps).clamp(0.0, 1.0);

    final subtitle = isRunGoal
        ? (progress.runsCompleted >= (targetRunsPerWeek ?? 2)
              ? 'Weekly run goal complete.'
              : '${(targetRunsPerWeek ?? 2) - progress.runsCompleted} runs to go this week.')
        : (progress.isOnTrackToday
              ? 'Today complete.'
              : '${_formatNumber(remainingToday)} steps to go today.');

    return AnimatedSlide(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      offset: heroEntered ? Offset.zero : const Offset(-0.06, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 520),
        opacity: heroEntered ? 1 : 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.cardColor.withValues(alpha: 0.9),
                      AppColor.cardColor.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _gradientAnimation,
                builder: (context, child) {
                  final value = heroEntered ? _gradientAnimation.value : -1.2;
                  return Positioned.fill(
                    child: FractionalTranslation(
                      translation: Offset(value, 0),
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(-0.4, 0),
                              radius: 1.5,
                              colors: [
                                AppColor.accentTeal.withValues(alpha: 0.32),
                                AppColor.accentTeal.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryTextColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primaryTextColor.withValues(
                                alpha: 0.92,
                              ),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRunGoal
                          ? '${progress.runsCompleted} / ${targetRunsPerWeek ?? 2} runs this week'
                          : '${_formatNumber(progress.todaySteps)} / ${_formatNumber(progress.targetSteps)} steps',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryTextColor,
                        letterSpacing: -0.7,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: progressRatio,
                        backgroundColor: AppColor.primaryTextColor.withValues(
                          alpha: 0.15,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress.isOnTrackToday
                              ? AppColor.accentTeal
                              : AppColor.primaryTextColor.withValues(
                                  alpha: 0.9,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.primaryTextColor.withValues(
                          alpha: 0.82,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyGoalBlock(CurrentFocus focus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          focus.goalType == 'run_frequency'
              ? 'Goal: ${focus.targetRunsPerWeek ?? 2} runs this week'
              : 'Goal: ${_formatNumber(focus.targetSteps)} steps daily this week',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryTextColor,
            letterSpacing: -0.35,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 2),
        Text(
          focus.fitnessState.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.accentTeal.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 6),
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

  Widget _buildPathwayPeek(CurrentFocus focus) {
    final pathway = focus.pathway;
    if (pathway == null) return const SizedBox.shrink();

    return GlassSurface(
      radius: 10,
      alpha: 0.035,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next unlock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pathway.next,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.primaryTextColor.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalChangeCard(CurrentFocus focus) {
    final summary = focus.changeSummary;
    if (summary == null || summary.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassSurface(
      radius: 10,
      alpha: 0.035,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why this goal changed',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.primaryTextColor.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(WeekProgress progress, {required bool isRunGoal}) {
    return GlassSurface(
      radius: 12,
      alpha: 0.04,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: isRunGoal
                ? _WeeklyRunBars(
                    dailyRuns: progress.dailyRuns,
                    targetRunsPerWeek: progress.targetRunsPerWeek,
                  )
                : _WeeklyBars(
                    dailySteps: progress.dailySteps,
                    targetSteps: progress.targetSteps,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStatus(WeekProgress progress, {required bool isRunGoal}) {
    return Text(
      isRunGoal
          ? '${progress.runsCompleted}/${progress.targetRunsPerWeek} runs complete'
          : '${progress.daysCompleted}/7 days on target',
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
            ? 'Saved: goal felt right this week.'
            : 'Saved: goal felt off this week.',
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
          'Was this goal right for you this week?',
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

class _WeeklyRunBars extends StatelessWidget {
  final List<int> dailyRuns;
  final int targetRunsPerWeek;

  const _WeeklyRunBars({
    required this.dailyRuns,
    required this.targetRunsPerWeek,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final runs = dailyRuns[index];
              final ratio = runs > 0 ? 1.0 : 0.1;
              final isToday = index == todayIndex;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FractionallySizedBox(
                    heightFactor: ratio,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: runs > 0
                            ? AppColor.accentTeal.withValues(alpha: 0.75)
                            : isToday
                            ? AppColor.primaryTextColor.withValues(alpha: 0.32)
                            : AppColor.primaryTextColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              );
            }),
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
    final targetRatio = maxValue == 0
        ? 0.0
        : (targetSteps / maxValue).clamp(0.0, 1.0);
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
                  final ratio = maxValue == 0
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
                            color: isComplete
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
