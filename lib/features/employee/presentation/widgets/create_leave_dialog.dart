import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/employee/presentation/providers/employee_provider.dart';

class CreateLeaveDialog extends StatefulWidget {
  const CreateLeaveDialog({super.key});

  static Future<void> show(BuildContext context) {
    final employeeProvider = context.read<EmployeeProvider>();
    return showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider<EmployeeProvider>.value(
        value: employeeProvider,
        child: const CreateLeaveDialog(),
      ),
    );
  }

  @override
  State<CreateLeaveDialog> createState() => _CreateLeaveDialogState();
}

class _CreateLeaveDialogState extends State<CreateLeaveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  String _selectedType = 'Cuti Tahunan';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final totalDays = _endDate.difference(_startDate).inDays + 1;
    final dateRange = _startDate == _endDate
        ? _fmtDate(_startDate)
        : '${_fmtDate(_startDate)} - ${_fmtDate(_endDate)}';

    final provider = context.read<EmployeeProvider>();
    final success = await provider.submitLeave(
      type: _selectedType,
      dateRange: dateRange,
      days: totalDays,
      reason: _reasonCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Pengajuan cuti berhasil dikirim.')),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Gagal mengirim pengajuan cuti.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSubmitting = context.select<EmployeeProvider, bool>(
      (p) => p.isSubmittingLeave,
    );
    final totalDays = _endDate.difference(_startDate).inDays + 1;

    return AlertDialog(
      title: const Text('Ajukan Cuti'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxFormWidth,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Jenis Cuti'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Cuti Tahunan',
                      child: Text('Cuti Tahunan'),
                    ),
                    DropdownMenuItem(
                      value: 'Cuti Sakit',
                      child: Text('Cuti Sakit'),
                    ),
                    DropdownMenuItem(
                      value: 'Izin Khusus',
                      child: Text('Izin Khusus'),
                    ),
                  ],
                  onChanged: isSubmitting
                      ? null
                      : (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                ),
                AppDimensions.gap12,
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: AppDimensions.borderRadiusSm,
                        onTap: isSubmitting
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _startDate = picked;
                                    if (_endDate.isBefore(_startDate)) {
                                      _endDate = _startDate;
                                    }
                                  });
                                }
                              },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Mulai'),
                          child: Text(
                            _fmtDate(_startDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    AppDimensions.gap8,
                    Expanded(
                      child: InkWell(
                        borderRadius: AppDimensions.borderRadiusSm,
                        onTap: isSubmitting
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate,
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() => _endDate = picked);
                                }
                              },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Selesai',
                          ),
                          child: Text(
                            _fmtDate(_endDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppDimensions.gap8,
                Text(
                  'Durasi pengajuan: $totalDays hari',
                  style: theme.textTheme.bodySmall,
                ),
                AppDimensions.gap12,
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Alasan Cuti'),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Alasan wajib diisi'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: isSubmitting ? null : _submit,
          child: isSubmitting
              ? SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : const Text('Kirim Pengajuan'),
        ),
      ],
    );
  }
}
