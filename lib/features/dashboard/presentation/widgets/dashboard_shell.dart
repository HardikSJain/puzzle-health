import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes_constants.dart';

/// Dashboard Shell - Contains bottom navigation and renders child pages
class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.endsWith(RoutesConstants.home)) return 0;
    if (location.endsWith(RoutesConstants.profile)) return 1;
    if (location.endsWith(RoutesConstants.settings)) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.home}');
        break;
      case 1:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.profile}');
        break;
      case 2:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.settings}');
        break;
    }
  }
}
