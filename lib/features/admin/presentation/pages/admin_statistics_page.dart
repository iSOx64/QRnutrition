import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../data/repositories/admin_repository.dart';
import '../controllers/admin_stats_controller.dart';

class AdminStatisticsPage extends StatelessWidget {
  const AdminStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AdminStatsController(context.read<AdminRepository>())..loadStats(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Statistiques')),
        body: Consumer<AdminStatsController>(
          builder: (context, controller, _) {
            if (controller.status == ViewStatus.loading) {
              return const LoadingState();
            }

            final stats = controller.stats;
            if (stats == null) {
              return const Center(child: Text('Aucune statistique'));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatCard(
                      label: 'Produits',
                      value: '${stats.totalProducts}',
                      icon: Icons.inventory_2,
                    ),
                    StatCard(
                      label: 'Scans',
                      value: '${stats.totalScans}',
                      icon: Icons.qr_code_scanner,
                    ),
                    StatCard(
                      label: 'Utilisateurs',
                      value: '${stats.totalUsers}',
                      icon: Icons.people,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Produits populaires',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...stats.popularProducts.map((item) {
                  return ListTile(
                    leading: const Icon(Icons.star),
                    title: Text(item.productName),
                    trailing: Text('${item.scanCount} scans'),
                  );
                }),
                const SizedBox(height: 24),
                Text(
                  'Activite recente',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...stats.recentScans.map((scan) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(scan.productName),
                    subtitle:
                        Text(scan.scannedAt.toLocal().toString().split('.').first),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
