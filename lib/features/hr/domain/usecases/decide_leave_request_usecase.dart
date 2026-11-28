import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class DecideLeaveRequestUseCase {
  final HrRepository repository;

  const DecideLeaveRequestUseCase(this.repository);

  Future<HrLeaveItem> call(String leaveId, LeaveApprovalStatus status) {
    return repository.decideLeaveRequest(leaveId, status);
  }
}
