import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_employee_record.dart';
import 'package:hris_apps/features/hr/presentation/providers/hr_provider.dart';

class HrEmployeeDialogs {
  static Future<void> showEmployeeForm(
    BuildContext context, {
    HrEmployeeRecord? existing,
  }) async {
    final theme = Theme.of(context);
    final provider = context.read<HrProvider>();
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final deptCtrl = TextEditingController(
      text: existing?.department ?? 'Engineering',
    );
    final posCtrl = TextEditingController(text: existing?.position ?? '');
    final joinCtrl = TextEditingController(
      text:
          existing?.joinDate ??
          DateTime.now().toIso8601String().split('T').first,
    );
    bool isActive = existing?.isActive ?? true;

    final nikCtrl = TextEditingController(text: existing?.nik ?? '');
    final npwpCtrl = TextEditingController(text: existing?.npwp ?? '');
    final bankCtrl = TextEditingController(text: existing?.bankAccount ?? '');
    final addrCtrl = TextEditingController(text: existing?.address ?? '');
    final emergencyCtrl = TextEditingController(
      text: existing?.emergencyContact ?? '',
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Ubah Data Karyawan' : 'Tambah Karyawan Baru'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxDialogWidth,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Dasar Karyawan',
                      style: theme.textTheme.titleSmall,
                    ),
                    AppDimensions.gap10,
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Wajib diisi'
                          : null,
                    ),
                    AppDimensions.gap10,
                    TextFormField(
                      controller: emailCtrl,
                      enabled: !isEdit,
                      decoration: const InputDecoration(
                        labelText: 'Email Perusahaan',
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email tidak valid'
                          : null,
                    ),
                    AppDimensions.gap10,
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: deptCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Departemen',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                        AppDimensions.gap10,
                        Expanded(
                          child: TextFormField(
                            controller: posCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Jabatan',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    AppDimensions.gap10,
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: joinCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Masuk (YYYY-MM-DD)',
                            ),
                          ),
                        ),
                        AppDimensions.gap12,
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Status Aktif',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: isActive,
                            onChanged: (val) =>
                                setDialogState(() => isActive = val),
                          ),
                        ),
                      ],
                    ),
                    AppDimensions.gap12,
                    const Divider(),
                    AppDimensions.gap12,
                    Text(
                      'Data Sensitif & Administrasi (M2)',
                      style: theme.textTheme.titleSmall,
                    ),
                    AppDimensions.gap10,
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nikCtrl,
                            decoration: const InputDecoration(
                              labelText: 'NIK (16 digit)',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'NIK wajib diisi'
                                : null,
                          ),
                        ),
                        AppDimensions.gap10,
                        Expanded(
                          child: TextFormField(
                            controller: npwpCtrl,
                            decoration: const InputDecoration(
                              labelText: 'NPWP',
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppDimensions.gap10,
                    TextFormField(
                      controller: bankCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Rekening & Bank',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Rekening wajib diisi'
                          : null,
                    ),
                    AppDimensions.gap10,
                    TextFormField(
                      controller: addrCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Domisili',
                      ),
                    ),
                    AppDimensions.gap10,
                    TextFormField(
                      controller: emergencyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kontak Darurat',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Kontak darurat wajib diisi'
                          : null,
                    ),
                  ],
                ),
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
                final record = HrEmployeeRecord(
                  id: existing?.id ?? '',
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  department: deptCtrl.text.trim(),
                  position: posCtrl.text.trim(),
                  joinDate: joinCtrl.text.trim(),
                  isActive: isActive,
                  managerId: existing?.managerId,
                  nik: nikCtrl.text.trim(),
                  npwp: npwpCtrl.text.trim(),
                  bankAccount: bankCtrl.text.trim(),
                  address: addrCtrl.text.trim(),
                  emergencyContact: emergencyCtrl.text.trim(),
                  baseSalary: existing?.baseSalary ?? 6000000,
                  allowance: existing?.allowance ?? 500000,
                  deduction: existing?.deduction ?? 300000,
                );

                final ok = await provider.saveEmployee(record, isEdit: isEdit);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      backgroundColor: ok ? null : AppColors.error,
                      content: Text(
                        ok
                            ? (isEdit
                                  ? 'Data karyawan diperbarui.'
                                  : 'Karyawan baru ditambahkan.')
                            : (provider.errorMessage ??
                                  'Gagal menyimpan data.'),
                      ),
                    ),
                  );
              },
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Karyawan'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showAssignManager(
    BuildContext context,
    HrEmployeeRecord employee,
  ) async {
    final theme = Theme.of(context);
    final provider = context.read<HrProvider>();
    String? selectedManagerId = employee.managerId;
    final candidates = provider.employees
        .where((e) => e.id != employee.id && e.isActive)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tetapkan Atasan (manager_id)'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxFormWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Karyawan: ${employee.fullName} (${employee.department})',
                  style: theme.textTheme.titleSmall,
                ),
                AppDimensions.gap6,
                Text(
                  'Karyawan yang ditetapkan sebagai atasan otomatis berstatus Lead dan menjadi approver cuti bagi anggota timnya.',
                  style: theme.textTheme.bodySmall,
                ),
                AppDimensions.gap16,
                DropdownButtonFormField<String?>(
                  initialValue: selectedManagerId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Atasan Langsung',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tidak ada atasan (Top-level)'),
                    ),
                    ...candidates.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(
                          '${c.fullName} • ${c.position}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) =>
                      setDialogState(() => selectedManagerId = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await provider.assignManager(
                  employee.id,
                  selectedManagerId,
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
                            ? 'Atasan untuk ${employee.fullName} berhasil diperbarui.'
                            : (provider.errorMessage ??
                                  'Gagal menetapkan atasan.'),
                      ),
                    ),
                  );
              },
              child: const Text('Simpan Atasan'),
            ),
          ],
        ),
      ),
    );
  }

  static void showSensitiveDetail(
    BuildContext context,
    HrEmployeeRecord emp,
    String managerName,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(emp.fullName),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxFormWidth,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Email', value: emp.email),
                _DetailRow(
                  label: 'Departemen / Jabatan',
                  value: '${emp.department} • ${emp.position}',
                ),
                _DetailRow(label: 'Tanggal Masuk', value: emp.joinDate),
                _DetailRow(label: 'Atasan (manager_id)', value: managerName),
                AppDimensions.gap4,
                const Divider(),
                AppDimensions.gap8,
                _DetailRow(label: 'NIK', value: emp.nik),
                _DetailRow(label: 'NPWP', value: emp.npwp),
                _DetailRow(label: 'Rekening Bank', value: emp.bankAccount),
                _DetailRow(label: 'Alamat', value: emp.address),
                _DetailRow(
                  label: 'Kontak Darurat',
                  value: emp.emergencyContact,
                ),
              ],
            ),
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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const Gap(AppDimensions.space2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
