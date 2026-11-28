import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class GetHrEmployeesUseCase {
  final HrRepository repository;
  const GetHrEmployeesUseCase(this.repository);
  Future<List<HrEmployeeRecord>> call() => repository.getEmployees();
}
