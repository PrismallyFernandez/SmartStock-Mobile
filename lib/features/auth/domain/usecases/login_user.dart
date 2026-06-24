import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: iniciar sesion (RF-01, RF-02, RF-03).
class LoginUser {
  LoginUser(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
