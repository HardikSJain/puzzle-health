import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/health_baseline.dart';
import '../../../../core/models/health_insight.dart';
import '../../../../core/services/insight_generator.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_constants.dart';

/// Clinical baseline assessment - neutral, factual presentation of health data
class OnboardingInsightsPage extends StatefulWidget {
  final HealthBaseline baseline;

  const OnboardingInsightsPage({super.key, required this.baseline});

  @override
  State<OnboardingInsightsPage> createState() => _OnboardingInsightsPageState();
}

class _OnboardingInsightsPageState extends State<OnboardingInsightsPage>
    with TickerProviderStateMixin {
  late final List<HealthInsight> _insights;

  late AnimationController _pageController;
  late AnimationController _ctaController;

  late List<Animation<double>> _insightAnimations;
  late List<Animation<double>> _insightScales;

  @override
  void initState() {
    super.initState();

    _insights = InsightGenerator.generateInsights(widget.baseline);

    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _pageController = AnimationController(
      duration: Duration(milliseconds: 1400 + (_insights.length * 180)),
      vsync: this,
    );

    _insightAnimations = List.generate(_insights.length, (index) {
      final start = 0.2 + (index * 0.15);
      final end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _insightScales = List.generate(_insights.length, (index) {
      final start = 0.2 + (index * 0.15);
      final end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(
          parent: _pageController,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    _ctaController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    HapticFeedback.lightImpact();
    _pageController.forward();

    await Future.delayed(
      Duration(milliseconds: 1000 + (_insights.length * 180)),
    );
    if (!mounted) return;
    _ctaController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    await AppRouter.completeOnboarding();
    if (mounted) {
      context.go('${RoutesConstants.dashboard}/${RoutesConstants.home}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: Stack(
        children: [
          // Background decorative elements - outside SafeArea for edge-to-edge
          _buildBackgroundElements(),

          // Content inside SafeArea
          SafeArea(
            child: Stack(
              children: [
                // Main content
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeroHeader()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildInsightItem(index),
                          childCount: _insights.length,
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating CTA
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFloatingCTA(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Subtle background elements - minimal visual noise
  Widget _buildBackgroundElements() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top right circle - heavily muted
            Positioned(
              top: -80,
              right: -60,
              child: Opacity(
                opacity: 0.015 * _pageController.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.accentTeal.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroHeader() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final headerProgress = Interval(
          0.0,
          0.35,
          curve: Curves.easeOut,
        ).transform(_pageController.value);

        return Opacity(
          opacity: headerProgress,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - headerProgress)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 56, 28, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clean header - minimal styling
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baseline',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryTextColor,
                          height: 1.1,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Text(
                        'Assessment',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryTextColor.withValues(
                            alpha: 0.5,
                          ),
                          height: 1.1,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightItem(int index) {
    final insight = _insights[index];

    return AnimatedBuilder(
      animation: _insightAnimations[index],
      builder: (context, child) {
        if (_insightAnimations[index].value > 0.5 &&
            _insightAnimations[index].value < 0.6) {
          HapticFeedback.selectionClick();
        }

        return Opacity(
          opacity: _insightAnimations[index].value,
          child: Transform.scale(
            scale: _insightScales[index].value,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 28, right: 28, bottom: 32),
              child: _buildInsightLayout(insight, index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightLayout(HealthInsight insight, int index) {
    // First insight (baseline) = neutral color, second (constraint) = accent
    final isConstraint = index == 1;
    final contentColor = isConstraint
        ? _getTypeColor(insight.type)
        : AppColor.primaryTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          insight.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: contentColor,
            letterSpacing: -0.6,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle - factual description
        Text(
          insight.subtitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColor.primaryTextColor.withValues(alpha: 0.7),
            height: 1.5,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCTA() {
    return AnimatedBuilder(
      animation: _ctaController,
      builder: (context, child) {
        return Opacity(
          opacity: _ctaController.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - _ctaController.value)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.backgroundColor.withValues(alpha: 0.0),
                    AppColor.backgroundColor.withValues(alpha: 0.8),
                    AppColor.backgroundColor,
                    AppColor.backgroundColor,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 48),
              child: AppButton(
                text: "Continue",
                onPressed: _ctaController.value > 0.8
                    ? _completeOnboarding
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return AppColor.accentTeal;
      case InsightType.honest:
        return AppColor.warningColor;
      case InsightType.curious:
        return AppColor.accentPurple;
      default:
        return AppColor.secondaryColor;
    }
  }
}
