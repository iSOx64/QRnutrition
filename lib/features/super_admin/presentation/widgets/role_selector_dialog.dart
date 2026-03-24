import 'package:flutter/material.dart';

import '../../../../core/constants/app_roles.dart';

class RoleSelectorDialog extends StatelessWidget {
  const RoleSelectorDialog({
    super.key,
    required this.currentRole,
  });

  final String currentRole;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Choisir un role'),
      children: AppRoles.all.map((role) {
        return RadioListTile<String>(
          value: role,
          groupValue: currentRole,
          onChanged: (value) => Navigator.of(context).pop(value),
          title: Text(role),
        );
      }).toList(),
    );
  }
}
