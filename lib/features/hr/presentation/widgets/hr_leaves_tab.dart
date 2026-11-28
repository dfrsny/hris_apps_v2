import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/hr/domain/entities/hr_leave_item.dart';
import 'package:hris_apps/features/hr/presentation/providers/hr_provider.dart';

class HrLeavesTab extends StatelessWidget {
  const HrLeavesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<HrProvider>();
    final visibleLeaves = provider.visibleLeaves;

    return Padding(
      padding: AppDimensions.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final headerInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring & Eskalasi Cuti (M4)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Gap(AppDimensions.space2),
                  Text(
                    'HR dapat mengambil alih pengajuan yang tidak memiliki approver (atasan)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );

              final filterChip = FilterChip(
                label: const Text('Tanpa Approver'),
                selected: provider.onlyNoApproverFilter,
                onSelected: provider.setOnlyNoApproverFilter,
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [headerInfo, AppDimensions.gap8, filterChip],
                );
              }

              return Row(
                children: [
                  Expanded(child: headerInfo),
                  AppDimensions.gap12,
                  filterChip,
                ],
              );
            },
          ),
          AppDimensions.gap12,
          Expanded(
            child: provider.isLoadingLeaves
                ? const Center(child: CircularProgressIndicator())
                : visibleLeaves.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 48,
                          color: colors.outline,
                        ),
                        AppDimensions.gap8,
                        Text(
                          'Tidak ada pengajuan cuti yang sesuai filter.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.loadAllLeaves,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: visibleLeaves.length,
                      separatorBuilder: (_, _) => AppDimensions.gap8,
                      itemBuilder: (context, index) {
                        final leave = visibleLeaves[index];
                        final canHrTakeOver =
                            leave.hasNoApprover &&
                            leave.status == LeaveApprovalStatus.pending;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderRadiusMd,
                            side: BorderSide(
                              color: canHrTakeOver
                                  ? AppColors.warning
                                  : colors.outlineVariant,
                              width: canHrTakeOver ? 1.5 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.space14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${leave.employeeName} (${leave.department})',
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ),
                                    AppDimensions.gap8,
                                    Container(
                                      padding: AppDimensions.paddingBadge,
                                      decoration: BoxDecoration(
                                        color: leave.status.color.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius:
                                            AppDimensions.borderRadiusPill,
                                      ),
                                      child: Text(
                                        leave.status.label,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: leave.status.color,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                AppDimensions.gap4,
                                Text(
                                  '${leave.type} • ${leave.dateRange} (${leave.days} hari)',
                                  style: theme.textTheme.bodySmall,
                                ),
                                AppDimensions.gap4,
                                Text(
                                  'Alasan: ${leave.reason}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                AppDimensions.gap6,
                                Text(
                                  leave.hasNoApprover
                                      ? 'Approver: Tidak ada atasan (Membutuhkan tindakan HR)'
                                      : 'Approver: ${leave.approverName}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: leave.hasNoApprover
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: leave.hasNoApprover
                                        ? AppColors.warning
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                                if (canHrTakeOver) ...[
                                  AppDimensions.gap10,
                                  const Divider(),
                                  AppDimensions.gap10,
                                  Wrap(
                                    spacing: AppDimensions.space8,
                                    runSpacing: AppDimensions.space8,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final ok = await provider.decideLeave(
                                            leave.id,
                                            LeaveApprovalStatus.rejected,
                                          );
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
                                                      ? 'Cuti ${leave.employeeName} ditolak oleh HR.'
                                                      : 'Gagal memproses cuti.',
                                                ),
                                              ),
                                            );
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: AppDimensions.iconSm,
                                        ),
                                        label: const Text('Tolak (HR)'),
                                      ),
                                      FilledButton.icon(
                                        onPressed: () async {
                                          final ok = await provider.decideLeave(
                                            leave.id,
                                            LeaveApprovalStatus.approved,
                                          );
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
                                                      ? 'Cuti ${leave.employeeName} disetujui HR (ambil alih).'
                                                      : 'Gagal memproses cuti.',
                                                ),
                                              ),
                                            );
                                        },
                                        icon: const Icon(
                                          Icons.check_rounded,
                                          size: AppDimensions.iconSm,
                                        ),
                                        label: const Text(
                                          'Ambil Alih & Setujui',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
