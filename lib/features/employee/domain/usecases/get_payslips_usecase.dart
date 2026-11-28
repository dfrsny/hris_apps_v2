import 'package:hris_apps/features/employee/domain/entities/payslip_record.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class GetPayslipsUseCase {
  final EmployeeRepository repository;
  GetPayslipsUseCase(this.repository);

  Future<List<PayslipRecord>> call() => repository.getPayslips();
}
