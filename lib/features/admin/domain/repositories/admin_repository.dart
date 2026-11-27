import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/domain/entities/system_settings.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

abstract class AdminRepository {
  Future<List<ManagedAccount>> getAccounts();
  Future<ManagedAccount> createAccount({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
  });
  Future<ManagedAccount> updateAccountRole(String accountId, UserRole newRole);
  Future<ManagedAccount> updateAccountStatus(String accountId, bool isActive);

  Future<SystemSettings> getSystemSettings();
  Future<SystemSettings> updateSystemSettings(SystemSettings settings);
}
