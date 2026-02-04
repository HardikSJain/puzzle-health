import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/health_service.dart';
import '../../../../routes/routes_constants.dart';

/// Screen: Health Permission Request
/// Shows Apple Health on iOS, Google Fit on Android
class OnboardingHealthPermissionPage extends StatefulWidget {
  const OnboardingHealthPermissionPage({super.key});

  @override
  State<OnboardingHealthPermissionPage> createState() =>
      _OnboardingHealthPermissionPageState();
}

class _OnboardingHealthPermissionPageState
    extends State<OnboardingHealthPermissionPage> {
  bool _isRequesting = false;

  bool get _isIOS => Platform.isIOS;

  String get _platformName => _isIOS ? 'Apple Health' : 'Google Fit';

  IconData get _platformIcon =>
      _isIOS ? Icons.favorite_rounded : Icons.fitness_center_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  _platformIcon,
                  size: 44,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Connect $_platformName',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 16),

              // Body
              Text(
                'We need access to your activity data to understand your baseline and set the right goal for you.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 40),

              // What we access
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildAccessItem(
                      context,
                      icon: Icons.directions_walk_rounded,
                      label: 'Steps',
                    ),
                    const SizedBox(height: 12),
                    _buildAccessItem(
                      context,
                      icon: Icons.straighten_rounded,
                      label: 'Distance',
                    ),
                    const SizedBox(height: 12),
                    _buildAccessItem(
                      context,
                      icon: Icons.local_fire_department_rounded,
                      label: 'Active calories',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const Spacer(flex: 3),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isRequesting ? null : _requestPermission,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isRequesting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          'Connect $_platformName',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Reassurance
              Text(
                'We only read activity data.\nWe never share or sell your health information.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: colorScheme.primary.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    try {
      final granted = await HealthService.requestPermission();

      if (!mounted) return;

      if (granted) {
        // Permission granted, proceed to magic page
        context.go(RoutesConstants.onboardingMagic);
      } else {
        // Permission denied, show dialog but still allow to proceed
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      if (!mounted) return;
      _showPermissionDeniedDialog();
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          'We need access to $_platformName to set your personalized goal. You can enable it later in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Try Again'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Allow user to continue anyway (will use dummy data)
              context.go(RoutesConstants.onboardingMagic);
            },
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }
}
