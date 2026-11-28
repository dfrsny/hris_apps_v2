import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/hr/presentation/providers/hr_provider.dart';
import 'package:hris_apps/features/hr/presentation/widgets/hr_employee_dialogs.dart';

class HrEmployeesTab extends StatelessWidget {
  const HrEmployeesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<HrProvider>();
    final departments = provider.employees
        .map((e) => e.department)
        .toSet()
        .toList();
    final filtered = provider.filteredEmployees;

    return Padding(
      padding: AppDimensions.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppDimensions.space12),
            padding: AppDimensions.paddingBanner,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.6),
              borderRadius: AppDimensions.borderRadiusSm,
              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.space2),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
                AppDimensions.gap10,
                Expanded(
                  child: Text(
                    'Ruang Lingkup HR: Pengelolaan profil & data sensitif karyawan, hierarki atasan (Lead), monitoring absensi, manajemen cuti, dan komponen gaji.',
                    softWrap: true,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;
              final headerInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direktori Karyawan (${provider.employees.length})',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Gap(AppDimensions.space2),
                  Text(
                    'Kelola data dasar, data sensitif (NIK/NPWP/Rekening), dan penetapan atasan (Lead)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );

              final addButton = FilledButton.icon(
                onPressed: () => HrEmployeeDialogs.showEmployeeForm(context),
                icon: const Icon(
                  Icons.person_add_outlined,
                  size: AppDimensions.iconSm,
                ),
                label: const Text('Tambah Karyawan'),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [headerInfo, AppDimensions.gap10, addButton],
                );
              }

              return Row(
                children: [
                  Expanded(child: headerInfo),
                  AppDimensions.gap12,
                  addButton,
                ],
              );
            },
          ),
          AppDimensions.gap12,
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;
              final searchField = TextField(
                onChanged: provider.setEmployeeSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Cari nama, email, atau jabatan...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: AppDimensions.iconMd,
                  ),
                ),
              );

              final deptDropdown = DropdownButtonFormField<String?>(
                initialValue: provider.selectedDepartmentFilter,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Departemen'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Semua'),
                  ),
                  ...departments.map(
                    (d) => DropdownMenuItem<String?>(
                      value: d,
                      child: Text(
                        d,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: provider.setDepartmentFilter,
              );

              if (isNarrow) {
                return Column(
                  children: [searchField, AppDimensions.gap10, deptDropdown],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 2, child: searchField),
                  AppDimensions.gap10,
                  Expanded(child: deptDropdown),
                ],
              );
            },
          ),
          AppDimensions.gap12,
          Expanded(
            child: provider.isLoadingEmployees
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 48,
                          color: colors.outline,
                        ),
                        AppDimensions.gap8,
                        Text(
                          'Tidak ada karyawan yang sesuai filter.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.loadEmployees,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => AppDimensions.gap8,
                      itemBuilder: (context, index) {
                        final emp = filtered[index];
                        final isLead = provider.isLead(emp);

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.space14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: emp.isActive
                                          ? colors.primaryContainer
                                          : colors.surfaceContainerHighest,
                                      child: Text(
                                        emp.fullName.isNotEmpty
                                            ? emp.fullName[0].toUpperCase()
                                            : '?',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: emp.isActive
                                                  ? colors.onPrimaryContainer
                                                  : colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    AppDimensions.gap12,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  emp.fullName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color: emp.isActive
                                                            ? colors.onSurface
                                                            : colors.onSurface
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                      ),
                                                ),
                                              ),
                                              if (isLead) ...[
                                                AppDimensions.gap6,
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal:
                                                            AppDimensions
                                                                .space8,
                                                        vertical: AppDimensions
                                                            .space2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        colors.primaryContainer,
                                                    borderRadius: AppDimensions
                                                        .borderRadiusPill,
                                                    border: Border.all(
                                                      color: colors.primary
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Lead',
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: colors
                                                              .onPrimaryContainer,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const Gap(AppDimensions.space2),
                                          Text(
                                            '${emp.position} •${emp.department}',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          Text(
                                            'Atasan: ${provider.getManagerName(emp.managerId)}',
                                            style: theme.textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: emp.isActive,
                                      onChanged: (val) async {
                                        final ok = await provider
                                            .toggleEmployeeStatus(emp.id, val);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              backgroundColor: ok
                                                  ? null
                                                  : AppColors.error,
                                              content: Text(
                                                ok
                                                    ? (val
                                                          ? 'Karyawan ${emp.fullName} diaktifkan.'
                                                          : 'Karyawan ${emp.fullName} dinonaktifkan.')
                                                    : 'Gagal mengubah status.',
                                              ),
                                            ),
                                          );
                                      },
                                    ),
                                  ],
                                ),
                                AppDimensions.gap10,
                                const Divider(),
                                AppDimensions.gap10,
                                Row(
                                  spacing: AppDimensions.space6,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          HrEmployeeDialogs.showSensitiveDetail(
                                            context,
                                            emp,
                                            provider.getManagerName(
                                              emp.managerId,
                                            ),
                                          ),
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: AppDimensions.iconSs,
                                      ),
                                      label: const Text(
                                        'Detail',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          HrEmployeeDialogs.showEmployeeForm(
                                            context,
                                            existing: emp,
                                          ),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: AppDimensions.iconSs,
                                      ),
                                      label: const Text(
                                        'Edit',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          HrEmployeeDialogs.showAssignManager(
                                            context,
                                            emp,
                                          ),
                                      icon: const Icon(
                                        Icons.account_tree_outlined,
                                        size: AppDimensions.iconSs,
                                      ),
                                      label: const Text(
                                        'Tetapkan',
                                        style: TextStyle(fontSize: 11),
                                      ),
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
