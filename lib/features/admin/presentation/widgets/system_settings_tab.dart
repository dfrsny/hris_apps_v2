import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? null : Colors.red,
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
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfigurasi Perusahaan & Jam Kerja',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pengaturan dasar sistem yang berlaku secara global.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Divider(height: 28),
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Perusahaan',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Nama perusahaan tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Standar Jam Kerja Operasional',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isClockIn: true),
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Masuk',
                                prefixIcon: Icon(Icons.login_outlined),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(_clockInTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(isClockIn: false),
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Jam Pulang',
                                prefixIcon: Icon(Icons.logout_outlined),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(_clockOutTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: provider.isSavingSettings
                            ? null
                            : _saveSettings,
                        icon: provider.isSavingSettings
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
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
