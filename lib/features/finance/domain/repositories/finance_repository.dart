import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';

abstract class FinanceRepository {
  Future<List<MonthlyPayrollBatch>> getPayrollBatches();
  Future<MonthlyPayrollBatch> runPayrollBatch(String period);
  Future<MonthlyPayrollBatch> finalizePayrollBatch(String period);
}
