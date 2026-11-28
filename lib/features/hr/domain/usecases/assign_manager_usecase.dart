import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class AssignManagerUseCase {
  final HrRepository repository;
  const AssignManagerUseCase(this.repository);
  Future<HrEmployeeRecord> call(String employeeId, String? managerId) =>
      repository.assignManager(employeeId, managerId);
}
