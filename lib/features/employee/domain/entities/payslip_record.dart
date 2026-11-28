class PayslipRecord {
  final String period;
  final int baseSalary;
  final int allowance;
  final int deduction;

  const PayslipRecord({
    required this.period,
    required this.baseSalary,
    required this.allowance,
    required this.deduction,
  });

  int get netSalary => baseSalary + allowance - deduction;
}
