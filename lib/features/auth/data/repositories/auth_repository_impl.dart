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
}
