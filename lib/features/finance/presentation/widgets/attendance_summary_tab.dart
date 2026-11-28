import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/finance/presentation/providers/finance_provider.dart';
import 'package:hris_apps/features/finance/presentation/widgets/finance_period_selector_card.dart';
import 'package:hris_apps/features/finance/presentation/widgets/finance_scope_notice_banner.dart';

class AttendanceSummaryTab extends StatelessWidget {
  const AttendanceSummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<FinanceProvider>();
    final batch = provider.currentBatch;

    if (provider.isLoading || batch == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final summaries = batch.attendanceSummaries;
    final totalEmployees = summaries.fold(
      0,
      (sum, item) => sum + item.activeEmployees,
    );
    final totalWorkDays = summaries.fold(
      0,
      (sum, item) => sum + item.totalWorkDays,
    );
    final totalLate = summaries.fold(
      0,
      (sum, item) => sum + item.totalLateCount,
    );
    final totalUnpaidLeave = summaries.fold(
      0,
      (sum, item) => sum + item.totalUnpaidLeaveDays,
    );

    return RefreshIndicator(
      onRefresh: provider.loadBatches,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.paddingPage,
        children: [
          const FinanceScopeNoticeBanner(),
          const FinancePeriodSelectorCard(),
          Text(
            'Ringkasan Kehadiran Periode ${batch.period}',
            style: theme.textTheme.titleMedium,
          ),
          AppDimensions.gap4,
          Text(
            'Data agregat untuk komponen kalkulasi payroll (tidak memuat log jam masuk/pulang harian individu).',
            style: theme.textTheme.bodySmall,
          ),
          AppDimensions.gap16,
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Karyawan Aktif',
                  value: '$totalEmployees',
                  icon: Icons.people_outline_rounded,
                  color: colors.primary,
                ),
              ),
              AppDimensions.gap10,
              Expanded(
                child: _MetricCard(
                  title: 'Total Hari Kerja',
                  value: '$totalWorkDays hr',
                  icon: Icons.event_available_outlined,
                  color: colors.secondary,
                ),
              ),
            ],
          ),
          AppDimensions.gap10,
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Keterlambatan',
                  value: '$totalLate kali',
                  icon: Icons.schedule_outlined,
                  color: AppColors.warning,
                ),
              ),
              AppDimensions.gap10,
              Expanded(
                child: _MetricCard(
                  title: 'Cuti Tanpa Upah',
                  value: '$totalUnpaidLeave hr',
                  icon: Icons.event_busy_outlined,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          AppDimensions.gap20,
          Text(
            'Rekapitulasi per Departemen',
            style: theme.textTheme.titleSmall,
          ),
          AppDimensions.gap8,
          ...summaries.map(
            (dept) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dept.department,
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            '${dept.activeEmployees} karyawan',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      AppDimensions.gap8,
                      const Divider(),
                      AppDimensions.gap8,
                      Wrap(
                        spacing: AppDimensions.space12,
                        runSpacing: AppDimensions.space4,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hari Hadir: ${dept.totalWorkDays}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'Terlambat: ${dept.totalLateCount}x',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'Unpaid Leave: ${dept.totalUnpaidLeaveDays} hr',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppDimensions.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconMd),
          AppDimensions.gap8,
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(AppDimensions.space2),
          Text(title, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
