import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../data/models/app_user_model.dart';
import '../../data/models/auth_state.dart';
import '../controllers/auth_controller.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final state = authController.state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = state.user;

      if (!context.mounted) return;

      switch (state.status) {
        case AuthStatus.initial:
        case AuthStatus.loading:
          break;
        case AuthStatus.unauthenticated:
          context.go(AppRoute.welcome.path);
          break;
        case AuthStatus.emailVerificationRequired:
          context.go(AppRoute.verifyEmail.path);
          break;
        case AuthStatus.authenticated:
          context.go(roleHomePath(user));
          break;
        case AuthStatus.error:
          if (user == null) {
            context.go(AppRoute.welcome.path);
          } else {
            context.go(roleHomePath(user));
          }
          break;
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


