import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/action_card.dart';
import '../../../../core/widgets/dashboard_header.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/utils/seed_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../controllers/admin_stats_controller.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.state.user;

    if (user == null) {
      return const Scaffold(body: LoadingState());
    }

    final displayName =
        user.fullName.trim().isNotEmpty ? user.fullName : user.email;

    return ChangeNotifierProvider(
      create: (context) =>
          AdminStatsController(context.read<AdminRepository>())..loadStats(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Espace Admin'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'seed') {
                  final adminId = user.uid;
                  final seedService =
                      SeedService(context.read<ProductRepository>());
                  await seedService.seedProducts(adminId);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produits demo ajoutes')),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'seed',
                  child: Text('Seed demo'),
                ),
              ],
            ),
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
        body: Consumer<AdminStatsController>(
          builder: (context, controller, _) {
            if (controller.status == ViewStatus.loading) {
              return const LoadingState();
            }

            final stats = controller.stats;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DashboardHeader(
                  title: 'Bonjour $displayName',
                  subtitle: 'Pilotez les produits, statistiques et activites.',
                  icon: Icons.admin_panel_settings,
                  badge: RoleBadge(role: user.role),
                  gradientColors: const [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionHeader(
                  title: "Vue d'ensemble",
                  subtitle: 'Chiffres cles en temps reel.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatCard(
                      label: 'Produits',
                      value: '${stats?.totalProducts ?? 0}',
                      icon: Icons.inventory_2,
                    ),
                    StatCard(
                      label: 'Scans',
                      value: '${stats?.totalScans ?? 0}',
                      icon: Icons.qr_code_scanner,
                    ),
                    StatCard(
                      label: 'Utilisateurs',
                      value: '${stats?.totalUsers ?? 0}',
                      icon: Icons.people,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Actions rapides',
                  subtitle: 'Acces direct aux operations principales.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ActionCard(
                      icon: Icons.inventory,
                      title: 'Produits',
                      subtitle: 'Lister et modifier les produits.',
                      onTap: () => context.push(AppRoute.adminProducts.path),
                    ),
                    ActionCard(
                      icon: Icons.add_circle_outline,
                      title: 'Ajouter',
                      subtitle: 'Creer un nouveau produit.',
                      onTap: () => context.push(AppRoute.addProduct.path),
                      accentColor: AppColors.secondary.withOpacity(0.25),
                    ),
                    ActionCard(
                      icon: Icons.insights,
                      title: 'Statistiques',
                      subtitle: 'Suivre les tendances et l usage.',
                      onTap: () => context.push(AppRoute.adminStatistics.path),
                    ),
                    ActionCard(
                      icon: Icons.list_alt,
                      title: 'Logs admin',
                      subtitle: 'Consulter les actions recentes.',
                      onTap: () => context.push(AppRoute.adminLogs.path),
                    ),
                    ActionCard(
                      icon: Icons.person,
                      title: 'Profil',
                      subtitle: 'Mettre a jour vos informations.',
                      onTap: () => context.push(AppRoute.userProfile.path),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
