import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class SaveEmployeeProfileUseCase {
  final HrRepository repository;
  const SaveEmployeeProfileUseCase(this.repository);
  Future<HrEmployeeRecord> call(
    HrEmployeeRecord employee, {
    required bool isEdit,
  }) => repository.saveEmployee(employee, isEdit: isEdit);
}
