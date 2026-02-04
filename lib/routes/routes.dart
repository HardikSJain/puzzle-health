import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/shared_preference/shared_preference_keys.dart';
import '../core/shared_preference/shared_preference_manager.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/widgets/dashboard_shell.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/onboarding_health_permission_page.dart';
import '../features/onboarding/presentation/pages/onboarding_magic_page.dart';
import '../features/onboarding/presentation/pages/onboarding_reveal_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'routes_constants.dart';

// ============================================================================
// APP ROUTER
// ============================================================================
// Flow:
// 1. First launch → Onboarding
// 2. After onboarding → Login (skippable based on flag)
// 3. After login/skip → Dashboard/Home
// ============================================================================

class AppRouter {
  AppRouter._();

  // ---- Configuration ----
  /// Set to false to make login mandatory (no skip button)
  static const bool isLoginSkippable = true;

  // ---- State Getters ----
  /// Check if onboarding is completed
  static bool get isOnboardingCompleted =>
      SharedPreferenceManager.getBool(
        SharedPreferenceKeys.onboardingCompleted,
      ) ??
      false;

  /// Check if user has seen login (skipped or logged in)
  static bool get hasSeenLogin =>
      SharedPreferenceManager.getBool(SharedPreferenceKeys.hasSeenLogin) ??
      false;

  /// Check if user is actually logged in
  static bool get isLoggedIn =>
      SharedPreferenceManager.getBool(SharedPreferenceKeys.isLoggedIn) ?? false;

  // ---- State Setters ----
  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    await SharedPreferenceManager.setBool(
      SharedPreferenceKeys.onboardingCompleted,
      true,
    );
  }

  /// Mark login as seen (either logged in or skipped)
  static Future<void> markLoginSeen() async {
    await SharedPreferenceManager.setBool(
      SharedPreferenceKeys.hasSeenLogin,
      true,
    );
  }

  /// Mark user as logged in
  static Future<void> setLoggedIn(bool value) async {
    await SharedPreferenceManager.setBool(
      SharedPreferenceKeys.isLoggedIn,
      value,
    );
    if (value) await markLoginSeen();
  }

  // ---- Router ----
  /// Get initial location based on app state
  static String get initialLocation {
    if (!isOnboardingCompleted) {
      return RoutesConstants.onboarding;
    }
    // If login is mandatory and user is not logged in, always show login
    if (!isLoginSkippable && !isLoggedIn) {
      return RoutesConstants.login;
    }
    // If login is skippable, only show login if not seen before
    if (isLoginSkippable && !hasSeenLogin) {
      return RoutesConstants.login;
    }
    return '${RoutesConstants.dashboard}/${RoutesConstants.home}';
  }

  /// Create GoRouter instance
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: initialLocation,
      debugLogDiagnostics: true,
      routes: _routes,
      redirect: _redirect,
    );
  }

  /// Global redirect logic
  static String? _redirect(BuildContext context, GoRouterState state) {
    final currentPath = state.matchedLocation;

    // Check if current path is part of onboarding flow
    final isOnboardingRoute = currentPath.startsWith('/onboarding');

    // If onboarding not completed, allow navigation within onboarding flow
    if (!isOnboardingCompleted) {
      // If trying to access non-onboarding route, redirect to start of onboarding
      if (!isOnboardingRoute) {
        return RoutesConstants.onboarding;
      }
      // Allow navigation within onboarding flow
      return null;
    }

    // If onboarding is completed but user is on an onboarding route, redirect to home
    if (isOnboardingCompleted && isOnboardingRoute) {
      return '${RoutesConstants.dashboard}/${RoutesConstants.home}';
    }

    // If login is mandatory and user is not logged in, force login
    if (isOnboardingCompleted &&
        !isLoginSkippable &&
        !isLoggedIn &&
        currentPath != RoutesConstants.login) {
      return RoutesConstants.login;
    }

    // If login is skippable, only force login if not seen before
    if (isOnboardingCompleted &&
        isLoginSkippable &&
        !hasSeenLogin &&
        currentPath != RoutesConstants.login) {
      return RoutesConstants.login;
    }

    // Redirect bare /dashboard to /dashboard/home
    if (currentPath == RoutesConstants.dashboard) {
      return '${RoutesConstants.dashboard}/${RoutesConstants.home}';
    }

    return null; // No redirect needed
  }

  /// Route definitions
  static final List<RouteBase> _routes = [
    // ---- Onboarding Flow (3 screens) ----
    GoRoute(
      path: RoutesConstants.onboarding,
      builder: (context, state) => const OnboardingRevealPage(),
    ),
    GoRoute(
      path: RoutesConstants.onboardingHealthPermission,
      builder: (context, state) => const OnboardingHealthPermissionPage(),
    ),
    GoRoute(
      path: RoutesConstants.onboardingMagic,
      builder: (context, state) => const OnboardingMagicPage(),
    ),

    // ---- Login ----
    GoRoute(
      path: RoutesConstants.login,
      builder: (context, state) => const LoginPage(),
    ),

    // ---- Dashboard Shell (with bottom navigation) ----
    ShellRoute(
      builder: (context, state, child) => DashboardShell(child: child),
      routes: [
        GoRoute(
          path: '${RoutesConstants.dashboard}/${RoutesConstants.home}',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '${RoutesConstants.dashboard}/${RoutesConstants.profile}',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '${RoutesConstants.dashboard}/${RoutesConstants.settings}',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ];
}
