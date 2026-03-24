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
import '../../../admin/data/repositories/admin_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/super_admin_controller.dart';

class SuperAdminHomePage extends StatelessWidget {
  const SuperAdminHomePage({super.key});

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
      create: (context) => SuperAdminController(
        context.read<AdminRepository>(),
      )..loadSummary(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Espace Super Admin'),
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
        body: Consumer<SuperAdminController>(
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
                  subtitle: 'Surveillez les acces et la gouvernance globale.',
                  icon: Icons.shield,
                  badge: RoleBadge(role: user.role),
                  gradientColors: const [
                    AppColors.primary,
                    AppColors.textPrimary,
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionHeader(
                  title: "Vue d'ensemble",
                  subtitle: 'Indicateurs globaux et activite recente.',
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
                  title: 'Commandes sensibles',
                  subtitle: 'Actions reservees au super admin.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ActionCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Gestion admins',
                      subtitle: 'Creer et modifier les roles.',
                      onTap: () => context.push(AppRoute.manageAdmins.path),
                      accentColor: AppColors.secondary.withOpacity(0.25),
                    ),
                    ActionCard(
                      icon: Icons.settings,
                      title: 'Parametres',
                      subtitle: 'Configurer les options globales.',
                      onTap: () => context.push(AppRoute.globalSettings.path),
                    ),
                    ActionCard(
                      icon: Icons.list_alt,
                      title: 'Logs systeme',
                      subtitle: 'Suivre les actions critiques.',
                      onTap: () => context.push(AppRoute.systemLogs.path),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Operations produit',
                  subtitle: 'Acces rapide aux modules admin.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ActionCard(
                      icon: Icons.inventory,
                      title: 'Produits',
                      subtitle: 'Gestion complete du catalogue.',
                      onTap: () => context.push(AppRoute.adminProducts.path),
                    ),
                    ActionCard(
                      icon: Icons.insights,
                      title: 'Statistiques',
                      subtitle: 'Analyser la performance globale.',
                      onTap: () => context.push(AppRoute.adminStatistics.path),
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
