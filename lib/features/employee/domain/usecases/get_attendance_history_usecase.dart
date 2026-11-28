import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class GetAttendanceHistoryUseCase {
  final EmployeeRepository repository;
  GetAttendanceHistoryUseCase(this.repository);

  Future<List<AttendanceRecord>> call() => repository.getAttendanceHistory();
}
