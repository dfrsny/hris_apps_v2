import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class CheckInUseCase {
  final EmployeeRepository repository;
  CheckInUseCase(this.repository);

  Future<AttendanceRecord> call(String timeFormatted) {
    return repository.checkIn(timeFormatted);
  }
}
