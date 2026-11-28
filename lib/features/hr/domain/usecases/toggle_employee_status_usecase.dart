import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class ToggleEmployeeStatusUseCase {
  final HrRepository repository;
  const ToggleEmployeeStatusUseCase(this.repository);
  Future<HrEmployeeRecord> call(String employeeId, bool isActive) =>
      repository.toggleEmployeeStatus(employeeId, isActive);
}
