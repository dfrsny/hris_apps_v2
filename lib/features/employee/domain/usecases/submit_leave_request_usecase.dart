import 'package:hris_apps/features/employee/domain/entities/leave_request.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class SubmitLeaveRequestUseCase {
  final EmployeeRepository repository;
  SubmitLeaveRequestUseCase(this.repository);

  Future<LeaveRequest> call({
    required String type,
    required String dateRange,
    required int days,
    required String reason,
  }) {
    return repository.submitLeaveRequest(
      type: type,
      dateRange: dateRange,
      days: days,
      reason: reason,
    );
  }
}
