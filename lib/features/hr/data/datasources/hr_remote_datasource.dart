import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/features/hr/data/models/hr_attendance_entry_model.dart';
import 'package:hris_apps/features/hr/data/models/hr_employee_record_model.dart';
import 'package:hris_apps/features/hr/data/models/hr_leave_item_model.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';

abstract class HrRemoteDataSource {
  Future<List<HrEmployeeRecordModel>> fetchEmployees();
  Future<HrEmployeeRecordModel> saveEmployee(
    HrEmployeeRecord employee, {
    required bool isEdit,
  });
  Future<HrEmployeeRecordModel> toggleEmployeeStatus(
    String employeeId,
    bool isActive,
  );
  Future<HrEmployeeRecordModel> assignManager(
    String employeeId,
    String? managerId,
  );
  Future<HrEmployeeRecordModel> updateSalaryComponents({
    required String employeeId,
    required int baseSalary,
    required int allowance,
    required int deduction,
  });
  Future<List<HrAttendanceEntryModel>> fetchAllAttendance();
  Future<List<HrLeaveItemModel>> fetchAllLeaves();
  Future<HrLeaveItemModel> decideLeaveRequest(
    String leaveId,
    LeaveApprovalStatus status,
  );
}

class HrRemoteDataSourceImpl implements HrRemoteDataSource {
  final SupabaseClient _supabase;

  HrRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const String _employeeColumns =
      'id, full_name, email, department, position, join_date, is_active, manager_id, nik, npwp, bank_account, address, emergency_contact, base_salary, allowance, deduction';

  @override
  Future<List<HrEmployeeRecordModel>> fetchEmployees() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select(_employeeColumns)
          .neq('role', 'super_admin')
          .order('full_name', ascending: true);

      return (response as List<dynamic>)
          .map(
            (row) =>
                HrEmployeeRecordModel.fromJson(row as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat direktori karyawan: ${e.message}');
    }
  }

  @override
  Future<HrEmployeeRecordModel> saveEmployee(
    HrEmployeeRecord employee, {
    required bool isEdit,
  }) async {
    try {
      final payload = {
        'full_name': employee.fullName,
        'email': employee.email,
        'department': employee.department,
        'position': employee.position,
        'join_date': employee.joinDate,
        'is_active': employee.isActive,
        'nik': employee.nik,
        'npwp': employee.npwp,
        'bank_account': employee.bankAccount,
        'address': employee.address,
        'emergency_contact': employee.emergencyContact,
      };

      if (isEdit) {
        final response = await _supabase
            .from('profiles')
            .update(payload)
            .eq('id', employee.id)
            .select(_employeeColumns)
            .single();
        return HrEmployeeRecordModel.fromJson(response);
      } else {
        // Pembuatan akun Auth baru melalui Edge Function create-user + lengkapi data HR
        final fnRes = await _supabase.functions.invoke(
          'create-user',
          body: {
            'email': employee.email,
            'password': 'TempPass@${DateTime.now().year}',
            'full_name': employee.fullName,
            'role': 'employee',
          },
        );
        final userMap =
            (fnRes.data['user'] ?? fnRes.data) as Map<String, dynamic>;
        final newUserId = userMap['id'] as String;

        final updated = await _supabase
            .from('profiles')
            .update({
              ...payload,
              'base_salary': employee.baseSalary,
              'allowance': employee.allowance,
              'deduction': employee.deduction,
            })
            .eq('id', newUserId)
            .select(_employeeColumns)
            .single();

        return HrEmployeeRecordModel.fromJson(updated);
      }
    } on PostgrestException catch (e) {
      throw Exception('Gagal menyimpan data karyawan: ${e.message}');
    }
  }

  @override
  Future<HrEmployeeRecordModel> toggleEmployeeStatus(
    String employeeId,
    bool isActive,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({'is_active': isActive})
          .eq('id', employeeId)
          .select(_employeeColumns)
          .single();

      return HrEmployeeRecordModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui status karyawan: ${e.message}');
    }
  }

  @override
  Future<HrEmployeeRecordModel> assignManager(
    String employeeId,
    String? managerId,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({'manager_id': managerId})
          .eq('id', employeeId)
          .select(_employeeColumns)
          .single();

      return HrEmployeeRecordModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal menetapkan atasan: ${e.message}');
    }
  }

  @override
  Future<HrEmployeeRecordModel> updateSalaryComponents({
    required String employeeId,
    required int baseSalary,
    required int allowance,
    required int deduction,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({
            'base_salary': baseSalary,
            'allowance': allowance,
            'deduction': deduction,
          })
          .eq('id', employeeId)
          .select(_employeeColumns)
          .single();

      return HrEmployeeRecordModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui komponen gaji: ${e.message}');
    }
  }

  @override
  Future<List<HrAttendanceEntryModel>> fetchAllAttendance() async {
    try {
      final response = await _supabase
          .from('attendances')
          .select(
            'user_id, attendance_date, check_in, check_out, status, profiles(full_name, department)',
          )
          .order('attendance_date', ascending: false)
          .limit(100);

      return (response as List<dynamic>)
          .map(
            (row) =>
                HrAttendanceEntryModel.fromJson(row as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat rekap absensi: ${e.message}');
    }
  }

  @override
  Future<List<HrLeaveItemModel>> fetchAllLeaves() async {
    try {
      // Ambil peta nama karyawan untuk me-resolve manager_id menjadi nama approver
      final profilesRes = await _supabase
          .from('profiles')
          .select('id, full_name');
      final nameById = <String, String>{
        for (final p in (profilesRes as List<dynamic>))
          p['id'] as String: (p['full_name'] as String? ?? 'Lead'),
      };

      final response = await _supabase
          .from('leave_requests')
          .select(
            'id, user_id, leave_type, date_range, days, reason, status, profiles(full_name, department, manager_id)',
          )
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        final profile = map['profiles'] as Map<String, dynamic>?;
        final managerId = profile?['manager_id'] as String?;
        final approverName =
            managerId != null && nameById.containsKey(managerId)
            ? '${nameById[managerId]} (Lead)'
            : null;

        return HrLeaveItemModel.fromJson(
          map,
          resolvedApproverName: approverName,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat data cuti: ${e.message}');
    }
  }

  @override
  Future<HrLeaveItemModel> decideLeaveRequest(
    String leaveId,
    LeaveApprovalStatus status,
  ) async {
    try {
      final response = await _supabase
          .from('leave_requests')
          .update({'status': status.name})
          .eq('id', leaveId)
          .select(
            'id, user_id, leave_type, date_range, days, reason, status, profiles(full_name, department)',
          )
          .single();

      return HrLeaveItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memproses persetujuan cuti: ${e.message}');
    }
  }
}
