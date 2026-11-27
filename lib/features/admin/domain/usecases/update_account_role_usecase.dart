import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/domain/repositories/admin_repository.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class UpdateAccountRoleUseCase {
  final AdminRepository repository;
  UpdateAccountRoleUseCase(this.repository);

  Future<ManagedAccount> call(String accountId, UserRole newRole) {
    return repository.updateAccountRole(accountId, newRole);
  }
}
