import '../entities/app_user.dart';

/// Contrato de autenticacion. La implementacion concreta (local hoy, Firebase
/// Authentication despues) vive en la capa de datos.
abstract class AuthRepository {
  /// Valida credenciales y devuelve el usuario autenticado.
  /// Lanza [InvalidCredentialsException] si no son validas.
  Future<AppUser> login({required String email, required String password});

  Future<void> logout();

  /// Devuelve el usuario con sesion activa, o null si no hay sesion.
  Future<AppUser?> currentUser();
}
