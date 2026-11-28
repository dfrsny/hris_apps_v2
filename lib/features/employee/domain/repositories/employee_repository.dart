import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';
import 'package:hris_apps/features/employee/domain/entities/employee_profile.dart';
import 'package:hris_apps/features/employee/domain/entities/leave_request.dart';
import 'package:hris_apps/features/employee/domain/entities/payslip_record.dart';

abstract class EmployeeRepository {
  Future<EmployeeProfile> getProfile();
  Future<EmployeeProfile> updatePhoneNumber(String newPhone);

  Future<List<AttendanceRecord>> getAttendanceHistory();
  Future<AttendanceRecord> checkIn(String timeFormatted);
  Future<AttendanceRecord> checkOut(String timeFormatted);

  Future<List<LeaveRequest>> getLeaveRequests();
  Future<LeaveRequest> submitLeaveRequest({
    required String type,
    required String dateRange,
    required int days,
    required String reason,
  });

  Future<List<PayslipRecord>> getPayslips();
}