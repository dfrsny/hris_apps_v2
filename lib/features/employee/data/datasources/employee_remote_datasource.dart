import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/features/employee/data/models/attendance_record_model.dart';
import 'package:hris_apps/features/employee/data/models/employee_profile_model.dart';
import 'package:hris_apps/features/employee/data/models/leave_request_model.dart';
import 'package:hris_apps/features/employee/data/models/payslip_record_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<EmployeeProfileModel> fetchProfile();
  Future<EmployeeProfileModel> updatePhone(String newPhone);
  Future<List<AttendanceRecordModel>> fetchAttendanceHistory();
  Future<AttendanceRecordModel> checkIn(String timeFormatted);
  Future<AttendanceRecordModel> checkOut(String timeFormatted);
  Future<List<LeaveRequestModel>> fetchLeaveRequests();
  Future<LeaveRequestModel> createLeaveRequest({
    required String type,
    required String dateRange,
    required int days,
    required String reason,
  });
  Future<List<PayslipRecordModel>> fetchPayslips();
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final SupabaseClient _supabase;

  EmployeeRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const String _profilesTable = 'profiles';
  static const String _attendancesTable = 'attendances';
  static const String _leaveRequestsTable = 'leave_requests';
  static const String _payslipsTable = 'payslips';

  /// Mengambil ID user yang sedang login saat ini
  String get _currentUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }
    return userId;
  }

  /// Format tanggal hari ini ke format YYYY-MM-DD (untuk key unik absensi harian)
  String _todayIsoDate() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Format tanggal tampilan UI (contoh: "28 Nov 2026")
  String _formatDisplayDate(String rawDate) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = months[parsed.month - 1];
    return '$day $month ${parsed.year}';
  }

  // ─────────────────────────────────────────────
  //  M1: Profil Karyawan
  // ─────────────────────────────────────────────
  @override
  Future<EmployeeProfileModel> fetchProfile() async {
    try {
      final userId = _currentUserId;
      final response = await _supabase
          .from(_profilesTable)
          .select(
            'id, employee_code, full_name, email, department, position, join_date, phone_number, remaining_leave_quota',
          )
          .eq('id', userId)
          .single();

      return EmployeeProfileModel.fromJson({
        'employee_id': response['employee_code'] ?? response['id'],
        'full_name': response['full_name'] ?? '-',
        'email': response['email'] ?? _supabase.auth.currentUser?.email ?? '-',
        'department': response['department'] ?? 'Belum diatur',
        'position': response['position'] ?? 'Karyawan',
        'join_date': response['join_date'] != null
            ? _formatDisplayDate(response['join_date'].toString())
            : '-',
        'phone_number': response['phone_number'] ?? '-',
        'remaining_leave_quota': response['remaining_leave_quota'] ?? 12,
      });
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat profil karyawan: ${e.message}');
    }
  }

  @override
  Future<EmployeeProfileModel> updatePhone(String newPhone) async {
    try {
      final userId = _currentUserId;
      final response = await _supabase
          .from(_profilesTable)
          .update({'phone_number': newPhone.trim()})
          .eq('id', userId)
          .select(
            'id, employee_code, full_name, email, department, position, join_date, phone_number, remaining_leave_quota',
          )
          .single();

      return EmployeeProfileModel.fromJson({
        'employee_id': response['employee_code'] ?? response['id'],
        'full_name': response['full_name'] ?? '-',
        'email': response['email'] ?? _supabase.auth.currentUser?.email ?? '-',
        'department': response['department'] ?? 'Belum diatur',
        'position': response['position'] ?? 'Karyawan',
        'join_date': response['join_date'] != null
            ? _formatDisplayDate(response['join_date'].toString())
            : '-',
        'phone_number': response['phone_number'] ?? '-',
        'remaining_leave_quota': response['remaining_leave_quota'] ?? 12,
      });
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui nomor telepon: ${e.message}');
    }
  }

  // ─────────────────────────────────────────────
  //  M3: Absensi Pribadi
  // ─────────────────────────────────────────────
  @override
  Future<List<AttendanceRecordModel>> fetchAttendanceHistory() async {
    try {
      final userId = _currentUserId;
      final response = await _supabase
          .from(_attendancesTable)
          .select('attendance_date, check_in, check_out, status')
          .eq('user_id', userId)
          .order('attendance_date', ascending: false)
          .limit(30);

      return (response as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        final rawDate = map['attendance_date'].toString();
        final isToday = rawDate == _todayIsoDate();
        final formattedDate = _formatDisplayDate(rawDate);

        return AttendanceRecordModel.fromJson({
          'raw_date': rawDate, // format YYYY-MM-DD dari Supabase
          'date': isToday ? 'Hari Ini ($formattedDate)' : formattedDate,
          'check_in': map['check_in'] ?? '-',
          'check_out': map['check_out'] ?? '-',
          'status': map['status'] ?? 'Hadir',
        });
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat riwayat absensi: ${e.message}');
    }
  }

  @override
  Future<AttendanceRecordModel> checkIn(String timeFormatted) async {
    try {
      final userId = _currentUserId;
      final today = _todayIsoDate();

      final response = await _supabase
          .from(_attendancesTable)
          .upsert({
            'user_id': userId,
            'attendance_date': today,
            'check_in': timeFormatted,
            'status': 'Hadir',
          }, onConflict: 'user_id,attendance_date')
          .select('attendance_date, check_in, check_out, status')
          .single();

      final formattedDate = _formatDisplayDate(
        response['attendance_date'].toString(),
      );

      return AttendanceRecordModel.fromJson({
        'raw_date': response['attendance_date'].toString(),
        'date': 'Hari Ini ($formattedDate)',
        'check_in': response['check_in'] ?? '-',
        'check_out': response['check_out'] ?? '-',
        'status': response['status'] ?? 'Hadir',
      });
    } on PostgrestException catch (e) {
      throw Exception('Gagal melakukan check-in: ${e.message}');
    }
  }

  @override
  Future<AttendanceRecordModel> checkOut(String timeFormatted) async {
    try {
      final userId = _currentUserId;
      final today = _todayIsoDate();

      final response = await _supabase
          .from(_attendancesTable)
          .update({'check_out': timeFormatted, 'status': 'Selesai'})
          .eq('user_id', userId)
          .eq('attendance_date', today)
          .select('attendance_date, check_in, check_out, status')
          .single();

      final formattedDate = _formatDisplayDate(
        response['attendance_date'].toString(),
      );

      return AttendanceRecordModel.fromJson({
        'raw_date': response['attendance_date'].toString(),
        'date': 'Hari Ini ($formattedDate)',
        'check_in': response['check_in'] ?? '-',
        'check_out': response['check_out'] ?? '-',
        'status': response['status'] ?? 'Hadir',
      });
    } on PostgrestException catch (e) {
      throw Exception('Gagal melakukan check-out: ${e.message}');
    }
  }

  // ─────────────────────────────────────────────
  //  M4: Pengajuan Cuti
  // ─────────────────────────────────────────────
  @override
  Future<List<LeaveRequestModel>> fetchLeaveRequests() async {
    try {
      final userId = _currentUserId;
      final response = await _supabase
          .from(_leaveRequestsTable)
          .select('id, leave_type, date_range, days, reason, status')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return LeaveRequestModel.fromJson({
          'id': map['id'].toString(),
          'type': map['leave_type'] as String,
          'date_range': map['date_range'] as String,
          'days': map['days'] as int,
          'reason': map['reason'] as String,
          'status': map['status'] as String,
        });
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat daftar pengajuan cuti: ${e.message}');
    }
  }

  @override
  Future<LeaveRequestModel> createLeaveRequest({
    required String type,
    required String dateRange,
    required int days,
    required String reason,
  }) async {
    try {
      final userId = _currentUserId;
      final response = await _supabase
          .from(_leaveRequestsTable)
          .insert({
            'user_id': userId,
            'leave_type': type,
            'date_range': dateRange,
            'days': days,
            'reason': reason.trim(),
            'status': 'pending',
          })
          .select('id, leave_type, date_range, days, reason, status')
          .single();

      return LeaveRequestModel.fromJson({
        'id': response['id'].toString(),
        'type': response['leave_type'] as String,
        'date_range': response['date_range'] as String,
        'days': response['days'] as int,
        'reason': response['reason'] as String,
        'status': response['status'] as String,
      });
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengirim pengajuan cuti: ${e.message}');
    }
  }

  // ─────────────────────────────────────────────
  //  M5: Slip Gaji Pribadi
  // ─────────────────────────────────────────────
  @override
  Future<List<PayslipRecordModel>> fetchPayslips() async {
    try {
      final userId = _currentUserId;
      final response = await _supabase
          .from(_payslipsTable)
          .select('period, base_salary, allowance, deduction')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (row) => PayslipRecordModel.fromJson(row as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat data slip gaji: ${e.message}');
    }
  }
}
