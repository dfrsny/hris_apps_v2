import 'package:hris_apps/features/hr/data/datasources/hr_remote_datasource.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_attendance_entry.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';
import 'package:hris_apps/features/hr/domain/repositories/hr_repository.dart';

class HrRepositoryImpl implements HrRepository {
  final HrRemoteDataSource remoteDataSource;
  const HrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HrEmployeeRecord>> getEmployees() =>
      remoteDataSource.fetchEmployees();

  @override
  Future<HrEmployeeRecord> saveEmployee(
    HrEmployeeRecord employee, {
    required bool isEdit,
  }) => remoteDataSource.saveEmployee(employee, isEdit: isEdit);

  @override
  Future<HrEmployeeRecord> toggleEmployeeStatus(
    String employeeId,
    bool isActive,
  ) => remoteDataSource.toggleEmployeeStatus(employeeId, isActive);

  @override
  Future<HrEmployeeRecord> assignManager(
    String employeeId,
    String? managerId,
  ) => remoteDataSource.assignManager(employeeId, managerId);

  @override
  Future<HrEmployeeRecord> updateSalaryComponents({
    required String employeeId,
    required int baseSalary,
    required int allowance,
    required int deduction,
  }) => remoteDataSource.updateSalaryComponents(
    employeeId: employeeId,
    baseSalary: baseSalary,
    allowance: allowance,
    deduction: deduction,
  );

  @override
  Future<List<HrAttendanceEntry>> getAllAttendance() =>
      remoteDataSource.fetchAllAttendance();

  @override
  Future<List<HrLeaveItem>> getAllLeaves() => remoteDataSource.fetchAllLeaves();

  @override
  Future<HrLeaveItem> decideLeaveRequest(
    String leaveId,
    LeaveApprovalStatus status,
  ) => remoteDataSource.decideLeaveRequest(leaveId, status);
}
