import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { checking, unauthenticated, loading, authenticated }

/// Estado de autenticacion para la capa de presentacion.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required LoginUser loginUser,
    required AuthRepository repository,
  }) : _loginUser = loginUser,
       _repository = repository;

  final LoginUser _loginUser;
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.checking;
  AppUser? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isChecking => _status == AuthStatus.checking;

  /// Restaura la sesion al iniciar la app (Firebase la mantiene persistida).
  Future<void> checkSession() async {
    try {
      _user = await _repository.currentUser();
      _status =
          _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _loginUser(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on InvalidCredentialsException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrio un error inesperado. Intenta de nuevo.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
