import 'package:hris_apps/features/employee/domain/entities/leave_request.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class GetLeaveRequestsUseCase {
  final EmployeeRepository repository;
  GetLeaveRequestsUseCase(this.repository);

  Future<List<LeaveRequest>> call() => repository.getLeaveRequests();
}