import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../products/data/models/product_model.dart';
import '../../../scanner/data/models/scan_result_model.dart';
import '../../../scanner/data/repositories/scanner_repository.dart';
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
        appBar: AppBar(
          title: const Text('Historique'),
          actions: [
            IconButton(
              tooltip: 'Ajouter un repas',
              icon: const Icon(Icons.add),
              onPressed: () => _openAddMeal(context),
            ),
          ],
        ),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final user =
                          context.read<AuthController>().state.user;
                      if (user == null) return;
                      await context.read<HistoryController>().deleteHistoryItem(
                            userId: user.uid,
                            scanId: item.id,
                          );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer ce repas'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAddMeal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ManualMealSheet(),
    );
  }
}

class _ManualMealSheet extends StatefulWidget {
  const _ManualMealSheet();

  @override
  State<_ManualMealSheet> createState() => _ManualMealSheetState();
}

class _ManualMealSheetState extends State<_ManualMealSheet> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  DateTime _dateTime = DateTime.now();
  bool _saving = false;

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
            Text(
              'Ajouter un repas perso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du repas',
                hintText: 'Ex: Riz poulet',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Le nom est obligatoire.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    controller: _caloriesController,
                    label: 'Calories (kcal)',
                    hint: 'Ex: 650',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    controller: _proteinsController,
                    label: 'Protéines (g)',
                    hint: 'Ex: 35',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    controller: _carbsController,
                    label: 'Glucides (g)',
                    hint: 'Ex: 80',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(
                    controller: _fatsController,
                    label: 'Lipides (g)',
                    hint: 'Ex: 15',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _pickDateTime,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_formatDateTime(_dateTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveMeal,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Enregistrement...' : 'Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) return 'Obligatoire';
        final parsed = double.tryParse(value.replaceAll(',', '.'));
        if (parsed == null || parsed < 0) return 'Nombre invalide';
        return null;
      },
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
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

  String _formatDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<void> _saveMeal() async {
    final authUser = context.read<AuthController>().state.user;
    final repository = context.read<ScannerRepository>();
    final historyController = context.read<HistoryController>();
    final messenger = ScaffoldMessenger.of(context);
    if (authUser == null) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final calories =
        double.parse(_caloriesController.text.trim().replaceAll(',', '.'));
    final proteins =
        double.parse(_proteinsController.text.trim().replaceAll(',', '.'));
    final carbs =
        double.parse(_carbsController.text.trim().replaceAll(',', '.'));
    final fats = double.parse(_fatsController.text.trim().replaceAll(',', '.'));

    setState(() => _saving = true);
    try {
      final productId = 'manual-${_uuid.v4()}';
      final mealProduct = Product(
        id: productId,
        name: _nameController.text.trim(),
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
        createdAt: _dateTime,
        updatedAt: _dateTime,
        createdBy: authUser.uid,
      );

      final scanResult = ScanResultModel(
        rawValue: productId,
        sourceType: ScanSourceType.manual,
      );

      await repository.saveScan(
        userId: authUser.uid,
        product: mealProduct,
        scanResult: scanResult,
      );

      // Rafraîchir l’historique
      await historyController.loadUserHistory(authUser.uid);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible d’ajouter le repas.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

