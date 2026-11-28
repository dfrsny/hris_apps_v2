class HrAttendanceEntry {
  final String employeeId;
  final String employeeName;
  final String department;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;

  const HrAttendanceEntry({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}
