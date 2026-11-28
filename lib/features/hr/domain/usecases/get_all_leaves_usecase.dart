import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class GetAllLeavesUseCase {
  final HrRepository repository;
  const GetAllLeavesUseCase(this.repository);
  Future<List<HrLeaveItem>> call() => repository.getAllLeaves();
}
