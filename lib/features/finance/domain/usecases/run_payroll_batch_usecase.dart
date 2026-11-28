import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';
import 'package:hris_apps/features/finance/domain/repositories/finance_repository.dart';

class RunPayrollBatchUseCase {
  final FinanceRepository repository;
  RunPayrollBatchUseCase(this.repository);

  Future<MonthlyPayrollBatch> call(String period) {
    return repository.runPayrollBatch(period);
  }
}