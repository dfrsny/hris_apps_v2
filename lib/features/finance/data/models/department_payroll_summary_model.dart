import 'package:hris_apps/features/finance/domain/entities/department_payroll_summary.dart';

class DepartmentPayrollSummaryModel extends DepartmentPayrollSummary {
  const DepartmentPayrollSummaryModel({
    required super.department,
    required super.employeeCount,
    required super.totalBaseSalary,
    required super.totalAllowance,
    required super.totalDeduction,
  });

  factory DepartmentPayrollSummaryModel.fromJson(Map<String, dynamic> json) {
    return DepartmentPayrollSummaryModel(
      department: json['department'] as String,
      employeeCount: json['employee_count'] as int,
      totalBaseSalary: json['total_base_salary'] as int,
      totalAllowance: json['total_allowance'] as int,
      totalDeduction: json['total_deduction'] as int,
    );
  }
}
