import 'package:flutter/material.dart';

import '../../../../core/models/current_focus.dart';
import '../../../../core/models/fitness_state.dart';
import '../../../../core/models/user_fitness_profile.dart';
import '../../../../core/services/local_store_service.dart';
import '../../../../core/services/progress_service.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../dashboard/presentation/widgets/dashboard_shell.dart';

/// Data Page - Read-only rolling baselines
/// Confidence repair when users doubt the system
class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List<double> _adherence = [];
  bool _loadingTrend = true;

  @override
  void initState() {
    super.initState();
    _loadTrend();
  }

  Future<void> _loadTrend() async {
    final history = LocalStoreService.getFocusHistory();
    final active = LocalStoreService.getActiveFocus();

    final rates = history
        .where((h) => h.completionRate != null)
        .take(4)
        .map((h) => h.completionRate!)
        .toList()
        .reversed
        .toList();

    if (active != null) {
      final current = await ProgressService.getCompletionRate(active);
      rates.add(current);
    }

    if (!mounted) return;
    setState(() {
      _adherence = rates.take(4).toList();
      _loadingTrend = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseline = LocalStoreService.getBaseline();
    final focus = LocalStoreService.getActiveFocus();
    final profile = LocalStoreService.getFitnessProfile();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(
            28,
            32,
            28,
            DashboardShell.bottomInsetForContent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Signals',
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
                'How your goal is chosen',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondaryColor.withValues(alpha: 0.6),
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 32),
              _buildBaselineCard(
                'Baseline (30 days)',
                baseline != null
                    ? '${baseline.avgSteps.round()} steps/day'
                    : 'No baseline yet',
                'Average daily steps',
              ),
              const SizedBox(height: 16),
              _buildBaselineCard(
                'Current state',
                focus != null
                    ? focus.fitnessState.label
                    : _patternLabel(baseline?.activityPattern),
                focus != null
                    ? _shortReason(focus.reason)
                    : 'No active focus yet.',
              ),
              const SizedBox(height: 16),
              _buildPathwayCard(focus),
              const SizedBox(height: 16),
              _buildLastRunCard(profile),
              const SizedBox(height: 16),
              _buildTrendCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathwayCard(CurrentFocus? focus) {
    final pathway = focus?.pathway;
    return GlassSurface(
      radius: 12,
      alpha: 0.04,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pathway preview',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.5),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          if (pathway == null)
            Text(
              'Pathway appears after your first goal is generated.',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.primaryTextColor.withValues(alpha: 0.6),
              ),
            )
          else ...[
            _pathwayLine('Now', pathway.now),
            const SizedBox(height: 8),
            _pathwayLine('Next', pathway.next),
            const SizedBox(height: 8),
            _pathwayLine('Later', pathway.later),
          ],
        ],
      ),
    );
  }

  Widget _buildLastRunCard(UserFitnessProfile? profile) {
    final lastRun = profile?.lastRun;

    return GlassSurface(
      radius: 12,
      alpha: 0.04,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last run',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.5),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          if (lastRun == null)
            Text(
              'No running session detected yet.',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.primaryTextColor.withValues(alpha: 0.6),
              ),
            )
          else ...[
            _pathwayLine('When', _formatDate(lastRun.start)),
            const SizedBox(height: 6),
            _pathwayLine('Duration', '${lastRun.durationMinutes.round()} min'),
            if (lastRun.distanceMeters != null) ...[
              const SizedBox(height: 6),
              _pathwayLine(
                'Distance',
                '${(lastRun.distanceMeters! / 1000).toStringAsFixed(2)} km',
              ),
            ],
            if (lastRun.paceMinPerKm != null) ...[
              const SizedBox(height: 6),
              _pathwayLine('Pace', _formatPace(lastRun.paceMinPerKm!)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    final latest = _adherence.isNotEmpty
        ? (_adherence.last * 100).round()
        : null;

    return GlassSurface(
      radius: 12,
      alpha: 0.04,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4-week adherence',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.secondaryColor.withValues(alpha: 0.5),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingTrend)
            const SizedBox(
              height: 42,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_adherence.isEmpty)
            Text(
              'Not enough weekly data yet.',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.primaryTextColor.withValues(alpha: 0.6),
              ),
            )
          else
            SizedBox(
              height: 52,
              child: _AdherenceSparkline(values: _adherence),
            ),
          const SizedBox(height: 8),
          Text(
            latest != null ? 'This week: $latest% on target' : 'This week: n/a',
            style: TextStyle(
              fontSize: 14,
              color: AppColor.primaryTextColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pathwayLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: AppColor.primaryTextColor.withValues(alpha: 0.7),
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColor.primaryTextColor.withValues(alpha: 0.9),
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildBaselineCard(String label, String value, String subtitle) {
    return GlassSurface(
      radius: 12,
      alpha: 0.04,
      padding: const EdgeInsets.all(20),
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
            style: const TextStyle(
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

  String _shortReason(String reason) {
    final firstSentence = reason.split('.').first.trim();
    final clean = firstSentence.isEmpty ? reason.trim() : '$firstSentence.';
    const maxLen = 88;
    if (clean.length <= maxLen) return clean;
    return '${clean.substring(0, maxLen - 1).trimRight()}…';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPace(double minPerKm) {
    final minutes = minPerKm.floor();
    final seconds = ((minPerKm - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  String _patternLabel(String? pattern) {
    switch (pattern) {
      case 'weekday_only':
        return 'Weekday-focused';
      case 'weekend_warrior':
        return 'Weekend-heavy';
      case 'sporadic':
        return 'Inconsistent';
      case 'consistent':
        return 'Consistent';
      case 'building':
        return 'Building baseline';
      default:
        return 'Unknown';
    }
  }
}

class _AdherenceSparkline extends StatelessWidget {
  final List<double> values; // 0..1
  const _AdherenceSparkline({required this.values});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final ratio = values[index].clamp(0.0, 1.0);
        final isLatest = index == values.length - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: FractionallySizedBox(
              heightFactor: ratio == 0 ? 0.04 : ratio,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: isLatest
                      ? AppColor.accentTeal.withValues(alpha: 0.9)
                      : AppColor.primaryTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
