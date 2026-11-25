import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) =>
      DashboardScaffold(title: 'Super Admin', onLogout: onLogout);
}

class HrDashboardPage extends StatelessWidget {
  const HrDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) =>
      DashboardScaffold(title: 'HR', onLogout: onLogout);
}

class FinanceDashboardPage extends StatelessWidget {
  const FinanceDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) =>
      DashboardScaffold(title: 'Finance', onLogout: onLogout);
}

class EmployeeDashboardPage extends StatelessWidget {
  const EmployeeDashboardPage({
    super.key,
    required this.onLogout,
    required this.isLead,
  });

  final VoidCallback onLogout;
  final bool isLead;

  @override
  Widget build(BuildContext context) => DashboardScaffold(
    title: isLead ? 'Karyawan (Lead)' : 'Karyawan',
    onLogout: onLogout,
    // Bagian khusus Lead (tim dan persetujuan cuti) ditambahkan di M3 dan M4
  );
}
