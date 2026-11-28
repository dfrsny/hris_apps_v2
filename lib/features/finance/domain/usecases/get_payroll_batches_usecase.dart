import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';
import 'package:hris_apps/features/finance/domain/repositories/finance_repository.dart';

class GetPayrollBatchesUseCase {
  final FinanceRepository repository;
  GetPayrollBatchesUseCase(this.repository);

  Future<List<MonthlyPayrollBatch>> call() => repository.getPayrollBatches();
}
