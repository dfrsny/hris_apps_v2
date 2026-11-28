import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/employee/presentation/providers/employee_provider.dart';

class EditPhoneDialog extends StatefulWidget {
  final String initialPhone;

  const EditPhoneDialog({super.key, required this.initialPhone});

  static Future<void> show(BuildContext context, String currentPhone) {
    final employeeProvider = context.read<EmployeeProvider>();
    return showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider<EmployeeProvider>.value(
        value: employeeProvider,
        child: EditPhoneDialog(initialPhone: currentPhone),
      ),
    );
  }

  @override
  State<EditPhoneDialog> createState() => _EditPhoneDialogState();
}

class _EditPhoneDialogState extends State<EditPhoneDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<EmployeeProvider>().updatePhoneNumber(
      _phoneCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Nomor telepon berhasil diperbarui.')),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Gagal memperbarui nomor telepon.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUpdating = context.select<EmployeeProvider, bool>(
      (p) => p.isUpdatingPhone,
    );

    return AlertDialog(
      title: const Text('Ubah Nomor Telepon'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Nomor Telepon Aktif',
            prefixIcon: Icon(Icons.phone_outlined, size: AppDimensions.iconMd),
          ),
          validator: (val) {
            if (val == null || val.trim().length < 10) {
              return 'Masukkan nomor telepon yang valid (min. 10 digit)';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUpdating ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: isUpdating ? null : _submit,
          child: isUpdating
              ? SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
