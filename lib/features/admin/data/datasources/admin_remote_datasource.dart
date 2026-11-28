import 'package:supabase_flutter/supabase_flutter.dart';
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
  final SupabaseClient _supabase;

  AdminRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const String _profilesTable = 'profiles';
  static const String _settingsTable = 'system_settings';
  static const String _createUserFunction = 'create-user';
  static const String _profileColumns = 'id, email, full_name, role, is_active';

  String _roleToDbValue(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.hr:
        return 'hr';
      case UserRole.finance:
        return 'finance';
      case UserRole.employee:
        return 'employee';
    }
  }

  @override
  Future<List<ManagedAccountModel>> fetchAccounts() async {
    try {
      final response = await _supabase
          .from(_profilesTable)
          .select(_profileColumns)
          .neq('role', 'super_admin')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (row) => ManagedAccountModel.fromJson(row as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat daftar akun: ${e.message}');
    }
  }

  @override
  Future<ManagedAccountModel> createAccount({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (role == UserRole.superAdmin) {
      throw Exception(
        'Role Super Admin hanya dapat diberikan melalui SQL manual.',
      );
    }

    try {
      final response = await _supabase.functions.invoke(
        _createUserFunction,
        body: {
          'email': email.trim(),
          'password': password,
          'full_name': displayName.trim(),
          'role': _roleToDbValue(role),
        },
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Respons server tidak valid.');
      }

      final userMap = (data['user'] is Map<String, dynamic>)
          ? data['user'] as Map<String, dynamic>
          : data;

      return ManagedAccountModel.fromJson(userMap);
    } on FunctionException catch (e) {
      final details = e.details;
      final serverMessage = (details is Map && details['error'] != null)
          ? details['error'].toString()
          : (e.reasonPhrase ?? 'Gagal membuat akun di server.');
      throw Exception(serverMessage);
    }
  }

  @override
  Future<ManagedAccountModel> updateRole(
    String accountId,
    UserRole newRole,
  ) async {
    if (newRole == UserRole.superAdmin) {
      throw Exception(
        'Tidak dapat mengubah role menjadi Super Admin lewat UI.',
      );
    }

    try {
      final response = await _supabase
          .from(_profilesTable)
          .update({'role': _roleToDbValue(newRole)})
          .eq('id', accountId)
          .select(_profileColumns)
          .single();

      return ManagedAccountModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui role akun: ${e.message}');
    }
  }

  @override
  Future<ManagedAccountModel> updateStatus(
    String accountId,
    bool isActive,
  ) async {
    try {
      final response = await _supabase
          .from(_profilesTable)
          .update({'is_active': isActive})
          .eq('id', accountId)
          .select(_profileColumns)
          .single();

      return ManagedAccountModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui status akun: ${e.message}');
    }
  }

  @override
  Future<SystemSettingsModel> fetchSystemSettings() async {
    try {
      final response = await _supabase
          .from(_settingsTable)
          .select(
            'company_name, clock_in_hour, clock_in_minute, clock_out_hour, clock_out_minute',
          )
          .eq('id', 1)
          .maybeSingle();

      if (response == null) {
        return const SystemSettingsModel(
          companyName: 'PT Nusantara Teknologi Digital',
          clockInHour: 8,
          clockInMinute: 30,
          clockOutHour: 17,
          clockOutMinute: 30,
        );
      }

      return SystemSettingsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat pengaturan sistem: ${e.message}');
    }
  }

  @override
  Future<SystemSettingsModel> saveSystemSettings(
    SystemSettingsModel settings,
  ) async {
    try {
      final payload = {
        'id': 1,
        ...settings.toJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _supabase
          .from(_settingsTable)
          .upsert(payload)
          .select(
            'company_name, clock_in_hour, clock_in_minute, clock_out_hour, clock_out_minute',
          )
          .single();

      return SystemSettingsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal menyimpan pengaturan sistem: ${e.message}');
    }
  }
}
