import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/auth_failure.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthFailure(
          'user-null',
          'Impossible de créer le compte utilisateur.',
        );
      }
      await user.sendEmailVerification();
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthFailure(
          'user-null',
          'Impossible de se connecter avec cet utilisateur.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthFailure('no-user', 'Aucun utilisateur connecté.');
    }
    await user.sendEmailVerification();
  }

  Future<User?> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    return _auth.currentUser;
  }

  Future<User> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure('aborted', 'Connexion Google annulée.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential).catchError(
        (error) {
          if (error is FirebaseAuthException) {
            throw _mapFirebaseAuthException(error);
          }
          throw AuthFailure(
            'google-sign-in-error',
            'Erreur lors de la connexion avec Google.',
          );
        },
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthFailure(
          'user-null',
          'Impossible de se connecter avec Google.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn().signOut(),
    ]);
  }

  AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthFailure(
          e.code,
          'Adresse e-mail invalide.',
        );
      case 'user-disabled':
        return AuthFailure(
          e.code,
          'Ce compte est désactivé.',
        );
      case 'user-not-found':
        return AuthFailure(
          e.code,
          'Aucun utilisateur trouvé avec cet e-mail.',
        );
      case 'wrong-password':
        return AuthFailure(
          e.code,
          'Mot de passe incorrect.',
        );
      case 'email-already-in-use':
        return AuthFailure(
          e.code,
          'Un compte existe déjà avec cet e-mail.',
        );
      case 'weak-password':
        return AuthFailure(
          e.code,
          'Le mot de passe est trop faible.',
        );
      case 'account-exists-with-different-credential':
        return AuthFailure(
          e.code,
          'Un compte existe déjà avec cet e-mail mais avec un autre moyen de connexion. '
          'Connecte-toi avec le provider associé puis associe les comptes si besoin.',
        );
      default:
        return AuthFailure(
          e.code,
          'Une erreur d’authentification est survenue. Merci de réessayer.',
        );
    }
  }
}


