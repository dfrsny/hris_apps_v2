import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class ManagedAccount {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isActive;

  const ManagedAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.isActive = true,
  });

  ManagedAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    bool? isActive,
  }) {
    return ManagedAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
