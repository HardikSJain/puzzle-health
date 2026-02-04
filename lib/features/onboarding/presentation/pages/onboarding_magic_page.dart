import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';

import '../../../../core/models/health_baseline.dart';
import '../../../../core/models/health_target.dart';
import '../../../../core/services/health_analyzer.dart';
import '../../../../core/services/health_service.dart';
import '../../../../core/shared_preference/shared_preference_keys.dart';
import '../../../../core/shared_preference/shared_preference_manager.dart';
import '../../../../routes/routes_constants.dart';

/// Screen 2: The Magic Moment - Real health data reveal
class OnboardingMagicPage extends StatefulWidget {
  const OnboardingMagicPage({super.key});

  @override
  State<OnboardingMagicPage> createState() => _OnboardingMagicPageState();
}

class _OnboardingMagicPageState extends State<OnboardingMagicPage> {
  final _logger = Logger();

  bool _isLoading = true;
  String _loadingStatus = "Let's see your puzzle...";
  HealthBaseline? _baseline;
  HealthTarget? _target;
  String? _insightMessage;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchAndAnalyze();
  }

  Future<void> _fetchAndAnalyze() async {
    try {
      await _updateStatus("Let's see your puzzle...", 600);

      // Request permission
      await _updateStatus("Connecting to your health data...", 400);
      final hasPermission = await HealthService.requestPermission();

      if (!hasPermission) {
        _handlePermissionDenied();
        return;
      }

      // Fetch data with status updates
      await _updateStatus("Reading your last 30 days...", 500);
      final stepData = await HealthService.fetchStepData(days: 30);

      if (stepData.isEmpty) {
        _logger.w('No step data found, using default baseline');
      }

      // Calculate total for display
      final totalSteps = stepData.fold<int>(0, (sum, data) => sum + data.steps);
      final validDays = stepData.where((d) => d.steps > 0).length;

      if (validDays > 0) {
        await _updateStatus("Found $validDays days of activity...", 600);
        await _updateStatus(
          "You moved ${_formatSteps(totalSteps)} steps...",
          700,
        );
      }

      await _updateStatus("Analyzing patterns...", 500);

      // Analyze baseline
      final baseline = HealthAnalyzer.calculateBaseline(stepData);
      final target = HealthAnalyzer.generateTarget(baseline);
      final insight = HealthAnalyzer.generateInsight(baseline);

      // Small delay for dramatic effect
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _isLoading = false;
        _baseline = baseline;
        _target = target;
        _insightMessage = insight;
      });
    } catch (e) {
      _logger.e('Error fetching and analyzing health data: $e');
      // Fall back to default baseline on error
      _handleError();
    }
  }

  Future<void> _updateStatus(String status, int delayMs) async {
    if (!mounted) return;
    setState(() => _loadingStatus = status);
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  void _handlePermissionDenied() {
    _logger.w('Health permission denied, showing fallback');
    setState(() {
      _permissionDenied = true;
      _isLoading = false;
    });
  }

  void _handleError() {
    // Use default baseline if there's an error
    final baseline = HealthAnalyzer.calculateBaseline([]);
    final target = HealthAnalyzer.generateTarget(baseline);
    final insight = "Let's start with a fresh baseline.";

    setState(() {
      _isLoading = false;
      _baseline = baseline;
      _target = target;
      _insightMessage = insight;
    });
  }

  String _formatSteps(int steps) {
    if (steps >= 1000000) {
      return '${(steps / 1000000).toStringAsFixed(1)}M';
    } else if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}K';
    }
    return steps.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return _buildPermissionDeniedState();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    return _buildResultsState();
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _loadingStatus,
                    key: ValueKey(_loadingStatus),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsState() {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // Header
                      Text(
                        "Here's what we learned:",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Baseline Card
                      _buildBaselineCard(theme),

                      const SizedBox(height: 20),

                      // Insight Message
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _insightMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Target Introduction
                      Text(
                        "So here's your next piece:",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Target Card
                      _buildTargetCard(theme),

                      const SizedBox(height: 48),

                      // Start Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _completeOnboarding,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Start tracking',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 700.ms, curve: Curves.easeOutCubic)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: 700.ms,
                    curve: Curves.easeOutCubic,
                  ),
        ),
      ),
    );
  }

  Widget _buildBaselineCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your typical day",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow(theme, "📊", "${_baseline!.avgSteps.round()} steps"),
          const SizedBox(height: 12),
          _buildStatRow(
            theme,
            "🚶",
            "${_baseline!.avgActiveMinutes} mins moving",
          ),
          const SizedBox(height: 12),
          _buildStatRow(theme, "📅", "${_baseline!.activeDays} days/week"),
        ],
      ),
    );
  }

  Widget _buildTargetCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("🎯", style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                "This Week",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "${_target!.targetSteps}",
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
              fontSize: 56,
              height: 1.0,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "steps per day",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Just ${_target!.incrementSteps} more than you already do",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, String emoji, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDeniedState() {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "No problem",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "We can work with estimates.\nLet's start with a simple baseline:",
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.primaryContainer.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("🎯", style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                "This Week",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "3,000",
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              fontSize: 56,
                              height: 1.0,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "steps per day",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Most people do 2-3K just living.\nThis adds one short walk.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _completeOnboarding,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _permissionDenied = false;
                        _isLoading = true;
                      });
                      _fetchAndAnalyze();
                    },
                    child: const Text('Try again with health data'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    await SharedPreferenceManager.setBool(
      SharedPreferenceKeys.onboardingCompleted,
      true,
    );
    await SharedPreferenceManager.setBool(
      SharedPreferenceKeys.hasSeenLogin,
      true,
    );

    if (!mounted) return;
    context.go('${RoutesConstants.dashboard}/${RoutesConstants.home}');
  }
}
