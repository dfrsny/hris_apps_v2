import 'package:hris_apps/features/employee/data/datasources/employee_remote_datasource.dart';
import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';
import 'package:hris_apps/features/employee/domain/entities/employee_profile.dart';
import 'package:hris_apps/features/employee/domain/entities/leave_request.dart';
import 'package:hris_apps/features/employee/domain/entities/payslip_record.dart';
import 'package:hris_apps/features/employee/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<EmployeeProfile> getProfile() => remoteDataSource.fetchProfile();

  @override
  Future<EmployeeProfile> updatePhoneNumber(String newPhone) {
    return remoteDataSource.updatePhone(newPhone);
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistory() {
    return remoteDataSource.fetchAttendanceHistory();
  }

  @override
  Future<AttendanceRecord> checkIn(String timeFormatted) {
    return remoteDataSource.checkIn(timeFormatted);
  }

  @override
  Future<AttendanceRecord> checkOut(String timeFormatted) {
    return remoteDataSource.checkOut(timeFormatted);
  }

  @override
  Future<List<LeaveRequest>> getLeaveRequests() {
    return remoteDataSource.fetchLeaveRequests();
  }

  @override
  Future<LeaveRequest> submitLeaveRequest({
    required String type,
    required String dateRange,
    required int days,
    required String reason,
  }) {
    return remoteDataSource.createLeaveRequest(
      type: type,
      dateRange: dateRange,
      days: days,
      reason: reason,
    );
  }

  @override
  Future<List<PayslipRecord>> getPayslips() => remoteDataSource.fetchPayslips();
}
