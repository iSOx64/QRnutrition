import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/quick_actions_grid.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.state.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final actions = [
      QuickActionItem(
        label: 'Scanner code-barres',
        icon: Icons.qr_code_scanner,
        onTap: () => context.push(AppRoute.scanner.path),
      ),
      QuickActionItem(
        label: 'Scanner image (code-barres)',
        icon: Icons.photo_library,
        onTap: () => context.push(AppRoute.scanner.path, extra: true),
      ),
      QuickActionItem(
        label: 'Recherche',
        icon: Icons.search,
        onTap: () => context.push(AppRoute.productSearch.path),
      ),
      QuickActionItem(
        label: 'Historique',
        icon: Icons.history,
        onTap: () => context.push(AppRoute.scanHistory.path),
      ),
      QuickActionItem(
        label: 'Dashboard',
        icon: Icons.insights,
        onTap: () => context.push(AppRoute.nutritionDashboard.path),
      ),
      QuickActionItem(
        label: 'Profil',
        icon: Icons.person,
        onTap: () => context.push(AppRoute.userProfile.path),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Nutrition'),
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
          children: [
            InfoCard(
              title: 'Bienvenue',
              subtitle: user.fullName.isEmpty ? user.email : user.fullName,
              icon: Icons.waving_hand,
              trailing: RoleBadge(role: user.role),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Acces rapide',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            QuickActionsGrid(items: actions),
          ],
        ),
      ),
    );
  }
}
