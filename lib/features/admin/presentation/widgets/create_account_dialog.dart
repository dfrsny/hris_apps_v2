import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/admin/presentation/extensions/user_role_ui_ext.dart';
import 'package:hris_apps/features/admin/presentation/providers/admin_provider.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class CreateAccountDialog extends StatefulWidget {
  const CreateAccountDialog({super.key});

  static Future<void> show(BuildContext context) {
    final adminProvider = context.read<AdminProvider>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider<AdminProvider>.value(
        value: adminProvider,
        child: const CreateAccountDialog(),
      ),
    );
  }

  @override
  State<CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.employee;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AdminProvider>();
    final email = _emailCtrl.text.trim();
    final role = _selectedRole;

    final success = await provider.createAccount(
      displayName: _nameCtrl.text,
      email: email,
      password: _passwordCtrl.text,
      role: role,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Akun $email (${role.label}) berhasil dibuat.'),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              provider.errorMessage ?? 'Gagal membuat akun. Silakan coba lagi.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isCreating = context.select<AdminProvider, bool>(
      (p) => p.isCreatingAccount,
    );

    return AlertDialog(
      title: const Text('Buat Akun Baru'),
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
                Container(
                  padding: AppDimensions.paddingBanner,
                  decoration: BoxDecoration(
                    color: AppColors.infoSurface,
                    borderRadius: AppDimensions.borderRadiusSm,
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.info,
                      ),
                      AppDimensions.gap8,
                      Expanded(
                        child: Text(
                          'Akun dibuat lewat Edge Function. Role Super Admin hanya dapat diberikan melalui SQL manual.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppDimensions.gap16,
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tampilan Akun',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                AppDimensions.gap12,
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Login',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || !val.contains('@')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                AppDimensions.gap12,
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password Sementara',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: AppDimensions.iconMd,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: AppDimensions.iconMd,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (val) => (val == null || val.length < 8)
                      ? 'Minimal 8 karakter'
                      : null,
                ),
                AppDimensions.gap12,
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role Akses',
                    prefixIcon: Icon(
                      Icons.admin_panel_settings_outlined,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                  items: kManageableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.label),
                    );
                  }).toList(),
                  onChanged: isCreating
                      ? null
                      : (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isCreating ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: isCreating ? null : _submit,
          icon: isCreating
              ? SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : const Icon(
                  Icons.person_add_rounded,
                  size: AppDimensions.iconSm,
                ),
          label: const Text('Buat Akun'),
        ),
      ],
    );
  }
}
