import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/domain/repositories/admin_repository.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class CreateAccountUseCase {
  final AdminRepository repository;
  CreateAccountUseCase(this.repository);

  Future<ManagedAccount> call({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return repository.createAccount(
      displayName: displayName,
      email: email,
      password: password,
      role: role,
    );
  }
}
