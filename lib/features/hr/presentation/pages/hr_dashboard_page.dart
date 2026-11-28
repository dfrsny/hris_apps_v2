import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';
import 'package:hris_apps/features/hr/data/datasources/hr_remote_datasource.dart';
import 'package:hris_apps/features/hr/data/repositories/hr_repository_impl.dart';
import 'package:hris_apps/features/hr/domain/usecases/assign_manager_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/decide_leave_request_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/get_all_attendance_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/get_all_leaves_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/get_hr_employees_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/save_employee_profile_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/toggle_employee_status_usecase.dart';
import 'package:hris_apps/features/hr/domain/usecases/update_salary_components_usecase.dart';
import 'package:hris_apps/features/hr/presentation/providers/hr_provider.dart';
import 'package:hris_apps/features/hr/presentation/widgets/hr_attendance_tab.dart';
import 'package:hris_apps/features/hr/presentation/widgets/hr_employees_tab.dart';
import 'package:hris_apps/features/hr/presentation/widgets/hr_leaves_tab.dart';
import 'package:hris_apps/features/hr/presentation/widgets/hr_payroll_tab.dart';

class HrDashboardPage extends StatelessWidget {
  const HrDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HrProvider>(
      create: (_) {
        final dataSource = HrRemoteDataSourceImpl(
          supabaseClient: Supabase.instance.client,
        );
        final repository = HrRepositoryImpl(remoteDataSource: dataSource);

        return HrProvider(
          getHrEmployeesUseCase: GetHrEmployeesUseCase(repository),
          saveEmployeeProfileUseCase: SaveEmployeeProfileUseCase(repository),
          toggleEmployeeStatusUseCase: ToggleEmployeeStatusUseCase(repository),
          assignManagerUseCase: AssignManagerUseCase(repository),
          updateSalaryComponentsUseCase: UpdateSalaryComponentsUseCase(
            repository,
          ),
          getAllAttendanceUseCase: GetAllAttendanceUseCase(repository),
          getAllLeavesUseCase: GetAllLeavesUseCase(repository),
          decideLeaveRequestUseCase: DecideLeaveRequestUseCase(repository),
        )..initializeDashboard();
      },
      child: DashboardScaffold(
        title: 'HR',
        onLogout: onLogout,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Karyawan',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'Absensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available_rounded),
            label: 'Cuti',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payroll',
          ),
        ],
        pages: const [
          HrEmployeesTab(),
          HrAttendanceTab(),
          HrLeavesTab(),
          HrPayrollTab(),
        ],
      ),
    );
  }
}
