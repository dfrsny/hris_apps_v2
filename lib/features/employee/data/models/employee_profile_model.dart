import 'package:hris_apps/features/employee/domain/entities/employee_profile.dart';

class EmployeeProfileModel extends EmployeeProfile {
  const EmployeeProfileModel({
    required super.employeeId,
    required super.fullName,
    required super.email,
    required super.department,
    required super.position,
    required super.joinDate,
    required super.phoneNumber,
    required super.remainingLeaveQuota,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      employeeId: json['employee_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      joinDate: json['join_date'] as String,
      phoneNumber: json['phone_number'] as String,
      remainingLeaveQuota: json['remaining_leave_quota'] as int? ?? 0,
    );
  }
}