import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/scan_history_item_model.dart';
import '../../data/repositories/history_repository.dart';
import '../controllers/history_controller.dart';
import '../widgets/history_item_tile.dart';

class ScanHistoryPage extends StatelessWidget {
  const ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.state.user;

    if (user == null) {
      return const Scaffold(body: LoadingState());
    }

    return ChangeNotifierProvider(
      create: (context) => HistoryController(
        context.read<HistoryRepository>(),
      )..loadUserHistory(user.uid),
      child: Scaffold(
        appBar: AppBar(title: const Text('Historique')),
        body: Consumer<HistoryController>(
          builder: (context, controller, _) {
            switch (controller.status) {
              case ViewStatus.loading:
                return const LoadingState();
              case ViewStatus.empty:
                return const EmptyState(
                  title: 'Aucun scan',
                  message: 'Votre historique est vide.',
                );
              case ViewStatus.error:
                return EmptyState(
                  title: 'Erreur',
                  message: controller.errorMessage ?? 'Erreur inconnue.',
                );
              case ViewStatus.success:
                return ListView.separated(
                  itemCount: controller.history.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.history[index];
                    return HistoryItemTile(
                      item: item,
                      onTap: () => _showDetails(context, item),
                    );
                  },
                );
              case ViewStatus.initial:
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ScanHistoryItem item) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.productName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Calories: ${item.calories.toStringAsFixed(0)} kcal'),
            Text('Proteines: ${item.proteins.toStringAsFixed(1)} g'),
            Text('Glucides: ${item.carbs.toStringAsFixed(1)} g'),
            Text('Lipides: ${item.fats.toStringAsFixed(1)} g'),
            const SizedBox(height: 12),
            Text('Source: ${item.sourceType}'),
          ],
        ),
      ),
    );
  }
}
