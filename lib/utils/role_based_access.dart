// lib/utils/role_based_access.dart
import '../../models/user.dart';

bool hasPermission(UserRole userRole, List<UserRole> requiredRoles) {
  return requiredRoles.contains(userRole);
}

class Permissions {
  static const List<UserRole> adminOnly = [UserRole.admin];
  static const List<UserRole> adminAndEngineer = [UserRole.admin, UserRole.engineer];
  static const List<UserRole> all = [UserRole.admin, UserRole.engineer, UserRole.operator];
}