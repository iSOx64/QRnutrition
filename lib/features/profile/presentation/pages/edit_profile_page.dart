import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _goalController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final authUser = auth.state.user;

    if (authUser == null) {
      return const Scaffold(body: LoadingState());
    }

    return ChangeNotifierProvider(
      create: (context) => ProfileController(
        context.read<ProfileRepository>(),
      )..loadProfile(authUser.uid),
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: Consumer<ProfileController>(
          builder: (context, controller, _) {
            if (controller.status.isLoading) {
              return const LoadingState();
            }

            final user = controller.user ?? authUser;
            if (!_initialized) {
              _fullNameController.text = user.fullName;
              _goalController.text = user.dailyCalorieGoal.toString();
              _initialized = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration:
                          const InputDecoration(labelText: 'Nom complet'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nom requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                        labelText: 'Objectif calorique journalier',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Objectif requis';
                        }
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Objectif invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label:
                          controller.isSaving ? 'Sauvegarde...' : 'Enregistrer',
                      onPressed: controller.isSaving
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final goal =
                                  int.parse(_goalController.text.trim());
                              await controller.updateProfile(
                                uid: authUser.uid,
                                fullName: _fullNameController.text.trim(),
                                dailyCalorieGoal: goal,
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
