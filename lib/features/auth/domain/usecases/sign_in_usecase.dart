import 'package:hris_apps/features/auth/domain/entities/user_entity.dart';
import 'package:hris_apps/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<UserEntity> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}
