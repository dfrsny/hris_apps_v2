class HrEmployeeRecord {
  final String id;
  final String fullName;
  final String email;
  final String department;
  final String position;
  final String joinDate;
  final bool isActive;
  final String? managerId;

  // Data sensitif (M2)
  final String nik;
  final String npwp;
  final String bankAccount;
  final String address;
  final String emergencyContact;

  // Komponen gaji per karyawan (M5)
  final int baseSalary;
  final int allowance;
  final int deduction;

  const HrEmployeeRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
    required this.position,
    required this.joinDate,
    this.isActive = true,
    this.managerId,
    required this.nik,
    required this.npwp,
    required this.bankAccount,
    required this.address,
    required this.emergencyContact,
    required this.baseSalary,
    required this.allowance,
    required this.deduction,
  });

  int get netSalary => baseSalary + allowance - deduction;

  HrEmployeeRecord copyWith({
    String? id,
    String? fullName,
    String? email,
    String? department,
    String? position,
    String? joinDate,
    bool? isActive,
    String? managerId,
    bool clearManagerId = false,
    String? nik,
    String? npwp,
    String? bankAccount,
    String? address,
    String? emergencyContact,
    int? baseSalary,
    int? allowance,
    int? deduction,
  }) {
    return HrEmployeeRecord(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      department: department ?? this.department,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      managerId: clearManagerId ? null : (managerId ?? this.managerId),
      nik: nik ?? this.nik,
      npwp: npwp ?? this.npwp,
      bankAccount: bankAccount ?? this.bankAccount,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      baseSalary: baseSalary ?? this.baseSalary,
      allowance: allowance ?? this.allowance,
      deduction: deduction ?? this.deduction,
    );
  }
}
