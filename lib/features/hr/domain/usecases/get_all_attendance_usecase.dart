import 'package:hris_apps/features/hr/domain/entities/hr_attendance_entry.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class GetAllAttendanceUseCase {
  final HrRepository repository;
  const GetAllAttendanceUseCase(this.repository);
  Future<List<HrAttendanceEntry>> call() => repository.getAllAttendance();
}
