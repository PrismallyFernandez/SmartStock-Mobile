import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) {
    return _dataSource.login(email, password);
  }

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<AppUser?> currentUser() => _dataSource.currentUser();

  @override
  Future<List<AppUser>> getUsers() => _dataSource.getUsers();

  @override
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) {
    return _dataSource.createUser(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }
}
