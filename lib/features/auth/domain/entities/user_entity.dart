import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class UserEntity {
  final String id;
  final String? email;
  final String? fullName;
  final UserRole role;
  final bool isLead;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isLead,
  });
}
