enum UserRole {
  superAdmin,
  hr,
  finance,
  employee;

  static UserRole fromString(String value) {
    switch (value) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'hr':
        return UserRole.hr;
      case 'finance':
        return UserRole.employee;
      default:
        return UserRole.employee;
    }
  }
}
