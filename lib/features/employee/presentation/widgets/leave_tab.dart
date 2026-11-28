import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/employee/presentation/extensions/leave_status_ui_ext.dart';
import 'package:hris_apps/features/employee/presentation/providers/employee_provider.dart';
import 'package:hris_apps/features/employee/presentation/widgets/create_leave_dialog.dart';
import 'package:hris_apps/features/employee/presentation/widgets/lead_mode_banner.dart';

class LeaveTab extends StatelessWidget {
  final bool isLead;

  const LeaveTab({super.key, required this.isLead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<EmployeeProvider>();
    final quota = provider.profile?.remainingLeaveQuota ?? 0;

    return Padding(
      padding: AppDimensions.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLead) const LeadModeBanner(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengajuan Cuti Saya',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Gap(AppDimensions.space2),
                    Text(
                      'Sisa kuota cuti tahunan: $quota hari',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppDimensions.gap12,
              FilledButton.icon(
                onPressed: () => CreateLeaveDialog.show(context),
                icon: const Icon(Icons.add_rounded, size: AppDimensions.iconMd),
                label: const Text('Ajukan Cuti'),
              ),
            ],
          ),
          AppDimensions.gap16,
          Expanded(
            child: provider.isLoadingLeaves
                ? const Center(child: CircularProgressIndicator())
                : provider.leaveRequests.isEmpty
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
                          'Belum ada riwayat pengajuan cuti.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.loadLeaveRequests,
                    child: ListView.separated(
                      itemCount: provider.leaveRequests.length,
                      separatorBuilder: (_, _) => AppDimensions.gap8,
                      itemBuilder: (context, index) {
                        final req = provider.leaveRequests[index];
                        return Card(
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
                                        '${req.type} (${req.days} hari)',
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ),
                                    AppDimensions.gap8,
                                    Container(
                                      padding: AppDimensions.paddingBadge,
                                      decoration: BoxDecoration(
                                        color: req.status.color.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius:
                                            AppDimensions.borderRadiusPill,
                                      ),
                                      child: Text(
                                        req.status.label,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: req.status.color,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                AppDimensions.gap4,
                                Text(
                                  req.dateRange,
                                  style: theme.textTheme.bodySmall,
                                ),
                                AppDimensions.gap6,
                                Text(
                                  req.reason,
                                  style: theme.textTheme.bodyMedium,
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
