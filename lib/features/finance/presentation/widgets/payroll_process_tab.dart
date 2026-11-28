import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/finance/domain/entities/monthly_payroll_batch.dart';
import 'package:hris_apps/features/finance/presentation/providers/finance_provider.dart';
import 'package:hris_apps/features/finance/presentation/utils/currency_formatter.dart';
import 'package:hris_apps/features/finance/presentation/widgets/finance_period_selector_card.dart';
import 'package:hris_apps/features/finance/presentation/widgets/finance_summary_line.dart';

class PayrollProcessTab extends StatelessWidget {
  const PayrollProcessTab({super.key});

  Future<void> _confirmAndRunPayroll(
    BuildContext context,
    MonthlyPayrollBatch batch,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jalankan Proses Payroll'),
        content: Text(
          'Sistem akan menghitung payroll bulanan periode ${batch.period} untuk ${batch.totalEmployees} karyawan berdasarkan rekap absensi M3 dan membuat laporan ringkasan.\n\nLanjutkan proses?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Jalankan Payroll'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context
        .read<FinanceProvider>()
        .runPayrollForCurrentPeriod();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? null : AppColors.error,
          content: Text(
            success
                ? 'Payroll periode ${batch.period} selesai diproses & laporan dibuat.'
                : 'Gagal memproses payroll periode ${batch.period}.',
          ),
        ),
      );
  }

  Future<void> _finalizePayroll(
    BuildContext context,
    MonthlyPayrollBatch batch,
  ) async {
    final success = await context
        .read<FinanceProvider>()
        .finalizeCurrentPayroll();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? null : AppColors.error,
          content: Text(
            success
                ? 'Laporan payroll ${batch.period} telah dikunci (Final).'
                : 'Gagal mengunci laporan payroll.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<FinanceProvider>();
    final batch = provider.currentBatch;

    if (provider.isLoading || batch == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isLocked = batch.status == PayrollStatus.finalized;

    return RefreshIndicator(
      onRefresh: provider.loadBatches,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.paddingPage,
        children: [
          const FinancePeriodSelectorCard(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eksekusi Payroll • ${batch.period}',
                    style: theme.textTheme.titleMedium,
                  ),
                  AppDimensions.gap4,
                  Text(
                    batch.processedAt != null
                        ? 'Terakhir diproses: ${batch.processedAt}'
                        : 'Menunggu eksekusi kalkulasi bulanan.',
                    style: theme.textTheme.bodySmall,
                  ),
                  AppDimensions.gap12,
                  const Divider(),
                  AppDimensions.gap12,
                  FinanceSummaryLine(
                    label: 'Jumlah Karyawan Terhitung',
                    value: '${batch.totalEmployees} orang',
                  ),
                  AppDimensions.gap8,
                  FinanceSummaryLine(
                    label: 'Total Gaji Kotor & Tunjangan',
                    value: formatRupiah(batch.grandTotalGross),
                  ),
                  AppDimensions.gap8,
                  FinanceSummaryLine(
                    label: 'Total Potongan (BPJS, Pajak, Absensi)',
                    value: '- ${formatRupiah(batch.grandTotalDeduction)}',
                    valueColor: AppColors.error,
                  ),
                  AppDimensions.gap12,
                  const Divider(),
                  AppDimensions.gap12,
                  FinanceSummaryLine(
                    label: 'Total Pengeluaran Gaji Bersih',
                    value: formatRupiah(batch.grandTotalNet),
                    isBold: true,
                  ),
                  AppDimensions.gap20,
                  if (!isLocked)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: provider.isRunningPayroll
                                ? null
                                : () => _confirmAndRunPayroll(context, batch),
                            icon: provider.isRunningPayroll
                                ? SizedBox(
                                    width: AppDimensions.iconSm,
                                    height: AppDimensions.iconSm,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.play_arrow_rounded),
                            label: Text(
                              batch.status == PayrollStatus.draft
                                  ? 'Proses Payroll'
                                  : 'Hitung Ulang Payroll',
                            ),
                          ),
                        ),
                        if (batch.status == PayrollStatus.processed) ...[
                          AppDimensions.gap12,
                          OutlinedButton.icon(
                            onPressed: provider.isFinalizingPayroll
                                ? null
                                : () => _finalizePayroll(context, batch),
                            icon: const Icon(
                              Icons.lock_outline_rounded,
                              size: AppDimensions.iconSm,
                            ),
                            label: const Text('Kunci Laporan'),
                          ),
                        ],
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: AppDimensions.paddingCardCompact,
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: AppDimensions.borderRadiusSm,
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                          ),
                          AppDimensions.gap10,
                          Expanded(
                            child: Text(
                              'Payroll periode ${batch.period} telah difinalisasi dan laporan siap diunduh pada menu Laporan.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
