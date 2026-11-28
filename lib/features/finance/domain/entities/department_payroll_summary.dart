class DepartmentPayrollSummary {
  final String department;
  final int employeeCount;
  final int totalBaseSalary;
  final int totalAllowance;
  final int totalDeduction;

  const DepartmentPayrollSummary({
    required this.department,
    required this.employeeCount,
    required this.totalBaseSalary,
    required this.totalAllowance,
    required this.totalDeduction,
  });

  int get totalNetPayout => totalBaseSalary + totalAllowance - totalDeduction;
}
