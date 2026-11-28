import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.rawDate,
    required super.date,
    required super.checkIn,
    required super.checkOut,
    required super.status,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final parsedDate =
        DateTime.tryParse(json['raw_date']?.toString() ?? '') ?? DateTime.now();

    return AttendanceRecordModel(
      rawDate: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      date: json['date'] as String? ?? '-',
      checkIn: json['check_in'] as String? ?? '-',
      checkOut: json['check_out'] as String? ?? '-',
      status: json['status'] as String? ?? 'Hadir',
    );
  }
}
