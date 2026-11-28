import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/presentation/providers/hr_provider.dart';

class HrPayrollTab extends StatelessWidget {
  const HrPayrollTab({super.key});

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

  Future<void> _showSalaryComponentDialog(
    BuildContext context,
    HrEmployeeRecord emp,
  ) async {
    final provider = context.read<HrProvider>();
    final formKey = GlobalKey<FormState>();
    final baseCtrl = TextEditingController(text: emp.baseSalary.toString());
    final allowCtrl = TextEditingController(text: emp.allowance.toString());
    final deductCtrl = TextEditingController(text: emp.deduction.toString());

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Komponen Gaji • ${emp.fullName}'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxFormWidth,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: baseCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Gaji Pokok (Rp)',
                  ),
                  validator: (v) => (int.tryParse(v ?? '') == null)
                      ? 'Masukkan angka valid'
                      : null,
                ),
                AppDimensions.gap12,
                TextFormField(
                  controller: allowCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tunjangan Tetap (Rp)',
                  ),
                  validator: (v) => (int.tryParse(v ?? '') == null)
                      ? 'Masukkan angka valid'
                      : null,
                ),
                AppDimensions.gap12,
                TextFormField(
                  controller: deductCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Potongan (BPJS/Pajak) (Rp)',
                  ),
                  validator: (v) => (int.tryParse(v ?? '') == null)
                      ? 'Masukkan angka valid'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await provider.updateSalaryComponents(
                employeeId: emp.id,
                baseSalary: int.parse(baseCtrl.text),
                allowance: int.parse(allowCtrl.text),
                deduction: int.parse(deductCtrl.text),
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    backgroundColor: ok ? null : AppColors.error,
                    content: Text(
                      ok
                          ? 'Komponen gaji ${emp.fullName} berhasil disimpan.'
                          : 'Gagal menyimpan komponen gaji.',
                    ),
                  ),
                );
            },
            child: const Text('Simpan Komponen'),
          ),
        ],
      ),
    );
  }

  void _showPayslipPreviewDialog(
    BuildContext context,
    HrEmployeeRecord emp,
    String period,
  ) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Slip Gaji • $period'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxFormWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${emp.fullName} (${emp.position})',
                style: theme.textTheme.titleSmall,
              ),
              const Gap(AppDimensions.space2),
              Text(
                'Rekening: ${emp.bankAccount}',
                style: theme.textTheme.bodySmall,
              ),
              AppDimensions.gap10,
              const Divider(),
              AppDimensions.gap10,
              _SalaryLine(
                label: 'Gaji Pokok',
                val: _formatRupiah(emp.baseSalary),
              ),
              AppDimensions.gap6,
              _SalaryLine(
                label: 'Tunjangan',
                val: _formatRupiah(emp.allowance),
              ),
              AppDimensions.gap6,
              _SalaryLine(
                label: 'Potongan',
                val: '- ${_formatRupiah(emp.deduction)}',
                color: AppColors.error,
              ),
              AppDimensions.gap10,
              const Divider(),
              AppDimensions.gap10,
              _SalaryLine(
                label: 'Take Home Pay',
                val: _formatRupiah(emp.netSalary),
                isBold: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HrProvider>();

    return Padding(
      padding: AppDimensions.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;
              final headerInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Komponen Gaji & Slip Karyawan (M5)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Gap(AppDimensions.space2),
                  Text(
                    'Atur gaji pokok, tunjangan, potongan, serta tinjau slip gaji per karyawan',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );

              final periodDropdown = DropdownButtonFormField<String>(
                initialValue: provider.selectedPayrollPeriod,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Periode Slip'),
                items: const [
                  DropdownMenuItem(
                    value: 'November 2026',
                    child: Text('November 2026'),
                  ),
                  DropdownMenuItem(
                    value: 'Oktober 2026',
                    child: Text('Oktober 2026'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) provider.setSelectedPayrollPeriod(val);
                },
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [headerInfo, AppDimensions.gap10, periodDropdown],
                );
              }

              return Row(
                children: [
                  Expanded(child: headerInfo),
                  AppDimensions.gap12,
                  SizedBox(width: 185, child: periodDropdown),
                ],
              );
            },
          ),
          AppDimensions.gap12,
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadEmployees,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: provider.employees.length,
                separatorBuilder: (_, _) => AppDimensions.gap8,
                itemBuilder: (context, index) {
                  final emp = provider.employees[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      emp.fullName,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const Gap(AppDimensions.space2),
                                    Text(
                                      '${emp.position} • ${emp.department}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              AppDimensions.gap12,
                              Text(
                                _formatRupiah(emp.netSalary),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          AppDimensions.gap8,
                          Text(
                            'Pokok: ${_formatRupiah(emp.baseSalary)}  •  Tunjangan: ${_formatRupiah(emp.allowance)}  •  Potongan: ${_formatRupiah(emp.deduction)}',
                            style: theme.textTheme.bodySmall,
                          ),
                          AppDimensions.gap10,
                          const Divider(),
                          AppDimensions.gap10,
                          Wrap(
                            spacing: AppDimensions.space8,
                            runSpacing: AppDimensions.space8,
                            alignment: WrapAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showPayslipPreviewDialog(
                                  context,
                                  emp,
                                  provider.selectedPayrollPeriod,
                                ),
                                icon: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: AppDimensions.iconSm,
                                ),
                                label: const Text('Lihat Slip Gaji'),
                              ),
                              FilledButton.icon(
                                onPressed: () =>
                                    _showSalaryComponentDialog(context, emp),
                                icon: const Icon(
                                  Icons.tune_rounded,
                                  size: AppDimensions.iconSm,
                                ),
                                label: const Text('Atur Komponen'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryLine extends StatelessWidget {
  final String label;
  final String val;
  final bool isBold;
  final Color? color;

  const _SalaryLine({
    required this.label,
    required this.val,
    this.isBold = false,
    this.color,
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
            style: isBold
                ? theme.textTheme.titleSmall
                : theme.textTheme.bodyMedium,
          ),
        ),
        AppDimensions.gap12,
        Text(
          val,
          style:
              (isBold
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ))
                  ?.copyWith(color: color),
        ),
      ],
    );
  }
}
