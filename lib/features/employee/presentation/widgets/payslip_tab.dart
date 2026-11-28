import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/employee/presentation/providers/employee_provider.dart';

class PayslipTab extends StatelessWidget {
  const PayslipTab({super.key});

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<EmployeeProvider>();
    final currentSlip = provider.selectedPayslip;
    final profile = provider.profile;

    if (provider.isLoadingPayslips) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentSlip == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: colors.outline,
              ),
              AppDimensions.gap12,
              Text('Belum Ada Slip Gaji', style: theme.textTheme.titleMedium),
              AppDimensions.gap4,
              Text(
                'Slip gaji akan muncul di sini setelah Finance memproses penggajian bulanan Anda.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              AppDimensions.gap16,
              OutlinedButton.icon(
                onPressed: provider.loadPayslips,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadPayslips,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.paddingPage,
        children: [
          DropdownButtonFormField<int>(
            key: ValueKey('payslip-${provider.selectedPayslipIndex}'),
            initialValue: provider.selectedPayslipIndex,
            decoration: const InputDecoration(
              labelText: 'Pilih Periode Penggajian',
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
                size: AppDimensions.iconMd,
              ),
            ),
            items: List.generate(provider.payslips.length, (i) {
              return DropdownMenuItem(
                value: i,
                child: Text(provider.payslips[i].period),
              );
            }),
            onChanged: (val) {
              if (val != null) provider.selectPayslipIndex(val);
            },
          ),
          AppDimensions.gap16,
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slip Gaji • ${currentSlip.period}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Gap(AppDimensions.space2),
                  Text(
                    '${profile?.fullName ?? '-'} (${profile?.employeeId ?? '-'})',
                    style: theme.textTheme.bodySmall,
                  ),
                  AppDimensions.gap12,
                  const Divider(),
                  AppDimensions.gap12,
                  _SalaryRow(
                    label: 'Gaji Pokok',
                    value: _formatRupiah(currentSlip.baseSalary),
                  ),
                  AppDimensions.gap8,
                  _SalaryRow(
                    label: 'Tunjangan',
                    value: _formatRupiah(currentSlip.allowance),
                  ),
                  AppDimensions.gap8,
                  _SalaryRow(
                    label: 'Potongan (BPJS & Pajak)',
                    value: '- ${_formatRupiah(currentSlip.deduction)}',
                    valueColor: AppColors.error,
                  ),
                  AppDimensions.gap12,
                  const Divider(),
                  AppDimensions.gap12,
                  _SalaryRow(
                    label: 'Total Gaji Bersih (Take Home Pay)',
                    value: _formatRupiah(currentSlip.netSalary),
                    isTotal: true,
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

class _SalaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _SalaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? theme.textTheme.titleSmall
                : theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style:
              (isTotal
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ))
                  ?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
