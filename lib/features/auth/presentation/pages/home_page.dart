import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../data/models/app_user_model.dart';
import '../controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final AppUser? user = controller.state.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await controller.logout();
              if (!context.mounted) return;
              context.go(AppRoute.authGate.path);
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Utilisateur connecté',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Nom : ${user.fullName.isEmpty ? '—' : user.fullName}'),
                    Text('Email : ${user.email}'),
                    Text('Rôle : ${user.role}'),
                    Text(
                        'Profil complet : ${user.isProfileComplete ? 'Oui' : 'Non'}'),
                    const SizedBox(height: 24),
                    Text('Providers : ${user.authProviders.join(', ')}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


