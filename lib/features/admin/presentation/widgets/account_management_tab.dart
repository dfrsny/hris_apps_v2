import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/admin/presentation/extensions/user_role_ui_ext.dart';
import 'package:hris_apps/features/admin/presentation/providers/admin_provider.dart';
import 'package:hris_apps/features/admin/presentation/widgets/account_card_item.dart';
import 'package:hris_apps/features/admin/presentation/widgets/create_account_dialog.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class AccountManagementTab extends StatefulWidget {
  const AccountManagementTab({super.key});

  @override
  State<AccountManagementTab> createState() => _AccountManagementTabState();
}

class _AccountManagementTabState extends State<AccountManagementTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<AdminProvider>();
    final accounts = provider.filteredAccounts;

    return Padding(
      padding: AppDimensions.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Akun Pengguna (${provider.totalAccountsCount})',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Gap(AppDimensions.space2),
                    Text(
                      '${provider.activeAccountsCount} akun aktif • Role Super Admin hanya dapat diberikan via SQL manual',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppDimensions.gap12,
              FilledButton.icon(
                onPressed: () => CreateAccountDialog.show(context),
                icon: const Icon(Icons.add_rounded, size: AppDimensions.iconMd),
                label: const Text('Buat Akun'),
              ),
            ],
          ),
          AppDimensions.gap16,
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;
              final searchField = TextField(
                controller: _searchController,
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Cari nama akun atau email...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: AppDimensions.iconMd,
                  ),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              );

              final roleDropdown = DropdownButtonFormField<UserRole?>(
                initialValue: provider.filterRole,
                decoration: const InputDecoration(labelText: 'Filter Role'),
                items: [
                  const DropdownMenuItem<UserRole?>(child: Text('Semua Role')),
                  ...kManageableRoles.map(
                    (r) => DropdownMenuItem<UserRole?>(
                      value: r,
                      child: Text(r.label),
                    ),
                  ),
                ],
                onChanged: provider.setFilterRole,
              );

              if (isNarrow) {
                return Column(
                  children: [searchField, AppDimensions.gap10, roleDropdown],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 2, child: searchField),
                  AppDimensions.gap12,
                  Expanded(child: roleDropdown),
                ],
              );
            },
          ),
          AppDimensions.gap16,
          Expanded(
            child: provider.isLoadingAccounts
                ? const Center(child: CircularProgressIndicator())
                : accounts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: colors.outline,
                        ),
                        AppDimensions.gap8,
                        Text(
                          'Tidak ada akun yang sesuai filter.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (provider.searchQuery.isNotEmpty ||
                            provider.filterRole != null) ...[
                          AppDimensions.gap4,
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.clearFilters();
                            },
                            child: const Text('Reset Filter'),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.loadAccounts,
                    child: ListView.separated(
                      itemCount: accounts.length,
                      separatorBuilder: (_, _) => AppDimensions.gap8,
                      itemBuilder: (context, index) {
                        return AccountCardItem(account: accounts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
