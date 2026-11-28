enum LeaveStatus { pending, approved, rejected }

class LeaveRequest {
  final String id;
  final String type;
  final String dateRange;
  final int days;
  final String reason;
  final LeaveStatus status;

  const LeaveRequest({
    required this.id,
    required this.type,
    required this.dateRange,
    required this.days,
    required this.reason,
    required this.status,
  });
}
