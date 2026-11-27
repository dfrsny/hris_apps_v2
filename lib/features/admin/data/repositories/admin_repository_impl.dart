import 'package:hris_apps/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:hris_apps/features/admin/data/models/system_settings_model.dart';
import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/domain/entities/system_settings.dart';
import 'package:hris_apps/features/admin/domain/repositories/admin_repository.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ManagedAccount>> getAccounts() {
    return remoteDataSource.fetchAccounts();
  }

  @override
  Future<ManagedAccount> createAccount({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return remoteDataSource.createAccount(
      displayName: displayName,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<ManagedAccount> updateAccountRole(String accountId, UserRole newRole) {
    return remoteDataSource.updateRole(accountId, newRole);
  }

  @override
  Future<ManagedAccount> updateAccountStatus(String accountId, bool isActive) {
    return remoteDataSource.updateStatus(accountId, isActive);
  }

  @override
  Future<SystemSettings> getSystemSettings() {
    return remoteDataSource.fetchSystemSettings();
  }

  @override
  Future<SystemSettings> updateSystemSettings(SystemSettings settings) {
    return remoteDataSource.saveSystemSettings(
      SystemSettingsModel.fromEntity(settings),
    );
  }
}
