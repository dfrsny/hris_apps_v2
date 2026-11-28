import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';

class FinanceSummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const FinanceSummaryLine({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            softWrap: true,
            style: isBold
                ? theme.textTheme.titleSmall
                : theme.textTheme.bodyMedium,
          ),
        ),
        AppDimensions.gap12,
        Flexible(
          flex: 0,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (isBold
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ))
                    ?.copyWith(color: valueColor),
          ),
        ),
      ],
    );
  }
}
