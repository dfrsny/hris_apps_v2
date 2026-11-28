import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_attendance_entry.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';
import 'package:hris_apps/features/hr/domain/usecases/assign_manager_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/decide_leave_request_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/get_all_attendance_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/get_all_leaves_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/get_hr_employees_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/save_employee_profile_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/toggle_employee_status_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/update_salary_components_usecase.dart';

class HrProvider extends ChangeNotifier {
  final GetHrEmployeesUseCase getHrEmployeesUseCase;
  final SaveEmployeeProfileUseCase saveEmployeeProfileUseCase;
  final ToggleEmployeeStatusUseCase toggleEmployeeStatusUseCase;
  final AssignManagerUseCase assignManagerUseCase;
  final UpdateSalaryComponentsUseCase updateSalaryComponentsUseCase;
  final GetAllAttendanceUseCase getAllAttendanceUseCase;
  final GetAllLeavesUseCase getAllLeavesUseCase;
  final DecideLeaveRequestUseCase decideLeaveRequestUseCase;

  HrProvider({
    required this.getHrEmployeesUseCase,
    required this.saveEmployeeProfileUseCase,
    required this.toggleEmployeeStatusUseCase,
    required this.assignManagerUseCase,
    required this.updateSalaryComponentsUseCase,
    required this.getAllAttendanceUseCase,
    required this.getAllLeavesUseCase,
    required this.decideLeaveRequestUseCase,
  });

  List<HrEmployeeRecord> _employees = [];
  List<HrAttendanceEntry> _allAttendance = [];
  List<HrLeaveItem> _allLeaves = [];

  bool _isLoadingEmployees = false;
  bool _isLoadingAttendance = false;
  bool _isLoadingLeaves = false;
  String? _errorMessage;

  // Filters
  String _employeeSearchQuery = '';
  String? _selectedDepartmentFilter;
  String _attendanceDeptFilter = 'Semua';
  bool _onlyNoApproverFilter = false;
  String _selectedPayrollPeriod = 'November 2026';

  List<HrEmployeeRecord> get employees => _employees;
  List<HrAttendanceEntry> get allAttendance => _allAttendance;
  List<HrLeaveItem> get allLeaves => _allLeaves;
  bool get isLoadingEmployees => _isLoadingEmployees;
  bool get isLoadingAttendance => _isLoadingAttendance;
  bool get isLoadingLeaves => _isLoadingLeaves;
  String? get errorMessage => _errorMessage;

  String? get selectedDepartmentFilter => _selectedDepartmentFilter;
  String get attendanceDeptFilter => _attendanceDeptFilter;
  bool get onlyNoApproverFilter => _onlyNoApproverFilter;
  String get selectedPayrollPeriod => _selectedPayrollPeriod;

  List<HrEmployeeRecord> get filteredEmployees {
    final q = _employeeSearchQuery.toLowerCase().trim();
    return _employees.where((emp) {
      final matchSearch = q.isEmpty ||
          emp.fullName.toLowerCase().contains(q) ||
          emp.email.toLowerCase().contains(q) ||
          emp.position.toLowerCase().contains(q);
      final matchDept = _selectedDepartmentFilter == null ||
          emp.department == _selectedDepartmentFilter;
      return matchSearch && matchDept;
    }).toList();
  }

  List<HrAttendanceEntry> get filteredAttendance => _attendanceDeptFilter == 'Semua'
      ? _allAttendance
      : _allAttendance.where((a) => a.department == _attendanceDeptFilter).toList();

  List<HrLeaveItem> get visibleLeaves => _onlyNoApproverFilter
      ? _allLeaves.where((l) => l.hasNoApprover).toList()
      : _allLeaves;

  bool isLead(HrEmployeeRecord emp) =>
      _employees.any((other) => other.managerId == emp.id);

  String getManagerName(String? managerId) {
    if (managerId == null) return 'Belum ditetapkan (Top-level)';
    final found = _employees.where((e) => e.id == managerId);
    return found.isNotEmpty ? found.first.fullName : 'Tidak ditemukan';
  }

  Future<void> initializeDashboard() async {
    await Future.wait([
      loadEmployees(),
      loadAllAttendance(),
      loadAllLeaves(),
    ]);
  }

  Future<void> loadEmployees() async {
    _isLoadingEmployees = true;
    notifyListeners();
    try {
      _employees = await getHrEmployeesUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('HR LOAD EMPLOYEES ERROR: $_errorMessage');
    } finally {
      _isLoadingEmployees = false;
      notifyListeners();
    }
  }

  Future<void> loadAllAttendance() async {
    _isLoadingAttendance = true;
    notifyListeners();
    try {
      _allAttendance = await getAllAttendanceUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('HR LOAD ATTENDANCE ERROR: $_errorMessage');
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  Future<void> loadAllLeaves() async {
    _isLoadingLeaves = true;
    notifyListeners();
    try {
      _allLeaves = await getAllLeavesUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('HR LOAD LEAVES ERROR: $_errorMessage');
    } finally {
      _isLoadingLeaves = false;
      notifyListeners();
    }
  }

  // --- Filter Setters ---
  void setEmployeeSearchQuery(String val) {
    _employeeSearchQuery = val;
    notifyListeners();
  }

  void setDepartmentFilter(String? dept) {
    _selectedDepartmentFilter = dept;
    notifyListeners();
  }

  void setAttendanceDeptFilter(String dept) {
    _attendanceDeptFilter = dept;
    notifyListeners();
  }

  void setOnlyNoApproverFilter(bool val) {
    _onlyNoApproverFilter = val;
    notifyListeners();
  }

  void setSelectedPayrollPeriod(String period) {
    _selectedPayrollPeriod = period;
    notifyListeners();
  }

  // --- Mutations ---
  Future<bool> saveEmployee(HrEmployeeRecord record, {required bool isEdit}) async {
    try {
      final saved = await saveEmployeeProfileUseCase(record, isEdit: isEdit);
      if (isEdit) {
        _employees = _employees.map((e) => e.id == saved.id ? saved : e).toList();
      } else {
        _employees = [saved, ..._employees];
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> toggleEmployeeStatus(String employeeId, bool isActive) async {
    try {
      final updated = await toggleEmployeeStatusUseCase(employeeId, isActive);
      _employees = _employees.map((e) => e.id == updated.id ? updated : e).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> assignManager(String employeeId, String? managerId) async {
    try {
      final updated = await assignManagerUseCase(employeeId, managerId);
      _employees = _employees.map((e) => e.id == updated.id ? updated : e).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> updateSalaryComponents({
    required String employeeId,
    required int baseSalary,
    required int allowance,
    required int deduction,
  }) async {
    try {
      final updated = await updateSalaryComponentsUseCase(
        employeeId: employeeId,
        baseSalary: baseSalary,
        allowance: allowance,
        deduction: deduction,
      );
      _employees = _employees.map((e) => e.id == updated.id ? updated : e).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> decideLeave(String leaveId, LeaveApprovalStatus status) async {
    try {
      final updated = await decideLeaveRequestUseCase(leaveId, status);
      _allLeaves = _allLeaves.map((l) => l.id == updated.id ? updated : l).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }
}