import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';
import 'package:hris_apps/features/employee/domain/entities/employee_profile.dart';
import 'package:hris_apps/features/employee/domain/entities/leave_request.dart';
import 'package:hris_apps/features/employee/domain/entities/payslip_record.dart';
import 'package:hris_apps/features/employee/domain/usecases/check_in_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/check_out_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_attendance_history_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_employee_profile_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_leave_requests_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_payslips_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/submit_leave_request_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/update_phone_number_usecase.dart';

class EmployeeProvider extends ChangeNotifier {
  final GetEmployeeProfileUseCase getEmployeeProfileUseCase;
  final UpdatePhoneNumberUseCase updatePhoneNumberUseCase;
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;
  final CheckInUseCase checkInUseCase;
  final CheckOutUseCase checkOutUseCase;
  final GetLeaveRequestsUseCase getLeaveRequestsUseCase;
  final SubmitLeaveRequestUseCase submitLeaveRequestUseCase;
  final GetPayslipsUseCase getPayslipsUseCase;

  EmployeeProvider({
    required this.getEmployeeProfileUseCase,
    required this.updatePhoneNumberUseCase,
    required this.getAttendanceHistoryUseCase,
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.getLeaveRequestsUseCase,
    required this.submitLeaveRequestUseCase,
    required this.getPayslipsUseCase,
  });

  // --- Profile State ---
  EmployeeProfile? _profile;
  bool _isLoadingProfile = false;
  bool _isUpdatingPhone = false;

  // --- Attendance State ---
  List<AttendanceRecord> _attendanceHistory = [];
  bool _isLoadingAttendance = false;
  bool _isSubmittingAttendance = false;
  bool _hasCheckedInToday = false;
  bool _hasCheckedOutToday = false;
  String? _todayCheckInTime;
  String? _todayCheckOutTime;

  // --- Leave State ---
  List<LeaveRequest> _leaveRequests = [];
  bool _isLoadingLeaves = false;
  bool _isSubmittingLeave = false;

  // --- Payslip State ---
  List<PayslipRecord> _payslips = [];
  int _selectedPayslipIndex = 0;
  bool _isLoadingPayslips = false;

  // --- Error State ---
  String? _errorMessage;

  // --- Getters ---
  EmployeeProfile? get profile => _profile;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isUpdatingPhone => _isUpdatingPhone;

  List<AttendanceRecord> get attendanceHistory => _attendanceHistory;
  bool get isLoadingAttendance => _isLoadingAttendance;
  bool get isSubmittingAttendance => _isSubmittingAttendance;
  bool get hasCheckedInToday => _hasCheckedInToday;
  bool get hasCheckedOutToday => _hasCheckedOutToday;
  String? get todayCheckInTime => _todayCheckInTime;
  String? get todayCheckOutTime => _todayCheckOutTime;

  List<LeaveRequest> get leaveRequests => _leaveRequests;
  bool get isLoadingLeaves => _isLoadingLeaves;
  bool get isSubmittingLeave => _isSubmittingLeave;

  List<PayslipRecord> get payslips => _payslips;
  int get selectedPayslipIndex => _selectedPayslipIndex;
  bool get isLoadingPayslips => _isLoadingPayslips;
  PayslipRecord? get selectedPayslip =>
      (_payslips.isNotEmpty && _selectedPayslipIndex < _payslips.length)
      ? _payslips[_selectedPayslipIndex]
      : null;

  String? get errorMessage => _errorMessage;

  // --- Init ---
  Future<void> initializeDashboard() async {
    await Future.wait([
      loadProfile(),
      loadAttendanceHistory(),
      loadLeaveRequests(),
      loadPayslips(),
    ]);
  }

  Future<void> loadProfile() async {
    _isLoadingProfile = true;
    notifyListeners();
    try {
      _profile = await getEmployeeProfileUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('FETCH PROFILE ERROR: $_errorMessage');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceHistory() async {
    _isLoadingAttendance = true;
    notifyListeners();
    try {
      _attendanceHistory = await getAttendanceHistoryUseCase();
      _syncTodayAttendanceState();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('FETCH ATTENDANCE ERROR: $_errorMessage');
    } finally {
      _isLoadingAttendance = false;
      notifyListeners();
    }
  }

  /// Menyelaraskan status tombol Check-In & Check-Out dari data database hari ini
  void _syncTodayAttendanceState() {
    final now = DateTime.now();
    final todayRecord = _attendanceHistory
        .where(
          (item) =>
              item.rawDate.year == now.year &&
              item.rawDate.month == now.month &&
              item.rawDate.day == now.day,
        )
        .firstOrNull;

    if (todayRecord != null) {
      _hasCheckedInToday =
          todayRecord.checkIn.isNotEmpty && todayRecord.checkIn != '-';
      _todayCheckInTime = _hasCheckedInToday ? todayRecord.checkIn : null;

      _hasCheckedOutToday =
          todayRecord.checkOut.isNotEmpty && todayRecord.checkOut != '-';
      _todayCheckOutTime = _hasCheckedOutToday ? todayRecord.checkOut : null;
    } else {
      _hasCheckedInToday = false;
      _hasCheckedOutToday = false;
      _todayCheckInTime = null;
      _todayCheckOutTime = null;
    }
  }

  Future<void> loadLeaveRequests() async {
    _isLoadingLeaves = true;
    notifyListeners();
    try {
      _leaveRequests = await getLeaveRequestsUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('FETCH LEAVES ERROR: $_errorMessage');
    } finally {
      _isLoadingLeaves = false;
      notifyListeners();
    }
  }

  Future<void> loadPayslips() async {
    _isLoadingPayslips = true;
    notifyListeners();
    try {
      _payslips = await getPayslipsUseCase();
      _selectedPayslipIndex = 0;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('FETCH PAYSLIPS ERROR: $_errorMessage');
    } finally {
      _isLoadingPayslips = false;
      notifyListeners();
    }
  }

  // --- Actions ---
  String _currentTimeFormatted() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<String?> checkIn([String? customTime]) async {
    if (_hasCheckedInToday || _isSubmittingAttendance) return null;
    _isSubmittingAttendance = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nowStr = customTime ?? _currentTimeFormatted();
      final record = await checkInUseCase(nowStr);
      _attendanceHistory = [
        record,
        ..._attendanceHistory.where(
          (item) =>
              item.rawDate.year != record.rawDate.year ||
              item.rawDate.month != record.rawDate.month ||
              item.rawDate.day != record.rawDate.day,
        ),
      ];
      _syncTodayAttendanceState();
      return nowStr;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('CHECK IN ERROR: $_errorMessage');
      return null;
    } finally {
      _isSubmittingAttendance = false;
      notifyListeners();
    }
  }

  Future<bool> performCheckIn(String timeFormatted) async {
    final result = await checkIn(timeFormatted);
    return result != null;
  }

  Future<String?> checkOut([String? customTime]) async {
    if (!_hasCheckedInToday || _hasCheckedOutToday || _isSubmittingAttendance) {
      return null;
    }
    _isSubmittingAttendance = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nowStr = customTime ?? _currentTimeFormatted();
      final updated = await checkOutUseCase(nowStr);
      _attendanceHistory = _attendanceHistory.map((item) {
        final isSameDay =
            item.rawDate.year == updated.rawDate.year &&
            item.rawDate.month == updated.rawDate.month &&
            item.rawDate.day == updated.rawDate.day;
        return isSameDay ? updated : item;
      }).toList();
      _syncTodayAttendanceState();
      return nowStr;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('CHECK OUT ERROR: $_errorMessage');
      return null;
    } finally {
      _isSubmittingAttendance = false;
      notifyListeners();
    }
  }

  Future<bool> performCheckOut(String timeFormatted) async {
    final result = await checkOut(timeFormatted);
    return result != null;
  }

  Future<bool> submitLeave({
    required String type,
    required String dateRange,
    required int days,
    required String reason,
  }) async {
    _isSubmittingLeave = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await submitLeaveRequestUseCase(
        type: type,
        dateRange: dateRange,
        days: days,
        reason: reason,
      );
      _leaveRequests = [created, ..._leaveRequests];
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('SUBMIT LEAVE ERROR: $_errorMessage');
      return false;
    } finally {
      _isSubmittingLeave = false;
      notifyListeners();
    }
  }

  void selectPayslipIndex(int index) {
    if (index >= 0 && index < _payslips.length) {
      _selectedPayslipIndex = index;
      notifyListeners();
    }
  }

  Future<bool> updatePhoneNumber(String newPhone) async {
    _isUpdatingPhone = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await updatePhoneNumberUseCase(newPhone);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('UPDATE PHONE ERROR: $_errorMessage');
      return false;
    } finally {
      _isUpdatingPhone = false;
      notifyListeners();
    }
  }
}
