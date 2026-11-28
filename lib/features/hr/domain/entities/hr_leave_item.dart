import 'package:material_ui/material_ui.dart';

enum LeaveApprovalStatus { pending, approved, rejected }

extension LeaveApprovalStatusExt on LeaveApprovalStatus {
  String get label {
    switch (this) {
      case LeaveApprovalStatus.pending:
        return 'Menunggu';
      case LeaveApprovalStatus.approved:
        return 'Disetujui';
      case LeaveApprovalStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case LeaveApprovalStatus.pending:
        return Colors.orange;
      case LeaveApprovalStatus.approved:
        return Colors.green;
      case LeaveApprovalStatus.rejected:
        return Colors.red;
    }
  }
}

class HrLeaveItem {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String type;
  final String dateRange;
  final int days;
  final String reason;
  final String? approverName;
  final LeaveApprovalStatus status;

  const HrLeaveItem({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.type,
    required this.dateRange,
    required this.days,
    required this.reason,
    this.approverName,
    required this.status,
  });

  bool get hasNoApprover => approverName == null || approverName!.isEmpty;

  HrLeaveItem copyWith({LeaveApprovalStatus? status}) {
    return HrLeaveItem(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      type: type,
      dateRange: dateRange,
      days: days,
      reason: reason,
      approverName: approverName,
      status: status ?? this.status,
    );
  }
}
