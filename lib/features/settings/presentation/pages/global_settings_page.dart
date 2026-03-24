import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/repositories/app_settings_repository.dart';
import '../controllers/settings_controller.dart';

class GlobalSettingsPage extends StatefulWidget {
  const GlobalSettingsPage({super.key});

  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  final _categoriesController = TextEditingController();
  final _maxCaloriesController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _initialized = false;

  @override
  void dispose() {
    _categoriesController.dispose();
    _maxCaloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          SettingsController(context.read<AppSettingsRepository>())
            ..loadSettings(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Parametres globaux')),
        body: Consumer<SettingsController>(
          builder: (context, controller, _) {
            if (controller.status == ViewStatus.loading) {
              return const LoadingState();
            }

            final settings = controller.settings;
            if (settings == null) {
              return const Center(child: Text('Configuration introuvable'));
            }

            if (!_initialized) {
              _notificationsEnabled = settings.notificationsEnabled;
              _categoriesController.text =
                  settings.supportedCategories.join(', ');
              _maxCaloriesController.text =
                  settings.maxDailyCaloriesDefault.toString();
              _initialized = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                    title: const Text('Notifications actives'),
                  ),
                  TextField(
                    controller: _categoriesController,
                    decoration: const InputDecoration(
                      labelText: 'Categories supportees',
                      helperText: 'Separees par des virgules',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxCaloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max calories par defaut',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: controller.isSaving
                          ? null
                          : () async {
                              final updated = AppSettings(
                                notificationsEnabled: _notificationsEnabled,
                                supportedCategories: _parseCategories(),
                                maxDailyCaloriesDefault: int.tryParse(
                                      _maxCaloriesController.text.trim(),
                                    ) ??
                                    settings.maxDailyCaloriesDefault,
                                updatedAt: DateTime.now(),
                              );
                              await controller.updateSettings(updated);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Parametres mis a jour'),
                                ),
                              );
                            },
                      child: Text(
                        controller.isSaving
                            ? 'Sauvegarde...'
                            : 'Enregistrer',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<String> _parseCategories() {
    return _categoriesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
