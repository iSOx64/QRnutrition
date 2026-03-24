import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_firestore_service.dart';
import '../../../../core/errors/auth_failure.dart';

class AuthRepository {
  AuthRepository(this._authService, this._userService);

  final FirebaseAuthService _authService;
  final UserFirestoreService _userService;

  Stream<AppUser?> get userStream async* {
    await for (final user in _authService.authStateChanges()) {
      if (user == null) {
        yield null;
      } else {
        yield await _userService.fetchUser(user.uid);
      }
    }
  }

  User? get currentFirebaseUser => _authService.currentUser;

  Future<AppUser> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final user = await _authService.registerWithEmail(
      email: email,
      password: password,
    );

    final appUser = await _userService.createUserDocument(
      firebaseUser: user,
      fullName: fullName,
      provider: 'password',
    );

    return appUser;
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    await _userService.updateLastLogin(
      uid: user.uid,
      provider: 'password',
      emailVerified: user.emailVerified,
    );

    final appUser = await _userService.fetchUser(user.uid);
    if (appUser == null) {
      // Create a default document if missing
      return _userService.createUserDocument(
        firebaseUser: user,
        fullName: user.displayName ?? '',
        provider: 'password',
      );
    }
    return appUser;
  }

  Future<AppUser> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    return _userService.upsertUserFromSocialLogin(
      firebaseUser: user,
      provider: 'google',
    );
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> sendEmailVerification() => _authService.sendEmailVerification();

  Future<User?> reloadCurrentUser() => _authService.reloadCurrentUser();

  Future<void> signOut() => _authService.signOut();

  Future<bool> isEmailVerified() async {
    final user = await reloadCurrentUser();
    if (user == null) {
      throw AuthFailure('no-user', 'Aucun utilisateur connecté.');
    }
    if (user.emailVerified) {
      await _userService.updateLastLogin(
        uid: user.uid,
        provider: 'password',
        emailVerified: true,
      );
      return true;
    }
    return false;
  }
}


