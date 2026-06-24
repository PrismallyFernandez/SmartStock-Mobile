// Prueba de la pantalla de login con un repositorio de autenticacion falso
// (sin Firebase). Verifica el render y la validacion del formulario.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smartstock_mobile/core/theme/app_theme.dart';
import 'package:smartstock_mobile/features/auth/domain/entities/app_user.dart';
import 'package:smartstock_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:smartstock_mobile/features/auth/domain/usecases/login_user.dart';
import 'package:smartstock_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:smartstock_mobile/features/auth/presentation/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AppUser> login({required String email, required String password}) async {
    return const AppUser(
      id: 'u1',
      name: 'Demo',
      email: 'demo@x.com',
      role: UserRole.administrador,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser?> currentUser() async => null;
}

void main() {
  Widget buildSubject() {
    final repo = _FakeAuthRepository();
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(loginUser: LoginUser(repo), repository: repo),
      child: MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );
  }

  testWidgets('Muestra el login con sus campos', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });

  testWidgets('Valida campos vacios al enviar', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesion'));
    await tester.pump();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contrasena'), findsOneWidget);
  });
}
