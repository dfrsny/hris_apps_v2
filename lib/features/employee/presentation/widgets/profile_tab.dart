import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/employee/presentation/providers/employee_provider.dart';
import 'package:hris_apps/features/employee/presentation/widgets/edit_phone_dialog.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<EmployeeProvider>();
    final profile = provider.profile;

    if (provider.isLoadingProfile || profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: AppDimensions.paddingPage,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Gap(AppDimensions.space14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: theme.textTheme.titleMedium,
                          ),
                          const Gap(AppDimensions.space2),
                          Text(
                            '${profile.position} • ${profile.department}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(AppDimensions.space14),
                const Divider(),
                const Gap(AppDimensions.space14),
                _ProfileItem(label: 'ID Karyawan', value: profile.employeeId),
                _ProfileItem(label: 'Email Kantor', value: profile.email),
                _ProfileItem(label: 'Departemen', value: profile.department),
                _ProfileItem(label: 'Jabatan', value: profile.position),
                _ProfileItem(
                  label: 'Tanggal Bergabung',
                  value: profile.joinDate,
                ),
                AppDimensions.gap4,
                const Divider(),
                AppDimensions.gap12,
                Row(
                  children: [
                    Expanded(
                      child: _ProfileItem(
                        label: 'Nomor Telepon',
                        value: profile.phoneNumber,
                        bottomPadding: 0,
                      ),
                    ),
                    AppDimensions.gap12,
                    OutlinedButton.icon(
                      onPressed: () =>
                          EditPhoneDialog.show(context, profile.phoneNumber),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: AppDimensions.iconSm,
                      ),
                      label: const Text('Ubah'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final double bottomPadding;

  const _ProfileItem({
    required this.label,
    required this.value,
    this.bottomPadding = AppDimensions.space12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const Gap(AppDimensions.space2),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
