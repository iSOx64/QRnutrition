import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/app/router.dart';
import 'package:first_app/features/auth/data/models/app_user_model.dart';

void main() {
  test('roleHomePath returns correct path by role', () {
    final baseUser = AppUser.initial('u1', 'user@test.com');

    final userPath = roleHomePath(baseUser);
    expect(userPath, AppRoute.userHome.path);

    final adminPath = roleHomePath(baseUser.copyWith(role: 'admin'));
    expect(adminPath, AppRoute.adminHome.path);

    final superAdminPath =
        roleHomePath(baseUser.copyWith(role: 'super_admin'));
    expect(superAdminPath, AppRoute.superAdminHome.path);
  });
}
