import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';

class DashboardScaffold extends StatefulWidget {
  const DashboardScaffold({
    super.key,
    required this.title,
    required this.onLogout,
    this.destinations = const [],
    this.pages = const [],
    this.body,
    this.children = const [],
  }) : assert(
         destinations.length == pages.length,
         'Jumlah destinations dan pages harus sama',
       );

  final String title;
  final VoidCallback onLogout;
  final List<NavigationDestination> destinations;
  final List<Widget> pages;
  final Widget? body;
  final List<Widget> children;

  @override
  State<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {
  int _activeIndex = 0;

  Future<void> _confirmLogout(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxFormWidth,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppDimensions.paddingCardCompact,
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: AppDimensions.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: AppDimensions.iconLg,
                  color: AppColors.error,
                ),
              ),
              AppDimensions.gap12,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apakah Anda yakin ingin keluar dari akun?',
                      style: theme.textTheme.titleSmall,
                    ),
                    AppDimensions.gap4,
                    Text(
                      'Sesi Anda saat ini akan diakhiri dan Anda harus login kembali untuk mengakses sistem HRIS.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasNavBar = widget.destinations.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: AppDimensions.paddingBadge,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: AppDimensions.borderRadiusSm,
              ),
              child: Text(
                widget.title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (hasNavBar) ...[
              AppDimensions.gap10,
              Flexible(
                child: Text(
                  widget.destinations[_activeIndex].label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space8),
            child: IconButton(
              icon: Icon(Icons.logout_rounded, color: colors.onSurfaceVariant),
              tooltip: 'Keluar dari Akun',
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
      body: hasNavBar
          ? IndexedStack(index: _activeIndex, children: widget.pages)
          : (widget.body ??
                ListView(
                  padding: AppDimensions.paddingPage,
                  children: widget.children.isEmpty
                      ? [
                          Center(
                            child: Text(
                              'Segera hadir',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ]
                      : widget.children,
                )),
      bottomNavigationBar: hasNavBar
          ? DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.outlineVariant, width: 1),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _activeIndex,
                onDestinationSelected: (index) {
                  setState(() => _activeIndex = index);
                },
                destinations: widget.destinations,
              ),
            )
          : null,
    );
  }
}
