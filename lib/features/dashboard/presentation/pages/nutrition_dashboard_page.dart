import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../history/data/repositories/history_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/macro_summary_card.dart';
import '../widgets/nutrition_progress_card.dart';

class NutritionDashboardPage extends StatelessWidget {
  const NutritionDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.state.user;

    if (user == null) {
      return const Scaffold(body: LoadingState());
    }

    return ChangeNotifierProvider(
      create: (context) => DashboardController(
        context.read<HistoryRepository>(),
        context.read<DashboardRepository>(),
      )..loadDaily(
          userId: user.uid,
          goalCalories: user.dailyCalorieGoal,
        ),
      child: _DashboardView(goalCalories: user.dailyCalorieGoal),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({required this.goalCalories});

  final int goalCalories;

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  String _mode = 'daily';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          DropdownButton<String>(
            value: _mode,
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Jour')),
              DropdownMenuItem(value: 'weekly', child: Text('Semaine')),
            ],
            onChanged: (value) async {
              if (value == null) return;
              setState(() => _mode = value);
              if (_mode == 'daily') {
                await controller.loadDaily(
                  userId: context.read<AuthController>().state.user!.uid,
                  goalCalories: widget.goalCalories,
                );
              } else {
                await controller.loadWeekly(
                  userId: context.read<AuthController>().state.user!.uid,
                  goalCalories: widget.goalCalories,
                );
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          switch (controller.status) {
            case ViewStatus.loading:
              return const LoadingState();
            case ViewStatus.empty:
              return const EmptyState(
                title: 'Aucune donnee',
                message: 'Aucun scan pour cette periode.',
              );
            case ViewStatus.error:
              return EmptyState(
                title: 'Erreur',
                message: controller.errorMessage ?? 'Erreur inconnue.',
              );
            case ViewStatus.success:
              return _buildContent(context, controller);
            case ViewStatus.initial:
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DashboardController controller,
  ) {
    final summary = controller.dailySummary;
    final weekly = controller.weeklySummary;

    if (_mode == 'weekly' && weekly != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NutritionProgressCard(
            title: 'Calories hebdo',
            valueText: '${weekly.totalCalories.toStringAsFixed(0)} kcal',
            progress: weekly.totalCalories / (widget.goalCalories * 7),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MacroSummaryCard(
                label: 'Proteines',
                value: weekly.totalProteins,
                unit: 'g',
              ),
              MacroSummaryCard(
                label: 'Glucides',
                value: weekly.totalCarbs,
                unit: 'g',
              ),
              MacroSummaryCard(
                label: 'Lipides',
                value: weekly.totalFats,
                unit: 'g',
              ),
            ],
          ),
        ],
      );
    }

    if (summary == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NutritionProgressCard(
          title: 'Calories du jour',
          valueText:
              '${summary.totalCalories.toStringAsFixed(0)} / ${summary.goalCalories.toStringAsFixed(0)} kcal',
          progress: summary.caloriesProgress,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MacroSummaryCard(
              label: 'Proteines',
              value: summary.totalProteins,
              unit: 'g',
            ),
            MacroSummaryCard(
              label: 'Glucides',
              value: summary.totalCarbs,
              unit: 'g',
            ),
            MacroSummaryCard(
              label: 'Lipides',
              value: summary.totalFats,
              unit: 'g',
            ),
          ],
        ),
      ],
    );
  }
}
