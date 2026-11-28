import 'package:material_ui/material_ui.dart';
import 'package:hris_apps/features/auth/domain/entities/user_role.dart';

const List<UserRole> kManageableRoles = [
  UserRole.hr,
  UserRole.finance,
  UserRole.employee,
];

extension ManageableUserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.hr:
        return 'HR';
      case UserRole.finance:
        return 'Finance';
      case UserRole.employee:
        return 'Employee';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.superAdmin:
        return Colors.deepPurple;
      case UserRole.hr:
        return Colors.indigo;
      case UserRole.finance:
        return Colors.teal;
      case UserRole.employee:
        return Colors.blueGrey;
    }
  }
}
