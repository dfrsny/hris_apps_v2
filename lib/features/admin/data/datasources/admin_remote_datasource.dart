import 'package:hris_apps/features/admin/data/models/managed_account_model.dart';
import 'package:hris_apps/features/admin/data/models/system_settings_model.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

abstract class AdminRemoteDataSource {
  Future<List<ManagedAccountModel>> fetchAccounts();
  Future<ManagedAccountModel> createAccount({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
  });
  Future<ManagedAccountModel> updateRole(String accountId, UserRole newRole);
  Future<ManagedAccountModel> updateStatus(String accountId, bool isActive);
  Future<SystemSettingsModel> fetchSystemSettings();
  Future<SystemSettingsModel> saveSystemSettings(SystemSettingsModel settings);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  // Simulasi in-memory database sementara sebelum integrasi Supabase Client
  final List<ManagedAccountModel> _mockDbAccounts = [
    const ManagedAccountModel(
      id: 'usr-001',
      email: 'nadia.hr@perusahaan.co.id',
      displayName: 'Nadia Pratama',
      role: UserRole.hr,
      isActive: true,
    ),
    const ManagedAccountModel(
      id: 'usr-002',
      email: 'budi.fin@perusahaan.co.id',
      displayName: 'Budi Santoso',
      role: UserRole.finance,
      isActive: true,
    ),
    const ManagedAccountModel(
      id: 'usr-003',
      email: 'rizky.dev@perusahaan.co.id',
      displayName: 'Rizky Ramadhan',
      role: UserRole.employee,
      isActive: true,
    ),
    const ManagedAccountModel(
      id: 'usr-004',
      email: 'sari.ops@perusahaan.co.id',
      displayName: 'Sari Wulandari',
      role: UserRole.employee,
      isActive: false,
    ),
  ];

  SystemSettingsModel _mockSettings = const SystemSettingsModel(
    companyName: 'PT Nusantara Teknologi Digital',
    clockInHour: 8,
    clockInMinute: 30,
    clockOutHour: 17,
    clockOutMinute: 30,
  );

  @override
  Future<List<ManagedAccountModel>> fetchAccounts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_mockDbAccounts);
  }

  @override
  Future<ManagedAccountModel> createAccount({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // TODO: Panggil Supabase Edge Function: supabase.functions.invoke('create-user', body: ...)
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final newAccount = ManagedAccountModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: displayName.trim(),
      role: role,
      isActive: true,
    );
    _mockDbAccounts.insert(0, newAccount);
    return newAccount;
  }

  @override
  Future<ManagedAccountModel> updateRole(
    String accountId,
    UserRole newRole,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final idx = _mockDbAccounts.indexWhere((e) => e.id == accountId);
    if (idx == -1) throw Exception('Akun tidak ditemukan');
    final updated = ManagedAccountModel(
      id: _mockDbAccounts[idx].id,
      email: _mockDbAccounts[idx].email,
      displayName: _mockDbAccounts[idx].displayName,
      role: newRole,
      isActive: _mockDbAccounts[idx].isActive,
    );
    _mockDbAccounts[idx] = updated;
    return updated;
  }

  @override
  Future<ManagedAccountModel> updateStatus(
    String accountId,
    bool isActive,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final idx = _mockDbAccounts.indexWhere((e) => e.id == accountId);
    if (idx == -1) throw Exception('Akun tidak ditemukan');
    final updated = ManagedAccountModel(
      id: _mockDbAccounts[idx].id,
      email: _mockDbAccounts[idx].email,
      displayName: _mockDbAccounts[idx].displayName,
      role: _mockDbAccounts[idx].role,
      isActive: isActive,
    );
    _mockDbAccounts[idx] = updated;
    return updated;
  }

  @override
  Future<SystemSettingsModel> fetchSystemSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockSettings;
  }

  @override
  Future<SystemSettingsModel> saveSystemSettings(
    SystemSettingsModel settings,
  ) async {
    // TODO: Simpan ke tabel system_settings di Supabase
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _mockSettings = settings;
    return _mockSettings;
  }
}
