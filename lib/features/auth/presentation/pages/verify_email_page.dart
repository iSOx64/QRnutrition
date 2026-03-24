import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/auth_state.dart';
import '../controllers/auth_controller.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  Future<void> _checkVerified(
      BuildContext context, AuthController controller) async {
    await controller.checkEmailVerified();
    if (!context.mounted) return;

    final status = controller.state.status;
    if (status == AuthStatus.authenticated) {
      context.go(roleHomePath(controller.state.user));
    } else if (controller.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.state.errorMessage!)),
      );
    }
  }

  Future<void> _resend(BuildContext context, AuthController controller) async {
    await controller.resendEmailVerification();
    if (!context.mounted) return;
    if (controller.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.state.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de vérification renvoyé.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final isLoading = controller.state.isLoading;
    final email = controller.state.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthHeader(
                    title: 'Vérifie ton email',
                    subtitle:
                        'Nous avons envoyé un lien de vérification à ton adresse email.',
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'J’ai vérifié',
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => _checkVerified(context, controller),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed:
                        isLoading ? null : () => _resend(context, controller),
                    child: const Text('Renvoyer l’email'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(AppRoute.welcome.path),
                    child: const Text('Changer d’email / Se déconnecter'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


