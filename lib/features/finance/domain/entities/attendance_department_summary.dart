class AttendanceDepartmentSummary {
  final String department;
  final int activeEmployees;
  final int totalWorkDays;
  final int totalLateCount;
  final int totalUnpaidLeaveDays;

  const AttendanceDepartmentSummary({
    required this.department,
    required this.activeEmployees,
    required this.totalWorkDays,
    required this.totalLateCount,
    required this.totalUnpaidLeaveDays,
  });
}