import 'package:hris_apps/features/finance/domain/entities/attendance_department_summary.dart';

class AttendanceDepartmentSummaryModel extends AttendanceDepartmentSummary {
  const AttendanceDepartmentSummaryModel({
    required super.department,
    required super.activeEmployees,
    required super.totalWorkDays,
    required super.totalLateCount,
    required super.totalUnpaidLeaveDays,
  });

  factory AttendanceDepartmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDepartmentSummaryModel(
      department: json['department'] as String,
      activeEmployees: json['active_employees'] as int,
      totalWorkDays: json['total_work_days'] as int,
      totalLateCount: json['total_late_count'] as int,
      totalUnpaidLeaveDays: json['total_unpaid_leave_days'] as int,
    );
  }
}
