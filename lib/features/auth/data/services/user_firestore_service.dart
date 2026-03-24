import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';

class UserFirestoreService {
  UserFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _usersRef.doc(uid);

  Future<AppUser> createUserDocument({
    required User firebaseUser,
    required String fullName,
    required String provider,
  }) async {
    final existingSnapshot = await _userDoc(firebaseUser.uid).get();
    String role = AppUser.defaultRoleUser;
    if (existingSnapshot.exists) {
      final existing = AppUser.fromMap(existingSnapshot.data()!);
      role = existing.role;
    }
    final now = DateTime.now();
    final user = AppUser(
      uid: firebaseUser.uid,
      fullName: fullName,
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      role: role,
      authProviders: [provider],
      emailVerified: firebaseUser.emailVerified,
      dailyCalorieGoal: 2000,
      isProfileComplete: true,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );

    await _userDoc(firebaseUser.uid).set(user.toMap(), SetOptions(merge: true));
    return user;
  }

  Future<AppUser> upsertUserFromSocialLogin({
    required User firebaseUser,
    required String provider,
  }) async {
    final docRef = _userDoc(firebaseUser.uid);
    final snapshot = await docRef.get();
    final now = DateTime.now();

    if (!snapshot.exists) {
      final user = AppUser.initial(
        firebaseUser.uid,
        firebaseUser.email ?? '',
        fullName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        provider: provider,
      ).copyWith(
        emailVerified: firebaseUser.emailVerified,
        lastLoginAt: now,
        updatedAt: now,
      );

      await docRef.set(user.toMap(), SetOptions(merge: true));
      return user;
    }

    final existing = AppUser.fromMap(snapshot.data()!);
    final providers = {
      ...existing.authProviders,
      provider,
    }.toList();

    final updated = existing.copyWith(
      fullName: firebaseUser.displayName ?? existing.fullName,
      email: firebaseUser.email ?? existing.email,
      photoUrl: firebaseUser.photoURL ?? existing.photoUrl,
      authProviders: providers,
      emailVerified: firebaseUser.emailVerified,
      lastLoginAt: now,
      updatedAt: now,
    );

    await docRef.update(updated.toMap());
    return updated;
  }

  Future<AppUser?> fetchUser(String uid) async {
    final snapshot = await _userDoc(uid).get();
    if (!snapshot.exists) return null;
    return AppUser.fromMap(snapshot.data()!);
  }

  Future<void> updateLastLogin({
    required String uid,
    required String provider,
    bool? emailVerified,
  }) async {
    final docRef = _userDoc(uid);
    final now = DateTime.now();
    final data = <String, dynamic>{
      'lastLoginAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'authProviders': FieldValue.arrayUnion([provider]),
    };
    if (emailVerified != null) {
      data['emailVerified'] = emailVerified;
    }
    await docRef.set(data, SetOptions(merge: true));
  }
}


