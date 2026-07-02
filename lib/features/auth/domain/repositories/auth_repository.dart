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

  /// Lista todos los usuarios registrados en Firestore.
  Future<List<AppUser>> getUsers();

  /// Crea un nuevo usuario con correo/contrasena y guarda su perfil en
  /// Firestore. La sesion actual se cierra tras la creacion (limitacion del
  /// cliente Firebase). Devuelve el [AppUser] creado.
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });
}
