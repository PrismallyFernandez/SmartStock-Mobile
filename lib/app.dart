import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_logo.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/main_shell.dart';

class SmartStockApp extends StatelessWidget {
  const SmartStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ServiceLocator.providers(),
      child: MaterialApp(
        title: 'SmartStock Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Decide la pantalla inicial segun el estado de autenticacion.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((p) => p.status);

    switch (status) {
      case AuthStatus.checking:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const MainShell();
      case AuthStatus.unauthenticated:
      case AuthStatus.loading:
        return const LoginPage();
    }
  }
}

/// Pantalla breve mientras se verifica si hay una sesion activa.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 72),
            SizedBox(height: 24),
            SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
