import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final authUser = auth.state.user;

    if (authUser == null) {
      return const Scaffold(body: LoadingState());
    }

    return ChangeNotifierProvider(
      create: (context) => ProfileController(
        context.read<ProfileRepository>(),
      )..loadProfile(authUser.uid),
      child: const _UserProfileView(),
    );
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final auth = context.read<AuthController>();

    if (controller.status.isLoading) {
      return const Scaffold(body: LoadingState());
    }

    final user = controller.user ?? auth.state.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Profil introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              context.go(AppRoute.authGate.path);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              fullName: user.fullName,
              email: user.email,
              role: user.role,
              photoUrl: user.photoUrl,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Providers',
              subtitle: user.authProviders.join(', '),
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push(AppRoute.editProfile.path),
                child: const Text('Modifier le profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
