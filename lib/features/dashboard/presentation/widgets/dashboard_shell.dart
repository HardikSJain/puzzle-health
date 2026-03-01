import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../routes/routes_constants.dart';

/// Dashboard Shell - bottom navigation wrapper
/// Tabs order: Home -> Signals(Data) -> History
class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _GlassBottomNav(
          selectedIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.endsWith(RoutesConstants.home)) return 0;
    if (location.endsWith(RoutesConstants.data)) return 1;
    if (location.endsWith(RoutesConstants.history)) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.home}');
        break;
      case 1:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.data}');
        break;
      case 2:
        context.go('${RoutesConstants.dashboard}/${RoutesConstants.history}');
        break;
    }
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColor.cardColor.withValues(alpha: 0.56),
            border: Border.all(
              color: AppColor.primaryTextColor.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: [
              _NavItem(
                index: 0,
                selectedIndex: selectedIndex,
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                selectedIndex: selectedIndex,
                label: 'Signals',
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights_rounded,
                onTap: onTap,
              ),
              _NavItem(
                index: 2,
                selectedIndex: selectedIndex,
                label: 'History',
                icon: Icons.history_outlined,
                activeIcon: Icons.history_rounded,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColor.primaryTextColor.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 20,
                    color: isSelected
                        ? AppColor.primaryTextColor
                        : AppColor.primaryTextColor.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColor.primaryTextColor
                        : AppColor.primaryTextColor.withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
