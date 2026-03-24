import 'package:flutter/material.dart';

import '../../../../core/widgets/role_badge.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  final String fullName;
  final String email;
  final String role;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: photoUrl == null || photoUrl!.isEmpty
              ? null
              : NetworkImage(photoUrl!),
          child: photoUrl == null || photoUrl!.isEmpty
              ? const Icon(Icons.person, size: 32)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName.isEmpty ? 'Utilisateur' : fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              RoleBadge(role: role),
            ],
          ),
        ),
      ],
    );
  }
}
