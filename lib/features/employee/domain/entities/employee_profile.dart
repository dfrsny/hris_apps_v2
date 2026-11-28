class EmployeeProfile {
  final String employeeId;
  final String fullName;
  final String email;
  final String department;
  final String position;
  final String joinDate;
  final String phoneNumber;
  final int remainingLeaveQuota;

  const EmployeeProfile({
    required this.employeeId,
    required this.fullName,
    required this.email,
    required this.department,
    required this.position,
    required this.joinDate,
    required this.phoneNumber,
    required this.remainingLeaveQuota,
  });

  EmployeeProfile copyWith({
    String? employeeId,
    String? fullName,
    String? email,
    String? department,
    String? position,
    String? joinDate,
    String? phoneNumber,
    int? remainingLeaveQuota,
  }) {
    return EmployeeProfile(
      employeeId: employeeId ?? this.employeeId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      department: department ?? this.department,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      remainingLeaveQuota: remainingLeaveQuota ?? this.remainingLeaveQuota,
    );
  }
}
