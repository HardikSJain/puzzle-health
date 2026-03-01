abstract class SharedPreferenceKeys {
  static const String fcmToken = 'fcmToken';
  static const String firstLogin = 'firstLogin';
  static const String pendingDeepLink = 'pending_deep_link';
  static const String accessToken = 'accessToken';

  // ---- App Flow ----
  static const String onboardingCompleted = 'onboarding_completed';
  static const String hasSeenLogin = 'has_seen_login';
  static const String isLoggedIn = 'is_logged_in';

  // ---- MVP Local Intelligence ----
  static const String latestBaseline = 'latest_baseline';
  static const String activeWeeklyFocus = 'active_weekly_focus';
  static const String weeklyFocusHistory = 'weekly_focus_history';
  static const String weeklyGoalRatedGood = 'weekly_goal_rated_good';
}
