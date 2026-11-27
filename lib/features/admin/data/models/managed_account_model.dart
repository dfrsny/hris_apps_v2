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
    return ManagedAccountModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.employee,
      ),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'role': role.name,
      'is_active': isActive,
    };
  }
}
