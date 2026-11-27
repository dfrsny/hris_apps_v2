import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/domain/repositories/admin_repository.dart';

class GetAccountsUseCase {
  final AdminRepository repository;
  GetAccountsUseCase(this.repository);

  Future<List<ManagedAccount>> call() => repository.getAccounts();
}
