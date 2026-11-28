import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';

class FinanceScopeNoticeBanner extends StatelessWidget {
  const FinanceScopeNoticeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: AppDimensions.paddingBanner,
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.65),
        borderRadius: AppDimensions.borderRadiusSm,
        border: Border.all(color: colors.secondary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.space2),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: colors.secondary,
            ),
          ),
          AppDimensions.gap10,
          Expanded(
            child: Text(
              'Akses Agregat Finance: Hanya menampilkan ringkasan rekapitulasi & laporan payroll. Baris absensi mentah, data pribadi karyawan, struktur tim, dan pengaturan sistem tidak tersedia.',
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
