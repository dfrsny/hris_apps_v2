import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/admin/presentation/extensions/user_role_ui_ext.dart';
import 'package:hris_apps/features/admin/presentation/providers/admin_provider.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class AccountCardItem extends StatelessWidget {
  final ManagedAccount account;

  const AccountCardItem({super.key, required this.account});

  Future<void> _onRoleChanged(BuildContext context, UserRole? newRole) async {
    if (newRole == null || newRole == account.role) return;
    final success = await context.read<AdminProvider>().changeAccountRole(
      account.id,
      newRole,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          success
              ? 'Role ${account.displayName} diubah ke ${newRole.label}.'
              : 'Gagal mengubah role ${account.displayName}.',
        ),
      ),
    );
  }

  Future<void> _onStatusChanged(BuildContext context, bool val) async {
    final success = await context.read<AdminProvider>().toggleAccountStatus(
      account.id,
      val,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          success
              ? (val
                    ? 'Akun ${account.email} diaktifkan.'
                    : 'Akun ${account.email} dinonaktifkan.')
              : 'Gagal memperbarui status akun.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInactive = !account.isActive;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInactive
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: isInactive
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 520;

            final userInfo = Row(
              children: [
                // ── Avatar ──
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isInactive
                        ? theme.colorScheme.surfaceContainerHighest
                        : account.role.color.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Text(
                      account.displayName.isNotEmpty
                          ? account.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isInactive
                            ? theme.colorScheme.onSurfaceVariant
                            : account.role.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

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
                          fontWeight: FontWeight.w600,
                          color: isInactive
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              account.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            final controls = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Role Chip / Dropdown ──
                _RoleDropdown(
                  role: account.role,
                  isInactive: isInactive,
                  onChanged: (newRole) => _onRoleChanged(context, newRole),
                ),
                const SizedBox(width: 16),

                // ── Status Toggle ──
                _StatusToggle(
                  isActive: account.isActive,
                  onChanged: (val) => _onStatusChanged(context, val),
                ),
              ],
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userInfo,
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        account.isActive ? 'Aktif' : 'Nonaktif',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: account.isActive
                              ? Colors.green.shade600
                              : Colors.red.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      controls,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: userInfo),
                const SizedBox(width: 16),
                controls,
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Role Dropdown — clean chip-style
// ─────────────────────────────────────────────
class _RoleDropdown extends StatelessWidget {
  final UserRole role;
  final bool isInactive;
  final ValueChanged<UserRole?> onChanged;

  const _RoleDropdown({
    required this.role,
    required this.isInactive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isInactive
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : role.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInactive
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
              : role.color.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: role,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isInactive
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                : role.color,
          ),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isInactive
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                : role.color,
          ),
          dropdownColor: theme.colorScheme.surface,
          items: kManageableRoles.map((r) {
            return DropdownMenuItem(
              value: r,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: r.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(r.label, style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }).toList(),
          onChanged: isInactive ? null : onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Status Toggle — minimal switch + label
// ─────────────────────────────────────────────
class _StatusToggle extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _StatusToggle({required this.isActive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade50
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? Colors.green.shade200
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              isActive ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.green.shade700
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Switch(
            value: isActive,
            onChanged: onChanged,
            
            activeTrackColor: Colors.green.shade500,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: theme.colorScheme.outlineVariant.withValues(
              alpha: 0.4,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
