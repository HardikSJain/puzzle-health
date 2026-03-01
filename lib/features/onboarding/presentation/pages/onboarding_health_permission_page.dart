import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:logger/logger.dart';

import '../../../../core/services/health_service.dart';
import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../routes/routes_constants.dart';

/// Screen: Health Permission Request - Clean minimal design
class OnboardingHealthPermissionPage extends StatefulWidget {
  const OnboardingHealthPermissionPage({super.key});

  @override
  State<OnboardingHealthPermissionPage> createState() =>
      _OnboardingHealthPermissionPageState();
}

class _OnboardingHealthPermissionPageState
    extends State<OnboardingHealthPermissionPage>
    with SingleTickerProviderStateMixin {
  bool _isRequesting = false;

  late AnimationController _controller;
  late Animation<double> _contentFade;
  late Animation<double> _buttonFade;

  final _logger = Logger();

  bool get _isIOS => Platform.isIOS;
  String get _platformName => _isIOS ? 'Apple Health' : 'Health Connect';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _controller.forward();
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
                  const Spacer(flex: 2),

                  // Title
                  Opacity(
                    opacity: _contentFade.value,
                    child: Text(
                      'Connect\n$_platformName',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryTextColor,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Simple explanation
                  Opacity(
                    opacity: _contentFade.value,
                    child: Text(
                      'To set your first goal, we need your recent health data.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondaryColor,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // What we read - simple text list
                  Opacity(
                    opacity: _contentFade.value,
                    child: Text(
                      'Steps · Heart Rate · Sleep · Weight & more',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColor.secondaryColor.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Button
                  Opacity(
                    opacity: _buttonFade.value,
                    child: AppButton(
                      text: 'Allow access',
                      onPressed: _requestPermission,
                      isLoading: _isRequesting,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reassurance - minimal
                  Opacity(
                    opacity: _buttonFade.value,
                    child: Center(
                      child: Text(
                        'Read-only. Stored on your device.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.secondaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    try {
      // Check if Health Connect is available on Android
      if (!_isIOS) {
        final status = await HealthService.getHealthConnectSdkStatus();
        _logger.i('Health Connect SDK status: $status');

        if (status == HealthConnectSdkStatus.sdkUnavailable) {
          if (!mounted) return;
          setState(() => _isRequesting = false);
          _showDeviceNotSupportedDialog();
          return;
        } else if (status ==
            HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          if (!mounted) return;
          setState(() => _isRequesting = false);
          _showHealthConnectNotInstalledDialog();
          return;
        }
      }

      // Request permissions for all health types using the new HealthService
      final granted = await HealthService.requestAllPermissions();
      _logger.i('Permissions granted: $granted');

      if (!mounted) return;

      if (granted) {
        // Fetch a quick sample to verify data access
        final now = DateTime.now();
        final healthData = await HealthService.fetchData(
          types: [HealthDataType.STEPS],
          startTime: now.subtract(const Duration(days: 1)),
          endTime: now,
        );
        _logger.i('Sample health data fetched: ${healthData.length} points');

        HapticFeedback.mediumImpact();
        if (mounted) {
          context.go(RoutesConstants.onboardingMagic);
        }
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
      if (!mounted) return;
      _showPermissionDeniedDialog();
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardColor,
        title: const Text(
          'Permission needed',
          style: TextStyle(color: AppColor.primaryTextColor),
        ),
        content: Text(
          _isIOS
              ? 'We need $_platformName access to set your goal. You can enable it later in Settings.'
              : 'Please open Health Connect and grant permissions to Puzzle Health manually.',
          style: const TextStyle(color: AppColor.secondaryColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RoutesConstants.onboardingMagic);
            },
            child: const Text('Skip for now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_isIOS) {
                _requestPermission(); // Try again on iOS
              } else {
                HealthService.installHealthConnect(); // Open Health Connect on Android
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColor.accentTeal),
            child: Text(_isIOS ? 'Try again' : 'Open Health Connect'),
          ),
        ],
      ),
    );
  }

  void _showHealthConnectNotInstalledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardColor,
        title: const Text(
          'Health Connect required',
          style: TextStyle(color: AppColor.primaryTextColor),
        ),
        content: const Text(
          'Please install "Health Connect" from the Play Store to continue.\n\nAfter installing, open Health Connect once to complete setup, then return here.',
          style: TextStyle(color: AppColor.secondaryColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RoutesConstants.onboardingMagic);
            },
            child: const Text('Skip for now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              HealthService.installHealthConnect();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColor.accentTeal),
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  void _showDeviceNotSupportedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardColor,
        title: const Text(
          'Device not supported',
          style: TextStyle(color: AppColor.primaryTextColor),
        ),
        content: const Text(
          'Your device doesn\'t support Health Connect. You can still use the app with sample data for now.',
          style: TextStyle(color: AppColor.secondaryColor, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RoutesConstants.onboardingMagic);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColor.accentTeal),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
