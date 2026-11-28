import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';

class HrEmployeeRecordModel extends HrEmployeeRecord {
  const HrEmployeeRecordModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.department,
    required super.position,
    required super.joinDate,
    super.isActive,
    super.managerId,
    required super.nik,
    required super.npwp,
    required super.bankAccount,
    required super.address,
    required super.emergencyContact,
    required super.baseSalary,
    required super.allowance,
    required super.deduction,
  });

  factory HrEmployeeRecordModel.fromJson(Map<String, dynamic> json) {
    return HrEmployeeRecordModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '-',
      email: json['email'] as String? ?? '-',
      department: json['department'] as String? ?? 'Umum',
      position: json['position'] as String? ?? 'Staff',
      joinDate: json['join_date']?.toString() ?? '-',
      isActive: json['is_active'] as bool? ?? true,
      managerId: json['manager_id'] as String?,
      nik: json['nik'] as String? ?? '-',
      npwp: json['npwp'] as String? ?? '-',
      bankAccount: json['bank_account'] as String? ?? '-',
      address: json['address'] as String? ?? '-',
      emergencyContact: json['emergency_contact'] as String? ?? '-',
      baseSalary: (json['base_salary'] as num?)?.toInt() ?? 0,
      allowance: (json['allowance'] as num?)?.toInt() ?? 0,
      deduction: (json['deduction'] as num?)?.toInt() ?? 0,
    );
  }
}
