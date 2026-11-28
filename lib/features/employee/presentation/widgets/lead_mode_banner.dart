import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';

class LeadModeBanner extends StatelessWidget {
  const LeadModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: AppDimensions.paddingBanner,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.6),
        borderRadius: AppDimensions.borderRadiusSm,
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_outlined, size: 18, color: colors.primary),
          AppDimensions.gap10,
          Expanded(
            child: Text(
              'Mode Team Lead: Akses pemantauan absensi tim (M3) & persetujuan cuti anggota tim (M4) aktif.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
