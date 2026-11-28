import 'package:hris_apps/features/employee/domain/entities/employee_profile.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class GetEmployeeProfileUseCase {
  final EmployeeRepository repository;
  GetEmployeeProfileUseCase(this.repository);

  Future<EmployeeProfile> call() => repository.getProfile();
}
