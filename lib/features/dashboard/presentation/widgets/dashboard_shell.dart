import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/color_theme/app_colors.dart';
import '../../../../routes/routes_constants.dart';

/// Dashboard Shell - bottom navigation wrapper
/// Tabs order: Home -> Signals(Data) -> History
///
/// Nav bar is a floating overlay; body is full screen so content can scroll
/// behind it. Use [DashboardShell.bottomInsetForContent] for scroll padding.
class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  /// Bottom padding to use in scroll views so the last content clears the
  /// floating nav bar when scrolled to end. Content can scroll behind the bar.
  static const double bottomInsetForContent = 100;

  static const Duration navAnimDuration = Duration(milliseconds: 300);
  static const Curve navAnimCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              minimum: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: RepaintBoundary(
                child: _GlassBottomNav(
                  selectedIndex: selectedIndex,
                  onTap: (index) => _onItemTapped(index, context),
                ),
              ),
            ),
          ),
        ],
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

/// Bottom nav container: glass bar with blur, shadow, and row of buttons.
/// Matches [BottomNavigationView]-style API (width, height, color, boxShadow, children).
class _BottomNavigationView extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final BoxShadow? boxShadow;
  final List<Widget> children;

  const _BottomNavigationView({
    required this.width,
    required this.height,
    required this.color,
    this.boxShadow,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const barRadius = 26.0;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, minHeight: height),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(barRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(barRadius),
                color: color,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
                boxShadow: boxShadow != null ? [boxShadow!] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single nav button: icon + title, selected state, tap and same-tab callback.
/// Smooth icon crossfade, animated text and pill.
class _BottomNavigationButton extends StatelessWidget {
  final Widget activeIcon;
  final Widget inactiveIcon;
  final int uniqueIndex;
  final String title;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onSameTabPressed;

  const _BottomNavigationButton({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.uniqueIndex,
    required this.title,
    required this.selectedIndex,
    required this.onTap,
    this.onSameTabPressed,
  });

  static const _animDuration = DashboardShell.navAnimDuration;
  static const _animCurve = DashboardShell.navAnimCurve;

  @override
  Widget build(BuildContext context) {
    final isSelected = uniqueIndex == selectedIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (!isSelected) {
              onTap(uniqueIndex);
            } else {
              onSameTabPressed?.call();
            }
          },
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withValues(alpha: 0.06),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: _animDuration,
            curve: _animCurve,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColor.accentTeal.withValues(alpha: 0.36),
                        AppColor.accentTeal.withValues(alpha: 0.16),
                      ],
                    )
                  : null,
              color: Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                SizedBox(
                  height: 26,
                  child: AnimatedSwitcher(
                    duration: DashboardShell.navAnimDuration
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<bool>(isSelected),
                      child: isSelected ? activeIcon : inactiveIcon,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: _animDuration,
                  curve: _animCurve,
                  style: TextStyle(
                    color: isSelected
                        ? AppColor.primaryTextColor
                        : AppColor.primaryTextColor.withValues(alpha: 0.52),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: isSelected ? 12 : 11,
                    letterSpacing: 0.2,
                  ),
                  child: Text(title),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BottomNavigationView(
      width: 340,
      height: 64,
      color: Colors.white.withValues(alpha: 0.08),
      boxShadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      children: [
        _BottomNavigationButton(
          uniqueIndex: 0,
          title: 'Home',
          activeIcon: const Icon(
            Icons.home_rounded,
            size: 24,
            color: AppColor.primaryTextColor,
          ),
          inactiveIcon: Icon(
            Icons.home_outlined,
            size: 24,
            color: AppColor.primaryTextColor.withValues(alpha: 0.5),
          ),
          selectedIndex: selectedIndex,
          onTap: onTap,
          onSameTabPressed: null,
        ),
        _BottomNavigationButton(
          uniqueIndex: 1,
          title: 'Signals',
          activeIcon: const Icon(
            Icons.insights_rounded,
            size: 24,
            color: AppColor.primaryTextColor,
          ),
          inactiveIcon: Icon(
            Icons.insights_outlined,
            size: 24,
            color: AppColor.primaryTextColor.withValues(alpha: 0.5),
          ),
          selectedIndex: selectedIndex,
          onTap: onTap,
          onSameTabPressed: null,
        ),
        _BottomNavigationButton(
          uniqueIndex: 2,
          title: 'History',
          activeIcon: const Icon(
            Icons.history_rounded,
            size: 24,
            color: AppColor.primaryTextColor,
          ),
          inactiveIcon: Icon(
            Icons.history_outlined,
            size: 24,
            color: AppColor.primaryTextColor.withValues(alpha: 0.5),
          ),
          selectedIndex: selectedIndex,
          onTap: onTap,
          onSameTabPressed: null,
        ),
      ],
    );
  }
}
