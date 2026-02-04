import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../routes/routes_constants.dart';

/// Dashboard Shell - Contains bottom navigation and renders child pages
/// CRITICAL RULES:
/// - Never add badge counts to navigation items. Badges introduce urgency where none belongs.
/// - History and Data must remain visually dull - they are archival, not actionable.
/// - No hover effects, no highlights, no discoverable interactions on inactive tabs.
/// - Navigation should be immediate and functional, not theatrical.
class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          enableFeedback: false,
          backgroundColor: AppColor.backgroundColor,
          selectedItemColor: AppColor.primaryTextColor,
          unselectedItemColor:
              AppColor.primaryTextColor.withValues(alpha: 0.35),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Data',
          ),
        ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.endsWith(RoutesConstants.home)) return 0;
    if (location.endsWith(RoutesConstants.history)) return 1;
    if (location.endsWith(RoutesConstants.data)) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    // Use context.go() not context.push() - tabs are peers, not stack navigation
    // This ensures back button does not treat tabs as navigation history
    switch (index) {
      case 0:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.home}');
        break;
      case 1:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.history}');
        break;
      case 2:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.data}');
        break;
    }
  }
}
