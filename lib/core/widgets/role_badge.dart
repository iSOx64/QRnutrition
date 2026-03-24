import 'package:flutter/material.dart';

import '../constants/app_roles.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({
    super.key,
    required this.role,
  });

  final String role;

  @override
  Widget build(BuildContext context) {
    final colors = _roleColors(role, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label(role),
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: colors.foreground),
      ),
    );
  }

  String _label(String value) {
    switch (value) {
      case AppRoles.admin:
        return 'Admin';
      case AppRoles.superAdmin:
        return 'Super Admin';
      case AppRoles.user:
      default:
        return 'User';
    }
  }

  _RoleColors _roleColors(String value, ColorScheme scheme) {
    switch (value) {
      case AppRoles.superAdmin:
        return _RoleColors(
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        );
      case AppRoles.admin:
        return _RoleColors(
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
        );
      case AppRoles.user:
      default:
        return _RoleColors(
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
        );
    }
  }
}

class _RoleColors {
  const _RoleColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
