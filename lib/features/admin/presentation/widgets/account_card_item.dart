import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/presentation/extensions/user_role_ui_ext.dart';
import 'package:hris_apps/features/admin/presentation/providers/admin_provider.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class AccountCardItem extends StatelessWidget {
  final ManagedAccount account;

  const AccountCardItem({super.key, required this.account});

  Future<void> _onRoleChanged(BuildContext context, UserRole? newRole) async {
    if (newRole == null || newRole == account.role) return;
    final provider = context.read<AdminProvider>();
    final success = await provider.changeAccountRole(account.id, newRole);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? null : AppColors.error,
          content: Text(
            success
                ? 'Role ${account.displayName} diubah ke${newRole.label}.'
                : (provider.errorMessage ??
                      'Gagal mengubah role ${account.displayName}.'),
          ),
        ),
      );
  }

  Future<void> _onStatusChanged(BuildContext context, bool val) async {
    final provider = context.read<AdminProvider>();
    final success = await provider.toggleAccountStatus(account.id, val);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? null : AppColors.error,
          content: Text(
            success
                ? (val
                      ? 'Akun ${account.email} diaktifkan.'
                      : 'Akun ${account.email} dinonaktifkan.')
                : (provider.errorMessage ?? 'Gagal memperbarui status akun.'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isInactive = !account.isActive;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(
          color: isInactive
              ? colors.outlineVariant.withValues(alpha: 0.5)
              : colors.outlineVariant,
          width: 1,
        ),
        boxShadow: isInactive
            ? null
            : [
                BoxShadow(
                  color: colors.onSurface.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppDimensions.borderRadiusLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space14,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 520;

              final userInfo = Row(
                children: [
                  // ── Avatar ──
                  Container(
                    width: AppDimensions.avatarSize,
                    height: AppDimensions.avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isInactive
                          ? colors.surfaceContainerHighest
                          : account.role.color.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Text(
                        account.displayName.isNotEmpty
                            ? account.displayName[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isInactive
                              ? colors.onSurfaceVariant
                              : account.role.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppDimensions.space14),

                  // ── Name & Email ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: isInactive
                                ? colors.onSurface.withValues(alpha: 0.5)
                                : colors.onSurface,
                          ),
                        ),
                        const Gap(3),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 13,
                              color: colors.onSurfaceVariant,
                            ),
                            const Gap(5),
                            Expanded(
                              child: Text(
                                account.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userInfo,
                    AppDimensions.gap12,
                    Row(
                      children: [
                        Expanded(
                          child: _RoleDropdown(
                            accountId: account.id,
                            role: account.role,
                            isInactive: isInactive,
                            onChanged: (newRole) =>
                                _onRoleChanged(context, newRole),
                          ),
                        ),
                        AppDimensions.gap10,
                        _StatusToggle(
                          isActive: account.isActive,
                          onChanged: (val) => _onStatusChanged(context, val),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: userInfo),
                  AppDimensions.gap16,
                  SizedBox(
                    width: 148,
                    child: _RoleDropdown(
                      accountId: account.id,
                      role: account.role,
                      isInactive: isInactive,
                      onChanged: (newRole) => _onRoleChanged(context, newRole),
                    ),
                  ),
                  AppDimensions.gap12,
                  _StatusToggle(
                    isActive: account.isActive,
                    onChanged: (val) => _onStatusChanged(context, val),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Role Dropdown
// ─────────────────────────────────────────────
class _RoleDropdown extends StatelessWidget {
  final String accountId;
  final UserRole role;
  final bool isInactive;
  final ValueChanged<UserRole?> onChanged;

  const _RoleDropdown({
    required this.accountId,
    required this.role,
    required this.isInactive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeColor = isInactive
        ? colors.onSurfaceVariant.withValues(alpha: 0.5)
        : role.color;

    return DropdownButtonFormField<UserRole>(
      key: ValueKey('role-$accountId-${role.name}'),
      initialValue: role,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
        color: activeColor,
      ),
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: activeColor,
      ),
      dropdownColor: colors.surface,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: isInactive
            ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
            : role.color.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusSm,
          borderSide: BorderSide(
            color: isInactive
                ? colors.outlineVariant.withValues(alpha: 0.4)
                : role.color.withValues(alpha: 0.25),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusSm,
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusSm,
          borderSide: BorderSide(color: role.color, width: 1.5),
        ),
      ),
      items: kManageableRoles.map((r) {
        return DropdownMenuItem(
          value: r,
          child: Row(
            children: [
              Container(
                width: AppDimensions.space8,
                height: AppDimensions.space8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: r.color,
                ),
              ),
              AppDimensions.gap8,
              Expanded(
                child: Text(
                  r.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: isInactive ? null : onChanged,
    );
  }
}

// ─────────────────────────────────────────────
//  Status Toggle — hit-test box aman tanpa Transform.scale
// ─────────────────────────────────────────────
class _StatusToggle extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _StatusToggle({required this.isActive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: AppDimensions.borderRadiusPill,
      onTap: () => onChanged(!isActive),
      child: Container(
        padding: const EdgeInsets.only(
          left: AppDimensions.space12,
          right: AppDimensions.space6,
          top: AppDimensions.space4,
          bottom: AppDimensions.space4,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.successSurface
              : colors.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: AppDimensions.borderRadiusPill,
          border: Border.all(
            color: isActive
                ? AppColors.success.withValues(alpha: 0.3)
                : colors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? 'Aktif' : 'Nonaktif',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.success : colors.onSurfaceVariant,
              ),
            ),
            AppDimensions.gap6,
            SizedBox(
              height: 26,
              width: 44,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Switch(
                  value: isActive,
                  onChanged: onChanged,
                  activeTrackColor: AppColors.success,
                  inactiveThumbColor: colors.surface,
                  inactiveTrackColor: colors.outlineVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
