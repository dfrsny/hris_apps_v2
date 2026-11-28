import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class CheckOutUseCase {
  final EmployeeRepository repository;
  CheckOutUseCase(this.repository);

  Future<AttendanceRecord> call(String timeFormatted) {
    return repository.checkOut(timeFormatted);
  }
}
