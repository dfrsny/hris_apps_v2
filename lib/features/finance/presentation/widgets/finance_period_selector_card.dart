import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/finance/presentation/extensions/payroll_status_ui_ext.dart';
import 'package:hris_apps/features/finance/presentation/providers/finance_provider.dart';

class FinancePeriodSelectorCard extends StatelessWidget {
  const FinancePeriodSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FinanceProvider>();
    final batch = provider.currentBatch;
    if (batch == null) return const SizedBox.shrink();

    final dropdown = DropdownButtonFormField<int>(
      initialValue: provider.selectedPeriodIndex,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Periode Bulanan',
        prefixIcon: Icon(
          Icons.calendar_month_outlined,
          size: AppDimensions.iconMd,
        ),
      ),
      items: List.generate(provider.batches.length, (i) {
        return DropdownMenuItem(
          value: i,
          child: Text(
            provider.batches[i].period,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }),
      onChanged: (val) {
        if (val != null) provider.selectPeriodIndex(val);
      },
    );

    final statusBadge = Container(
      padding: AppDimensions.paddingBadge,
      decoration: BoxDecoration(
        color: batch.status.color.withValues(alpha: 0.12),
        borderRadius: AppDimensions.borderRadiusPill,
      ),
      child: Text(
        batch.status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: batch.status.color,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space16),
      child: Card(
        child: Padding(
          padding: AppDimensions.paddingCardCompact,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [dropdown, AppDimensions.gap8, statusBadge],
                );
              }
              return Row(
                children: [
                  Expanded(child: dropdown),
                  AppDimensions.gap12,
                  Flexible(flex: 0, child: statusBadge),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
