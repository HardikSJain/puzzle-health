import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/no_scroll_glow.dart';
import 'core/theme/app_theme.dart';
import 'routes/routes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  late final _router = AppRouter.createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return ScrollConfiguration(behavior: NoScrollGlow(), child: child!);
      },
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      routerConfig: _router,
    );
  }
}
