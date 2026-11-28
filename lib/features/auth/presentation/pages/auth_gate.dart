import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/core/widgets/app_snackbar.dart';
import 'package:hris_apps/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:hris_apps/features/auth/domain/entities/user_entity.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';
import 'package:hris_apps/features/auth/presentation/pages/login_page.dart';
import 'package:hris_apps/features/auth/presentation/providers/auth_provider.dart';
import 'package:hris_apps/features/employee/presentation/pages/employee_dashboard_page.dart';
import 'package:hris_apps/features/finance/presentation/pages/finance_dashboard_page.dart';
import 'package:hris_apps/features/hr/presentation/pages/hr_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.provider});

  final AuthProvider provider;

  Future<void> _handleLogout(BuildContext context) async {
    final success = await provider.signOut();
    if (!context.mounted) return;

    if (success) {
      AppSnackbar.showInfo(
        context,
        title: 'Keluar Sesi',
        message: 'Anda telah keluar dari akun.',
      );
    } else {
      AppSnackbar.showError(
        context,
        title: 'Gagal Keluar',
        message: provider.errorMessage ?? 'Gagal mengakhiri sesi akun.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (!provider.isReady) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    child: Icon(
                      Icons.badge_rounded,
                      size: 30,
                      color: colors.primary,
                    ),
                  ),
                  AppDimensions.gap20,
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  AppDimensions.gap12,
                  Text('Memuat sesi akun...', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          );
        }

        final user = provider.user;
        if (user == null) {
          return LoginPage(provider: provider);
        }
        return _dashboardFor(context, user);
      },
    );
  }

  Widget _dashboardFor(BuildContext context, UserEntity user) {
    void onLogout() => _handleLogout(context);

    return switch (user.role) {
      UserRole.superAdmin => AdminDashboardPage(onLogout: onLogout),
      UserRole.hr => HrDashboardPage(onLogout: onLogout),
      UserRole.finance => FinanceDashboardPage(onLogout: onLogout),
      UserRole.employee => EmployeeDashboardPage(
        onLogout: onLogout,
        isLead: user.isLead,
      ),
    };
  }
}
