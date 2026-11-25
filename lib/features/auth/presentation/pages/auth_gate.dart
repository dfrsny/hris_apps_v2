import 'package:material_ui/material_ui.dart';

import 'package:hris_apps/features/auth/domain/entities/user_entity.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';
import 'package:hris_apps/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hris_apps/features/auth/presentation/pages/dashboards.dart';
import 'package:hris_apps/features/auth/presentation/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = controller.user;
        if (user == null) {
          return LoginPage(controller: controller);
        }
        return _dashboardFor(user);
      },
    );
  }

  Widget _dashboardFor(UserEntity user) {
    void onLogout() => controller.signOut();

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
 