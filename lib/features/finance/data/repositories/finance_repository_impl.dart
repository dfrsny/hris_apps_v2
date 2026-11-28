import 'package:hris_apps/features/finance/data/datasources/finance_remote_datasource.dart';
import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';
import 'package:hris_apps/features/finance/domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MonthlyPayrollBatch>> getPayrollBatches() {
    return remoteDataSource.fetchPayrollBatches();
  }

  @override
  Future<MonthlyPayrollBatch> runPayrollBatch(String period) {
    return remoteDataSource.executePayrollBatch(period);
  }

  @override
  Future<MonthlyPayrollBatch> finalizePayrollBatch(String period) {
    return remoteDataSource.lockPayrollBatch(period);
  }
}
