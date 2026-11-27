import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/domain/repositories/admin_repository.dart';

class UpdateAccountStatusUseCase {
  final AdminRepository repository;
  UpdateAccountStatusUseCase(this.repository);

  Future<ManagedAccount> call(String accountId, bool isActive) {
    return repository.updateAccountStatus(accountId, isActive);
  }
}
