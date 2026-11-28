import 'package:hris_apps/features/employee/domain/entities/employee_profile.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class UpdatePhoneNumberUseCase {
  final EmployeeRepository repository;
  UpdatePhoneNumberUseCase(this.repository);

  Future<EmployeeProfile> call(String newPhone) {
    return repository.updatePhoneNumber(newPhone);
  }
}
