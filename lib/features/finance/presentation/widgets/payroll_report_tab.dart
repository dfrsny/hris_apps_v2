import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';
import 'package:hris_apps/features/finance/presentation/providers/finance_provider.dart';
import 'package:hris_apps/features/finance/presentation/utils/currency_formatter.dart';
import 'package:hris_apps/features/finance/presentation/widgets/finance_period_selector_card.dart';
import 'package:hris_apps/features/finance/presentation/widgets/finance_summary_line.dart';

class PayrollReportTab extends StatelessWidget {
  const PayrollReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<FinanceProvider>();
    final batch = provider.currentBatch;

    if (provider.isLoading || batch == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: provider.loadBatches,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.paddingPage,
        children: [
          const FinancePeriodSelectorCard(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan Payroll • ${batch.period}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'Ringkasan distribusi biaya gaji per departemen',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppDimensions.gap8,
              OutlinedButton.icon(
                onPressed: batch.status == PayrollStatus.draft
                    ? null
                    : () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                'Mengunduh laporan ringkasan payroll ${batch.period}...',
                              ),
                            ),
                          );
                      },
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Unduh Laporan'),
              ),
            ],
          ),
          AppDimensions.gap16,
          Card(
            color: colors.primaryContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: AppDimensions.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Periode ${batch.period}',
                    style: theme.textTheme.titleSmall,
                  ),
                  AppDimensions.gap10,
                  FinanceSummaryLine(
                    label: 'Total Karyawan',
                    value: '${batch.totalEmployees} orang',
                  ),
                  AppDimensions.gap6,
                  FinanceSummaryLine(
                    label: 'Total Bruto',
                    value: formatRupiah(batch.grandTotalGross),
                  ),
                  AppDimensions.gap6,
                  FinanceSummaryLine(
                    label: 'Total Potongan',
                    value: formatRupiah(batch.grandTotalDeduction),
                  ),
                  AppDimensions.gap10,
                  const Divider(),
                  AppDimensions.gap10,
                  FinanceSummaryLine(
                    label: 'Total Netto Dibayarkan',
                    value: formatRupiah(batch.grandTotalNet),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          AppDimensions.gap20,
          Text('Rincian per Departemen', style: theme.textTheme.titleSmall),
          AppDimensions.gap8,
          ...batch.departmentPayrolls.map(
            (dept) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space10),
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
                          Chip(
                            label: Text('${dept.employeeCount} orang'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      AppDimensions.gap8,
                      const Divider(),
                      AppDimensions.gap8,
                      FinanceSummaryLine(
                        label: 'Total Gaji Pokok',
                        value: formatRupiah(dept.totalBaseSalary),
                      ),
                      AppDimensions.gap4,
                      FinanceSummaryLine(
                        label: 'Total Tunjangan',
                        value: formatRupiah(dept.totalAllowance),
                      ),
                      AppDimensions.gap4,
                      FinanceSummaryLine(
                        label: 'Total Potongan',
                        value: '- ${formatRupiah(dept.totalDeduction)}',
                        valueColor: AppColors.error,
                      ),
                      AppDimensions.gap8,
                      const Divider(),
                      AppDimensions.gap8,
                      FinanceSummaryLine(
                        label: 'Subtotal Departemen',
                        value: formatRupiah(dept.totalNetPayout),
                        isBold: true,
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
