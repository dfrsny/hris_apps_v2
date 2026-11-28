import 'package:hris_apps/features/finance/data/models/attendance_department_summary_model.dart';
import 'package:hris_apps/features/finance/data/models/department_payroll_summary_model.dart';
import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';

class MonthlyPayrollBatchModel extends MonthlyPayrollBatch {
  const MonthlyPayrollBatchModel({
    required super.period,
    required super.status,
    super.processedAt,
    required super.attendanceSummaries,
    required super.departmentPayrolls,
  });

  factory MonthlyPayrollBatchModel.fromJson(Map<String, dynamic> json) {
    return MonthlyPayrollBatchModel(
      period: json['period'] as String,
      status: PayrollStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PayrollStatus.draft,
      ),
      processedAt: json['processed_at'] as String?,
      attendanceSummaries: (json['attendance_summaries'] as List<dynamic>)
          .map(
            (e) => AttendanceDepartmentSummaryModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      departmentPayrolls: (json['department_payrolls'] as List<dynamic>)
          .map(
            (e) => DepartmentPayrollSummaryModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
