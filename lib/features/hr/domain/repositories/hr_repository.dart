import 'package:hris_apps/features/hr/domain/entities/hr_attendance_entry.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';

abstract class HrRepository {
  Future<List<HrEmployeeRecord>> getEmployees();
  Future<HrEmployeeRecord> saveEmployee(
    HrEmployeeRecord employee, {
    required bool isEdit,
  });
  Future<HrEmployeeRecord> toggleEmployeeStatus(
    String employeeId,
    bool isActive,
  );
  Future<HrEmployeeRecord> assignManager(String employeeId, String? managerId);
  Future<HrEmployeeRecord> updateSalaryComponents({
    required String employeeId,
    required int baseSalary,
    required int allowance,
    required int deduction,
  });
  Future<List<HrAttendanceEntry>> getAllAttendance();
  Future<List<HrLeaveItem>> getAllLeaves();
  Future<HrLeaveItem> decideLeaveRequest(
    String leaveId,
    LeaveApprovalStatus status,
  );
}
