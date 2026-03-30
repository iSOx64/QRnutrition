import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../history/data/models/scan_history_item_model.dart';
import '../../../history/data/repositories/history_repository.dart';
import '../../../products/data/models/product_model.dart';
import '../../../scanner/data/models/scan_result_model.dart';
import '../../../scanner/data/repositories/scanner_repository.dart';
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
  final _uuid = const Uuid();

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

    final dayMeals = controller.history
        .where((s) => _isSameDay(s.scannedAt, controller.selectedDate))
        .toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _dayHeader(context, controller),
        const SizedBox(height: 12),
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
        const SizedBox(height: 20),
        Text(
          'Repas du jour',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (dayMeals.isEmpty)
          Text(
            'Aucun repas pour cette date.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ...dayMeals.map((m) => _mealTile(context, controller, m)),
      ],
    );
  }

  Widget _dayHeader(BuildContext context, DashboardController controller) {
    final date = controller.selectedDate;
    final label =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Row(
      children: [
        IconButton(
          tooltip: 'Jour précédent',
          onPressed: () async {
            final user = context.read<AuthController>().state.user;
            if (user == null) return;
            final prev = DateTime(date.year, date.month, date.day - 1);
            await controller.loadDaily(
              userId: user.uid,
              goalCalories: widget.goalCalories,
              date: prev,
            );
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Jour suivant',
          onPressed: () async {
            final user = context.read<AuthController>().state.user;
            if (user == null) return;
            final next = DateTime(date.year, date.month, date.day + 1);
            await controller.loadDaily(
              userId: user.uid,
              goalCalories: widget.goalCalories,
              date: next,
            );
          },
          icon: const Icon(Icons.chevron_right),
        ),
        const SizedBox(width: 4),
        FilledButton.icon(
          onPressed: () => _openAddMeal(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _mealTile(
    BuildContext context,
    DashboardController controller,
    ScanHistoryItem meal,
  ) {
    final canEdit = meal.sourceType == 'manual';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(meal.productName),
        subtitle: Text(
          '${meal.calories.toStringAsFixed(0)} kcal • P ${meal.proteins.toStringAsFixed(1)}g • G ${meal.carbs.toStringAsFixed(1)}g • L ${meal.fats.toStringAsFixed(1)}g',
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Supprimer',
              onPressed: () => controller.deleteMeal(scanId: meal.id),
              icon: const Icon(Icons.delete_outline),
            ),
            if (canEdit)
              IconButton(
                tooltip: 'Modifier',
                onPressed: () => _openEditMeal(context, controller, meal),
                icon: const Icon(Icons.edit),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _openAddMeal(BuildContext context, DashboardController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ManualMealFormSheet(
        title: 'Ajouter un repas perso',
        initial: null,
        onSave: (name, calories, proteins, carbs, fats, dateTime) async {
          final user = context.read<AuthController>().state.user;
          if (user == null) return;

          final productId = 'manual-${_uuid.v4()}';
          final mealProduct = Product(
            id: productId,
            name: name,
            brand: 'Perso',
            barcode: null,
            qrCodeValue: null,
            category: 'Repas',
            calories: calories,
            proteins: proteins,
            carbs: carbs,
            fats: fats,
            ingredients: '',
            allergens: '',
            extraNutrients: const <NutrientEntry>[],
            imageUrl: null,
            isActive: true,
            createdAt: dateTime,
            updatedAt: dateTime,
            createdBy: user.uid,
          );

          final repository = context.read<ScannerRepository>();
          final scanResult = ScanResultModel(
            rawValue: productId,
            sourceType: ScanSourceType.manual,
          );

          await repository.saveScan(
            userId: user.uid,
            product: mealProduct,
            scanResult: scanResult,
          );

          await controller.loadDaily(
            userId: user.uid,
            goalCalories: widget.goalCalories,
            date: controller.selectedDate,
          );
        },
      ),
    );
  }

  void _openEditMeal(
    BuildContext context,
    DashboardController controller,
    ScanHistoryItem meal,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ManualMealFormSheet(
        title: 'Modifier le repas',
        initial: meal,
        onSave: (name, calories, proteins, carbs, fats, dateTime) async {
          final updated = meal.copyWith(
            productName: name,
            calories: calories,
            proteins: proteins,
            carbs: carbs,
            fats: fats,
            scannedAt: dateTime,
          );
          await controller.updateManualMeal(updated: updated);
        },
      ),
    );
  }
}

class _ManualMealFormSheet extends StatefulWidget {
  const _ManualMealFormSheet({
    required this.title,
    required this.initial,
    required this.onSave,
  });

  final String title;
  final ScanHistoryItem? initial;
  final Future<void> Function(
    String name,
    double calories,
    double proteins,
    double carbs,
    double fats,
    DateTime dateTime,
  ) onSave;

  @override
  State<_ManualMealFormSheet> createState() => _ManualMealFormSheetState();
}

class _ManualMealFormSheetState extends State<_ManualMealFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;

  late DateTime _dateTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.productName ?? '');
    _caloriesController =
        TextEditingController(text: (initial?.calories ?? 0).toString());
    _proteinsController =
        TextEditingController(text: (initial?.proteins ?? 0).toString());
    _carbsController =
        TextEditingController(text: (initial?.carbs ?? 0).toString());
    _fatsController =
        TextEditingController(text: (initial?.fats ?? 0).toString());
    _dateTime = initial?.scannedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du repas',
                hintText: 'Ex: Riz poulet',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numField(_caloriesController, 'Calories (kcal)'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numField(_proteinsController, 'Protéines (g)'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numField(_carbsController, 'Glucides (g)')),
                const SizedBox(width: 12),
                Expanded(child: _numField(_fatsController, 'Lipides (g)')),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickDateTime,
              icon: const Icon(Icons.calendar_month),
              label: Text(_formatDateTime(_dateTime)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                child: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return 'Obligatoire';
        final parsed = double.tryParse(value.replaceAll(',', '.'));
        if (parsed == null || parsed < 0) return 'Invalide';
        return null;
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<void> _pickDateTime() async {
    // Capture to avoid using context after async gaps.
    final ctx = context;
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: ctx,
      initialDate: _dateTime,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final name = _nameController.text.trim();
    final calories = double.parse(_caloriesController.text.trim().replaceAll(',', '.'));
    final proteins = double.parse(_proteinsController.text.trim().replaceAll(',', '.'));
    final carbs = double.parse(_carbsController.text.trim().replaceAll(',', '.'));
    final fats = double.parse(_fatsController.text.trim().replaceAll(',', '.'));

    setState(() => _saving = true);
    try {
      await widget.onSave(name, calories, proteins, carbs, fats, _dateTime);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l’enregistrement.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
