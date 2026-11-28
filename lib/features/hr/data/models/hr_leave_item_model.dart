import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';

class HrLeaveItemModel extends HrLeaveItem {
  const HrLeaveItemModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.department,
    required super.type,
    required super.dateRange,
    required super.days,
    required super.reason,
    super.approverName,
    required super.status,
  });

  factory HrLeaveItemModel.fromJson(
    Map<String, dynamic> json, {
    String? resolvedApproverName,
  }) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final rawStatus = json['status'] as String? ?? 'pending';

    return HrLeaveItemModel(
      id: json['id'].toString(),
      employeeId: json['user_id'] as String,
      employeeName: profile?['full_name'] as String? ?? 'Karyawan',
      department: profile?['department'] as String? ?? 'Umum',
      type: json['leave_type'] as String? ?? 'Cuti',
      dateRange: json['date_range'] as String? ?? '-',
      days: (json['days'] as num?)?.toInt() ?? 1,
      reason: json['reason'] as String? ?? '-',
      approverName: resolvedApproverName,
      status: LeaveApprovalStatus.values.firstWhere(
        (e) => e.name == rawStatus,
        orElse: () => LeaveApprovalStatus.pending,
      ),
    );
  }
}
