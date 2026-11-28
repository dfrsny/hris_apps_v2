import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:hris_apps/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:hris_apps/features/admin/domain/usecases/create_account_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/get_accounts_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/get_system_settings_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/update_account_role_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/update_account_status_usecase.dart';
import 'package:hris_apps/features/admin/domain/usecases/update_system_settings_usecase.dart';
import 'package:hris_apps/features/admin/presentation/providers/admin_provider.dart';
import 'package:hris_apps/features/admin/presentation/widgets/account_management_tab.dart';
import 'package:hris_apps/features/admin/presentation/widgets/system_settings_tab.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminProvider>(
      create: (_) {
        final dataSource = AdminRemoteDataSourceImpl(
          supabaseClient: Supabase.instance.client,
        );
        final repository = AdminRepositoryImpl(remoteDataSource: dataSource);

        return AdminProvider(
          getAccountsUseCase: GetAccountsUseCase(repository),
          createAccountUseCase: CreateAccountUseCase(repository),
          updateAccountRoleUseCase: UpdateAccountRoleUseCase(repository),
          updateAccountStatusUseCase: UpdateAccountStatusUseCase(repository),
          getSystemSettingsUseCase: GetSystemSettingsUseCase(repository),
          updateSystemSettingsUseCase: UpdateSystemSettingsUseCase(repository),
        )..initializeDashboard();
      },
      child: DashboardScaffold(
        title: 'Super Admin',
        onLogout: onLogout,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_rounded),
            label: 'Akun',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Sistem',
          ),
        ],
        pages: const [AccountManagementTab(), SystemSettingsTab()],
      ),
    );
  }
}
