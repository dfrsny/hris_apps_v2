import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class UpdateSalaryComponentsUseCase {
  final HrRepository repository;
  const UpdateSalaryComponentsUseCase(this.repository);
  Future<HrEmployeeRecord> call({
    required String employeeId,
    required int baseSalary,
    required int allowance,
    required int deduction,
  }) => repository.updateSalaryComponents(
    employeeId: employeeId,
    baseSalary: baseSalary,
    allowance: allowance,
    deduction: deduction,
  );
}
