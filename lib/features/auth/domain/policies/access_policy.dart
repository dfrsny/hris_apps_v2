import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

enum AccessLevel { none, limited, own, team, full }

class AccessPolicy {
  const AccessPolicy._();

  static AccessLevel personalData(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return AccessLevel.limited;
      case UserRole.hr:
        return AccessLevel.full;
      case UserRole.finance:
        return AccessLevel.none;
      case UserRole.employee:
        return AccessLevel.own;
    }
  }
}
