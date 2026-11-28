import 'package:hris_apps/features/hr/domain/entities/hr_attendance_entry.dart';

class HrAttendanceEntryModel extends HrAttendanceEntry {
  const HrAttendanceEntryModel({
    required super.employeeId,
    required super.employeeName,
    required super.department,
    required super.date,
    required super.checkIn,
    required super.checkOut,
    required super.status,
  });

  factory HrAttendanceEntryModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return HrAttendanceEntryModel(
      employeeId: json['user_id'] as String,
      employeeName: profile?['full_name'] as String? ?? 'Karyawan',
      department: profile?['department'] as String? ?? 'Umum',
      date: json['attendance_date']?.toString() ?? '-',
      checkIn: json['check_in'] as String? ?? '-',
      checkOut: json['check_out'] as String? ?? '-',
      status: json['status'] as String? ?? 'Hadir',
    );
  }
}
