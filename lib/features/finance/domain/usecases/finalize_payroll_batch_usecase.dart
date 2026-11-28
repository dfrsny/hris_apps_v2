import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';
import 'package:hris_apps/features/finance/domain/repositories/finance_repository.dart';

class FinalizePayrollBatchUseCase {
  final FinanceRepository repository;
  FinalizePayrollBatchUseCase(this.repository);

  Future<MonthlyPayrollBatch> call(String period) {
    return repository.finalizePayrollBatch(period);
  }
}
