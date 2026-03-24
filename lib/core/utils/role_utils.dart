import '../../features/auth/data/models/app_user_model.dart';
import '../constants/app_roles.dart';

bool isUserRole(String? role) => role == AppRoles.user;

bool isAdminRole(String? role) =>
    role == AppRoles.admin || role == AppRoles.superAdmin;

bool isSuperAdminRole(String? role) => role == AppRoles.superAdmin;

bool isUser(AppUser? user) => user != null && isUserRole(user.role);

bool isAdmin(AppUser? user) => user != null && isAdminRole(user.role);

bool isSuperAdmin(AppUser? user) =>
    user != null && isSuperAdminRole(user.role);

