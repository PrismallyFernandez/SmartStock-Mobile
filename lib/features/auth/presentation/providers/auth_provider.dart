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

  List<AppUser> _users = [];
  bool _usersLoading = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isChecking => _status == AuthStatus.checking;

  List<AppUser> get users => _users;
  bool get usersLoading => _usersLoading;

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

  Future<void> loadUsers() async {
    _usersLoading = true;
    notifyListeners();
    try {
      _users = await _repository.getUsers();
    } catch (_) {
      _users = [];
    }
    _usersLoading = false;
    notifyListeners();
  }

  /// Crea un usuario nuevo. La sesion del admin se cierra tras la creacion
  /// (limitacion del SDK cliente de Firebase). Devuelve un mensaje de exito o
  /// null si hubo error.
  Future<String?> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      await _repository.createUser(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      // El SDK cliente inicio sesion con el nuevo usuario; cerramos sesion
      // para que el admin vuelva a iniciar sesion.
      await logout();
      return null;
    } on InvalidCredentialsException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo crear el usuario.';
    }
  }
}
