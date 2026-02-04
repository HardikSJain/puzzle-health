import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../../core/models/health_baseline.dart';
import '../../../../core/services/health_analyzer.dart';
import '../../../../core/services/health_service.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../routes/routes_constants.dart';

/// Analysis/Loading page - Shows step-by-step progress while fetching health data
class OnboardingMagicPage extends StatefulWidget {
  const OnboardingMagicPage({super.key});

  @override
  State<OnboardingMagicPage> createState() => _OnboardingMagicPageState();
}

class _OnboardingMagicPageState extends State<OnboardingMagicPage>
    with TickerProviderStateMixin {
  final _logger = Logger();

  // Analysis steps
  static const List<String> _steps = [
    'Connecting to Health...',
    'Fetching your last 30 days...',
    'Processing your data...',
    'Finding patterns...',
    'Almost there...',
  ];

  int _currentStep = 0;
  bool _isComplete = false;
  String? _errorMessage;
  HealthBaseline? _baseline;

  // Animation controllers
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _textOpacity;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Text fade animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Pulse animation for the dot
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnalysis();
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    _textController.forward();

    try {
      // Step 1: Connecting
      await _advanceStep(minDuration: 800);

      // Step 2: Fetching data
      await _advanceStep(minDuration: 500);
      final healthData = await HealthService.fetchLastNDays(days: 30);
      _logger.i('Fetched ${healthData.length} health data points');

      if (!mounted) return;

      // Step 3: Processing
      await _advanceStep(minDuration: 600);
      final uniqueData = HealthService.removeDuplicates(healthData);
      _logger.i('After deduplication: ${uniqueData.length} points');

      if (!mounted) return;

      // Step 4: Finding patterns
      await _advanceStep(minDuration: 800);
      final baseline = HealthAnalyzer.analyzeHealthData(uniqueData, days: 30);
      _logger.i('Baseline generated: ${baseline.avgSteps.round()} avg steps');

      if (!mounted) return;
      _baseline = baseline;

      // Step 5: Almost there
      await _advanceStep(minDuration: 600);

      // Complete!
      if (mounted) {
        setState(() => _isComplete = true);
        HapticFeedback.mediumImpact();

        // Brief pause to show completion, then navigate
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          _navigateToInsights();
        }
      }
    } catch (e) {
      _logger.e('Error during analysis: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  Future<void> _advanceStep({required int minDuration}) async {
    if (!mounted) return;

    // Fade out current text
    await _textController.reverse();

    if (!mounted) return;

    // Update step
    setState(() {
      _currentStep = (_currentStep + 1).clamp(0, _steps.length - 1);
    });

    // Fade in new text
    _textController.forward();

    // Ensure minimum duration for each step
    await Future.delayed(Duration(milliseconds: minDuration));
  }

  void _navigateToInsights() {
    context.go(
      RoutesConstants.onboardingInsights,
      extra: _baseline ?? HealthBaseline.defaultBaseline(),
    );
  }

  void _retry() {
    setState(() {
      _currentStep = 0;
      _errorMessage = null;
      _isComplete = false;
    });
    _startAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Main content
              if (_errorMessage != null)
                _buildErrorState()
              else
                _buildLoadingState(),

              const Spacer(flex: 3),

              // Progress indicator
              if (_errorMessage == null) _buildProgressIndicator(),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated pulsing dot
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColor.accentTeal.withOpacity(_pulseAnimation.value),
                shape: BoxShape.circle,
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Step text with fade animation
        AnimatedBuilder(
          animation: _textOpacity,
          builder: (context, child) {
            return Opacity(
              opacity: _textOpacity.value,
              child: Text(
                _isComplete ? 'Done.' : _steps[_currentStep],
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: _isComplete
                      ? AppColor.accentTeal
                      : AppColor.primaryTextColor,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Subtitle
        AnimatedOpacity(
          opacity: _isComplete ? 1.0 : 0.7,
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isComplete
                ? 'Let\'s see what we found.'
                : 'This will only take a moment.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: AppColor.secondaryColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: AppColor.errorColor.withOpacity(0.8),
        ),
        const SizedBox(height: 24),
        Text(
          'Oops.',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: AppColor.primaryTextColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage!,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColor.secondaryColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: _retry,
          style: TextButton.styleFrom(
            foregroundColor: AppColor.accentTeal,
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'Try again',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_steps.length, (index) {
        final isActive = index <= _currentStep;
        final isCurrent = index == _currentStep && !_isComplete;

        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index < _steps.length - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? (_isComplete ? AppColor.accentTeal : AppColor.primaryColor)
                  : AppColor.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: isCurrent
                ? AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(
                            _pulseAnimation.value,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      }),
    );
  }
}
