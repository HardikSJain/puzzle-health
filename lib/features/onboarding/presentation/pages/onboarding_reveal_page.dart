import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../routes/routes_constants.dart';

/// Screen 1: The Reveal - Clean dictionary style
class OnboardingRevealPage extends StatefulWidget {
  const OnboardingRevealPage({super.key});

  @override
  State<OnboardingRevealPage> createState() => _OnboardingRevealPageState();
}

class _OnboardingRevealPageState extends State<OnboardingRevealPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _contentFade;
  late Animation<double> _twistFade;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _twistFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _controller.forward();

    // Single haptic when twist reveals
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2), // More breathing room at top
                  // Word + noun - tighter baseline alignment
                  Opacity(
                    opacity: _contentFade.value,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Puzzle',
                          style: TextStyle(
                            fontSize: 52, // Slightly larger
                            fontWeight: FontWeight.w700,
                            color: AppColor.primaryTextColor,
                            letterSpacing: -1.2,
                            height: 1.0, // Tighter line height
                          ),
                        ),
                        const SizedBox(width: 12), // Tighter
                        Text(
                          'noun',
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: AppColor.secondaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6), // Tighter to pronunciation
                  // Pronunciation
                  Opacity(
                    opacity: _contentFade.value * 0.7,
                    child: const Text(
                      '/ˈpʌz(ə)l/',
                      style: TextStyle(
                        fontSize: 16, // Slightly larger
                        color: AppColor.secondaryColor,
                        letterSpacing: 0.5, // Less spaced
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 36,
                  ), // More separation before definition
                  // Definition
                  Opacity(
                    opacity: _contentFade.value,
                    child: const Text(
                      'a problem designed to test ingenuity.',
                      style: TextStyle(
                        fontSize: 22, // Slightly larger
                        fontWeight: FontWeight.w400,
                        color: AppColor.primaryTextColor,
                        height: 1.45, // Better readability
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // Balanced spacing
                  // The twist
                  Opacity(
                    opacity: _twistFade.value,
                    child: Container(
                      padding: const EdgeInsets.only(left: 4), // Slight indent
                      child: Text(
                        '* your health doesn\'t have to be one',
                        style: TextStyle(
                          fontSize: 18, // Slightly larger
                          fontWeight: FontWeight.w500,
                          color: AppColor.accentTeal,
                          height: 1.4,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Button
                  Opacity(
                    opacity: _buttonFade.value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: AppButton(
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _buttonFade.value > 0.9
                            ? () => context.go(
                                RoutesConstants.onboardingHealthPermission,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
