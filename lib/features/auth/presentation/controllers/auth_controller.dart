import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/app_user_model.dart';
import '../../data/models/auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/errors/auth_failure.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthState _state = AuthState.initial();
  AuthState get state => _state;

  StreamSubscription<AppUser?>? _userSub;

  void init() {
    _setState(AuthState(status: AuthStatus.loading));
    _userSub = _repository.userStream.listen((appUser) {
      if (appUser == null) {
        _setState(AuthState.unauthenticated());
      } else {
        final needsEmailVerification = appUser.authProviders.contains('password') &&
            (appUser.emailVerified == false);
        _setState(
          AuthState(
            status: needsEmailVerification
                ? AuthStatus.emailVerificationRequired
                : AuthStatus.authenticated,
            user: appUser,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setState(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      );

      final needsVerification =
          user.authProviders.contains('password') && !user.emailVerified;

      _setState(
        AuthState(
          status: needsVerification
              ? AuthStatus.emailVerificationRequired
              : AuthStatus.authenticated,
          user: user,
        ),
      );
    } on AuthFailure catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Une erreur est survenue lors de la création du compte.');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setState(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );

      final needsVerification =
          user.authProviders.contains('password') && !user.emailVerified;

      _setState(
        AuthState(
          status: needsVerification
              ? AuthStatus.emailVerificationRequired
              : AuthStatus.authenticated,
          user: user,
        ),
      );
    } on AuthFailure catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Impossible de se connecter. Merci de réessayer.');
    }
  }

  Future<void> loginWithGoogle() async {
    _setState(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.signInWithGoogle();
      _setState(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } on AuthFailure catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Erreur lors de la connexion avec Google.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setState(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _repository.sendPasswordResetEmail(email);
      _setState(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Email de réinitialisation envoyé si le compte existe.',
        ),
      );
    } on AuthFailure catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Erreur lors de l’envoi de l’email de réinitialisation.');
    }
  }

  Future<void> resendEmailVerification() async {
    _setState(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _repository.sendEmailVerification();
      _setState(
        state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          errorMessage: 'Email de vérification renvoyé.',
        ),
      );
    } on AuthFailure catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Erreur lors de l’envoi de l’email de vérification.');
    }
  }

  Future<void> checkEmailVerified() async {
    _setState(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final isVerified = await _repository.isEmailVerified();
      if (!isVerified) {
        _setState(state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          errorMessage: 'Ton email n’est pas encore vérifié.',
        ));
      } else {
        final existingUser = state.user;
        final updatedUser =
            existingUser?.copyWith(emailVerified: true) ?? existingUser;
        _setState(
          AuthState(
            status: AuthStatus.authenticated,
            user: updatedUser,
          ),
        );
      }
    } on AuthFailure catch (e) {
      _setError(e.message);
    } on FirebaseAuthException {
      _setError('Erreur lors de la vérification de l’email.');
    } catch (_) {
      _setError('Erreur lors de la vérification de l’email.');
    }
  }

  Future<void> logout() async {
    _setState(state.copyWith(status: AuthStatus.loading, clearError: true));
    await _repository.signOut();
    _setState(AuthState.unauthenticated());
  }

  void clearError() {
    if (state.errorMessage != null) {
      _setState(state.copyWith(clearError: true));
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _setState(
      state.copyWith(
        status: AuthStatus.error,
        errorMessage: message,
      ),
    );
  }
}


