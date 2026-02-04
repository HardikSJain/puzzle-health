import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../routes/routes_constants.dart';

/// Screen 1: The Reveal - Animated storytelling with puzzle metaphor
class OnboardingRevealPage extends StatefulWidget {
  const OnboardingRevealPage({super.key});

  @override
  State<OnboardingRevealPage> createState() => _OnboardingRevealPageState();
}

class _OnboardingRevealPageState extends State<OnboardingRevealPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showButton = false;
  bool _hasTriggeredHaptic = false;

  // Single accent color
  static const Color _accentColor = AppColor.successColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..addListener(_onAnimationUpdate);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  void _onAnimationUpdate() {
    final progress = _controller.value;

    if (progress >= 0.75 && !_hasTriggeredHaptic) {
      _hasTriggeredHaptic = true;
      HapticFeedback.mediumImpact();
    }

    if (progress >= 0.85 && !_showButton) {
      setState(() => _showButton = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getCurrentPhase() {
    final progress = _controller.value;
    if (progress < 0.25) return 0;
    if (progress < 0.50) return 1;
    if (progress < 0.75) return 2;
    return 3;
  }

  Widget _buildStyledText(BuildContext context) {
    final theme = Theme.of(context);
    final phase = _getCurrentPhase();

    final baseStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: -0.5,
    );

    final accentStyle = baseStyle?.copyWith(
      color: _accentColor,
      fontWeight: FontWeight.w700,
    );

    List<InlineSpan> spans;

    switch (phase) {
      case 0:
        spans = [
          TextSpan(
            text: "We are drowning in information.\nWe are starving for ",
            style: baseStyle,
          ),
          TextSpan(text: "wisdom", style: accentStyle),
          TextSpan(text: ".", style: baseStyle),
        ];
        break;
      case 1:
        spans = [
          TextSpan(text: "Your health is a ", style: baseStyle),
          TextSpan(text: "puzzle", style: accentStyle),
          TextSpan(text: ".", style: baseStyle),
        ];
        break;
      case 2:
        spans = [
          TextSpan(
            text: "Most apps overwhelm you\nwith 100 goals at once.",
            style: baseStyle,
          ),
        ];
        break;
      default:
        spans = [
          TextSpan(text: "We give you ", style: baseStyle),
          TextSpan(text: "one", style: accentStyle),
          TextSpan(text: ".\nThe right one.", style: baseStyle),
        ];
    }

    return RichText(
      key: ValueKey(phase),
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOutCubic,
                          switchOutCurve: Curves.easeInOutCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0, 0.08),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: child,
                              ),
                            );
                          },
                          child: _buildStyledText(context),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Continue button
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: _showButton ? Offset.zero : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _showButton
                            ? () => context.go(
                                RoutesConstants.onboardingHealthPermission,
                              )
                            : null,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
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
