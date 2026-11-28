import 'package:hris_apps/features/employee/domain/entities/payslip_record.dart';

class PayslipRecordModel extends PayslipRecord {
  const PayslipRecordModel({
    required super.period,
    required super.baseSalary,
    required super.allowance,
    required super.deduction,
  });

  factory PayslipRecordModel.fromJson(Map<String, dynamic> json) {
    return PayslipRecordModel(
      period: json['period'] as String,
      baseSalary: json['base_salary'] as int,
      allowance: json['allowance'] as int,
      deduction: json['deduction'] as int,
    );
  }
}
