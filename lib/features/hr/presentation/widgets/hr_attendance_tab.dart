import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/hr/presentation/providers/hr_provider.dart';

class HrAttendanceTab extends StatelessWidget {
  const HrAttendanceTab({super.key});

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('terlambat')) return AppColors.warning;
    if (lower.contains('alpha') || lower.contains('tidak')) {
      return AppColors.error;
    }
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<HrProvider>();
    final departments = [
      'Semua',
      ...provider.employees.map((e) => e.department).toSet(),
    ];
    final filteredLogs = provider.filteredAttendance;

    final onTimeCount = filteredLogs
        .where((a) => a.status != 'Terlambat')
        .length;
    final lateCount = filteredLogs.where((a) => a.status == 'Terlambat').length;

    if (provider.isLoadingAttendance) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: provider.loadAllAttendance,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.paddingPage,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final deptDropdown = DropdownButtonFormField<String>(
                initialValue:
                    departments.contains(provider.attendanceDeptFilter)
                    ? provider.attendanceDeptFilter
                    : 'Semua',
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Departemen'),
                items: departments
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          d,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) provider.setAttendanceDeptFilter(val);
                },
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekap & Riwayat Absensi Karyawan',
                      style: theme.textTheme.titleMedium,
                    ),
                    AppDimensions.gap10,
                    deptDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rekap & Riwayat Absensi Karyawan',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  AppDimensions.gap12,
                  SizedBox(width: 180, child: deptDropdown),
                ],
              );
            },
          ),
          AppDimensions.gap12,
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Total Log',
                  value: '${filteredLogs.length}',
                  color: colors.primary,
                ),
              ),
              AppDimensions.gap10,
              Expanded(
                child: _StatBox(
                  label: 'Hadir',
                  value: '$onTimeCount',
                  color: AppColors.success,
                ),
              ),
              AppDimensions.gap10,
              Expanded(
                child: _StatBox(
                  label: 'Terlambat',
                  value: '$lateCount',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          AppDimensions.gap16,
          if (filteredLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.space32,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 48,
                      color: colors.outline,
                    ),
                    AppDimensions.gap8,
                    Text(
                      'Belum ada catatan absensi pada filter ini.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredLogs.map((log) {
              final badgeColor = _statusColor(log.status);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space14,
                      vertical: AppDimensions.space4,
                    ),
                    title: Text(
                      '${log.employeeName} • ${log.department}',
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.space2),
                      child: Text(
                        '${log.date}  |  Masuk: ${log.checkIn} • Pulang: ${log.checkOut}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    trailing: Container(
                      padding: AppDimensions.paddingBadge,
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: AppDimensions.borderRadiusPill,
                      ),
                      child: Text(
                        log.status,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppDimensions.paddingCardCompact,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppDimensions.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Gap(AppDimensions.space2),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
