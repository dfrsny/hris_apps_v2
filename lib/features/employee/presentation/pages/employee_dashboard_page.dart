import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';
import 'package:hris_apps/features/employee/data/datasources/employee_remote_datasource.dart';
import 'package:hris_apps/features/employee/data/repositories/employee_repository_impl.dart';
import 'package:hris_apps/features/employee/domain/usecases/check_in_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/check_out_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_attendance_history_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_employee_profile_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_leave_requests_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/get_payslips_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/submit_leave_request_usecase.dart';
import 'package:hris_apps/features/employee/domain/usecases/update_phone_number_usecase.dart';
import 'package:hris_apps/features/employee/presentation/providers/employee_provider.dart';
import 'package:hris_apps/features/employee/presentation/widgets/attendance_tab.dart';
import 'package:hris_apps/features/employee/presentation/widgets/leave_tab.dart';
import 'package:hris_apps/features/employee/presentation/widgets/payslip_tab.dart';
import 'package:hris_apps/features/employee/presentation/widgets/profile_tab.dart';

class EmployeeDashboardPage extends StatelessWidget {
  const EmployeeDashboardPage({
    super.key,
    required this.onLogout,
    required this.isLead,
  });

  final VoidCallback onLogout;
  final bool isLead;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmployeeProvider>(
      create: (_) {
        final dataSource = EmployeeRemoteDataSourceImpl(
          supabaseClient: Supabase.instance.client,
        );
        final repository = EmployeeRepositoryImpl(remoteDataSource: dataSource);

        return EmployeeProvider(
          getEmployeeProfileUseCase: GetEmployeeProfileUseCase(repository),
          updatePhoneNumberUseCase: UpdatePhoneNumberUseCase(repository),
          getAttendanceHistoryUseCase: GetAttendanceHistoryUseCase(repository),
          checkInUseCase: CheckInUseCase(repository),
          checkOutUseCase: CheckOutUseCase(repository),
          getLeaveRequestsUseCase: GetLeaveRequestsUseCase(repository),
          submitLeaveRequestUseCase: SubmitLeaveRequestUseCase(repository),
          getPayslipsUseCase: GetPayslipsUseCase(repository),
        )..initializeDashboard();
      },
      child: DashboardScaffold(
        title: isLead ? 'Karyawan (Lead)' : 'Karyawan',
        onLogout: onLogout,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fingerprint_outlined),
            selectedIcon: Icon(Icons.fingerprint_rounded),
            label: 'Absensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Cuti',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Slip Gaji',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
        pages: [
          AttendanceTab(isLead: isLead),
          LeaveTab(isLead: isLead),
          const PayslipTab(),
          const ProfileTab(),
        ],
      ),
    );
  }
}
