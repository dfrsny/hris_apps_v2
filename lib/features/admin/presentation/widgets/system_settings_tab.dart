import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/admin/presentation/providers/admin_provider.dart';

class SystemSettingsTab extends StatefulWidget {
  const SystemSettingsTab({super.key});

  @override
  State<SystemSettingsTab> createState() => _SystemSettingsTabState();
}

class _SystemSettingsTabState extends State<SystemSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  TimeOfDay _clockInTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _clockOutTime = const TimeOfDay(hour: 17, minute: 30);
  bool _hasSyncedInitialData = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime({required bool isClockIn}) async {
    final initial = isClockIn ? _clockInTime : _clockOutTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isClockIn) {
          _clockInTime = picked;
        } else {
          _clockOutTime = picked;
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AdminProvider>().saveSystemSettings(
      companyName: _companyNameController.text,
      clockIn: _clockInTime,
      clockOut: _clockOutTime,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? null : AppColors.error,
          content: Text(
            success
                ? 'Pengaturan sistem berhasil diperbarui.'
                : 'Gagal menyimpan pengaturan sistem.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<AdminProvider>();

    if (provider.isLoadingSettings && !_hasSyncedInitialData) {
      return const Center(child: CircularProgressIndicator());
    }

    final settings = provider.systemSettings;
    if (settings != null && !_hasSyncedInitialData) {
      _companyNameController.text = settings.companyName;
      _clockInTime = TimeOfDay(
        hour: settings.clockInHour,
        minute: settings.clockInMinute,
      );
      _clockOutTime = TimeOfDay(
        hour: settings.clockOutHour,
        minute: settings.clockOutMinute,
      );
      _hasSyncedInitialData = true;
    }

    return SingleChildScrollView(
      padding: AppDimensions.paddingPage,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfigurasi Perusahaan & Jam Kerja',
                      style: theme.textTheme.titleMedium,
                    ),
                    AppDimensions.gap4,
                    Text(
                      'Pengaturan dasar sistem yang berlaku secara global.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const Gap(AppDimensions.space14),
                    const Divider(),
                    const Gap(AppDimensions.space14),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Perusahaan',
                        prefixIcon: Icon(
                          Icons.business_outlined,
                          size: AppDimensions.iconMd,
                        ),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Nama perusahaan tidak boleh kosong'
                          : null,
                    ),
                    AppDimensions.gap20,
                    Text(
                      'Standar Jam Kerja Operasional',
                      style: theme.textTheme.titleSmall,
                    ),
                    AppDimensions.gap10,
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isClockIn: true),
                            borderRadius: AppDimensions.borderRadiusSm,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Masuk',
                                prefixIcon: Icon(
                                  Icons.login_rounded,
                                  size: AppDimensions.iconMd,
                                ),
                              ),
                              child: Text(
                                _formatTime(_clockInTime),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        AppDimensions.gap16,
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isClockIn: false),
                            borderRadius: AppDimensions.borderRadiusSm,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Pulang',
                                prefixIcon: Icon(
                                  Icons.logout_rounded,
                                  size: AppDimensions.iconMd,
                                ),
                              ),
                              child: Text(
                                _formatTime(_clockOutTime),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppDimensions.gap24,
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: provider.isSavingSettings
                            ? null
                            : _saveSettings,
                        icon: provider.isSavingSettings
                            ? SizedBox(
                                width: AppDimensions.iconSm,
                                height: AppDimensions.iconSm,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                                size: AppDimensions.iconSm,
                              ),
                        label: const Text('Simpan Pengaturan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
