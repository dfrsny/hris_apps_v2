import 'package:hris_apps/features/finance/domain/entities/attendance_department_summary.dart';
import 'package:hris_apps/features/finance/domain/entities/department_payroll_summary.dart';

enum PayrollStatus { draft, processed, finalized }

class MonthlyPayrollBatch {
  final String period;
  final PayrollStatus status;
  final String? processedAt;
  final List<AttendanceDepartmentSummary> attendanceSummaries;
  final List<DepartmentPayrollSummary> departmentPayrolls;

  const MonthlyPayrollBatch({
    required this.period,
    required this.status,
    this.processedAt,
    required this.attendanceSummaries,
    required this.departmentPayrolls,
  });

  int get totalEmployees =>
      departmentPayrolls.fold(0, (sum, d) => sum + d.employeeCount);

  int get grandTotalGross => departmentPayrolls.fold(
    0,
    (sum, d) => sum + d.totalBaseSalary + d.totalAllowance,
  );

  int get grandTotalDeduction =>
      departmentPayrolls.fold(0, (sum, d) => sum + d.totalDeduction);

  int get grandTotalNet =>
      departmentPayrolls.fold(0, (sum, d) => sum + d.totalNetPayout);

  MonthlyPayrollBatch copyWith({
    String? period,
    PayrollStatus? status,
    String? processedAt,
    List<AttendanceDepartmentSummary>? attendanceSummaries,
    List<DepartmentPayrollSummary>? departmentPayrolls,
  }) {
    return MonthlyPayrollBatch(
      period: period ?? this.period,
      status: status ?? this.status,
      processedAt: processedAt ?? this.processedAt,
      attendanceSummaries: attendanceSummaries ?? this.attendanceSummaries,
      departmentPayrolls: departmentPayrolls ?? this.departmentPayrolls,
    );
  }
}
