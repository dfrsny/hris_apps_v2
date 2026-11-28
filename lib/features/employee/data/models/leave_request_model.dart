import 'package:hris_apps/features/employee/domain/entities/leave_request.dart';

class LeaveRequestModel extends LeaveRequest {
  const LeaveRequestModel({
    required super.id,
    required super.type,
    required super.dateRange,
    required super.days,
    required super.reason,
    required super.status,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] as String,
      type: json['type'] as String,
      dateRange: json['date_range'] as String,
      days: json['days'] as int,
      reason: json['reason'] as String,
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LeaveStatus.pending,
      ),
    );
  }
}
