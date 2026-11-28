import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/features/auth/presentation/widgets/dashboard_scaffold.dart';
import 'package:hris_apps/features/finance/data/datasources/finance_remote_datasource.dart';
import 'package:hris_apps/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:hris_apps/features/finance/domain/usecases/finalize_payroll_batch_usecase.dart';
import 'package:hris_apps/features/finance/domain/usecases/get_payroll_batches_usecase.dart';
import 'package:hris_apps/features/finance/domain/usecases/run_payroll_batch_usecase.dart';
import 'package:hris_apps/features/finance/presentation/providers/finance_provider.dart';
import 'package:hris_apps/features/finance/presentation/widgets/attendance_summary_tab.dart';
import 'package:hris_apps/features/finance/presentation/widgets/payroll_process_tab.dart';
import 'package:hris_apps/features/finance/presentation/widgets/payroll_report_tab.dart';

class FinanceDashboardPage extends StatelessWidget {
  const FinanceDashboardPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FinanceProvider>(
      create: (_) {
        final dataSource = FinanceRemoteDataSourceImpl(
          supabaseClient: Supabase.instance.client,
        );
        final repository = FinanceRepositoryImpl(remoteDataSource: dataSource);

        return FinanceProvider(
          getPayrollBatchesUseCase: GetPayrollBatchesUseCase(repository),
          runPayrollBatchUseCase: RunPayrollBatchUseCase(repository),
          finalizePayrollBatchUseCase: FinalizePayrollBatchUseCase(repository),
        )..loadBatches();
      },
      child: DashboardScaffold(
        title: 'Finance',
        onLogout: onLogout,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize_rounded),
            label: 'Absensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payroll',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Laporan',
          ),
        ],
        pages: const [
          AttendanceSummaryTab(),
          PayrollProcessTab(),
          PayrollReportTab(),
        ],
      ),
    );
  }
}
