import 'package:hris_apps/features/admin/domain/entities/managed_account.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class ManagedAccountModel extends ManagedAccount {
  const ManagedAccountModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.role,
    super.isActive,
  });

  factory ManagedAccountModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] as String? ?? 'employee';
    final normalizedRole = rawRole == 'super_admin' ? 'superAdmin' : rawRole;

    return ManagedAccountModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      // Mapping langsung dari kolom asli database (full_name) ke entity (displayName)
      displayName:
          (json['full_name'] as String?) ??
          (json['display_name'] as String?) ??
          '',
      role: UserRole.values.firstWhere(
        (e) => e.name == normalizedRole,
        orElse: () => UserRole.employee,
      ),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': displayName,
      'role': role == UserRole.superAdmin ? 'super_admin' : role.name,
      'is_active': isActive,
    };
  }
}
