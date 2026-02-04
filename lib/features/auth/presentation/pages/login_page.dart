import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../../../../routes/routes_constants.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // TODO: Add actual login logic
                await AppRouter.setLoggedIn(true);
                if (context.mounted) {
                  context.go(
                    '${RoutesConstants.dashboard}/${RoutesConstants.home}',
                  );
                }
              },
              child: const Text('Login'),
            ),
            // Show skip button only if login is skippable
            if (AppRouter.isLoginSkippable) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  // Skip login (not logged in, but seen)
                  await AppRouter.markLoginSeen();
                  if (context.mounted) {
                    context.go(
                      '${RoutesConstants.dashboard}/${RoutesConstants.home}',
                    );
                  }
                },
                child: const Text('Skip'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
