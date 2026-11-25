import 'package:hris_apps/features/auth/domain/entities/user_entity.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    required super.fullName,
    required super.role,
    required super.isLead,
  });

  factory UserModel.fromProfile({
    required String id,
    String? email,
    required Map<String, dynamic> profile,
    required bool isLead,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: profile['full_name'] as String,
      role: UserRole.fromString(profile['role'] as String),
      isLead: isLead,
    );
  }
}
