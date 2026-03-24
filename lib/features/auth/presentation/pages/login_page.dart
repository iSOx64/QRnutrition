import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/role_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/social_login_button.dart';
import '../../data/models/app_user_model.dart';
import '../../data/models/auth_state.dart';
import '../controllers/auth_controller.dart';

enum LoginTarget {
  user,
  admin,
  superAdmin,
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.target = LoginTarget.user,
  });

  final LoginTarget target;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.target) {
      case LoginTarget.admin:
        return 'Connexion Admin';
      case LoginTarget.superAdmin:
        return 'Connexion Super Admin';
      case LoginTarget.user:
        return 'Connexion';
    }
  }

  String get _subtitle {
    switch (widget.target) {
      case LoginTarget.admin:
        return 'Acces reserve aux administrateurs de la plateforme.';
      case LoginTarget.superAdmin:
        return 'Acces reserve aux super administrateurs.';
      case LoginTarget.user:
        return 'Retrouve tes donnees nutritionnelles en te connectant.';
    }
  }

  bool get _showRegister => widget.target == LoginTarget.user;

  bool get _showSocialLogin => widget.target == LoginTarget.user;

  bool _isRoleAllowed(AppUser? user) {
    switch (widget.target) {
      case LoginTarget.user:
        return isUser(user);
      case LoginTarget.admin:
        return isAdmin(user);
      case LoginTarget.superAdmin:
        return isSuperAdmin(user);
    }
  }

  String _accessDeniedMessage() {
    switch (widget.target) {
      case LoginTarget.admin:
        return 'Acces reserve aux administrateurs.';
      case LoginTarget.superAdmin:
        return 'Acces reserve aux super administrateurs.';
      case LoginTarget.user:
        return 'Acces reserve aux utilisateurs.';
    }
  }

  Future<void> _handleAuthResult(AuthController controller) async {
    final status = controller.state.status;
    if (!mounted) return;

    if (status == AuthStatus.emailVerificationRequired) {
      context.go(AppRoute.verifyEmail.path);
      return;
    }

    if (status == AuthStatus.authenticated) {
      final user = controller.state.user;
      if (_isRoleAllowed(user)) {
        context.go(roleHomePath(user));
        return;
      }

      await controller.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_accessDeniedMessage())),
      );
      return;
    }

    if (controller.state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.state.errorMessage!)),
      );
    }
  }

  Future<void> _submit(AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    await controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    await _handleAuthResult(controller);
  }

  Future<void> _loginWithSocial(
    AuthController controller,
    Future<void> Function() action,
  ) async {
    await action();
    await _handleAuthResult(controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final isLoading = controller.state.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthHeader(
                      title: _title,
                      subtitle: _subtitle,
                    ),
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Mot de passe',
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.push(AppRoute.forgotPassword.path),
                        child: const Text('Mot de passe oublie ?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Se connecter',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _submit(controller),
                    ),
                    if (_showSocialLogin) ...[
                      const SizedBox(height: 16),
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
                                  controller,
                                  controller.loginWithGoogle,
                                ),
                      ),
                    ],
                    if (_showRegister) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Pas encore de compte ?'),
                          TextButton(
                            onPressed: () => context.go(AppRoute.register.path),
                            child: const Text('Creer un compte'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
