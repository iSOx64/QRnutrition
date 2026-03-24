import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/social_login_button.dart';
import '../../data/models/auth_state.dart';
import '../controllers/auth_controller.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _loginWithSocial(
    BuildContext context,
    AuthController controller,
    Future<void> Function() action,
  ) async {
    await action();
    if (!context.mounted) return;
    final status = controller.state.status;
    if (status == AuthStatus.authenticated) {
      context.go(roleHomePath(controller.state.user));
    } else if (status == AuthStatus.emailVerificationRequired) {
      context.go(AppRoute.verifyEmail.path);
    } else if (controller.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isLoading = authController.state.isLoading;

    return Scaffold(
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
                    title: 'Bienvenue sur QR Nutrition',
                    subtitle:
                        'Scanne, analyse et suit ta nutrition en toute simplicite.',
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Se connecter',
                    isLoading: false,
                    onPressed: () {
                      context.push(AppRoute.login.path);
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.push(AppRoute.register.path),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Creer un compte'),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'ou continuer avec',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SocialLoginButton(
                    provider: SocialProvider.google,
                    label: 'Continuer avec Google',
                    onPressed: isLoading
                        ? () {}
                        : () => _loginWithSocial(
                              context,
                              authController,
                              authController.loginWithGoogle,
                            ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Acces professionnel',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRoute.adminLogin.path),
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Admin'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push(AppRoute.superAdminLogin.path),
                        icon: const Icon(Icons.shield),
                        label: const Text('Super Admin'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
