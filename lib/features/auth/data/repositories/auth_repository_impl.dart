import 'package:hris_apps/features/auth/domain/entities/user_entity.dart';
import 'package:hris_apps/features/auth/domain/repositories/auth_repository.dart';
import 'package:hris_apps/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> signIn({required String email, required String password}) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;
}
