import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../services/profile_firestore_service.dart';

class ProfileRepository {
  ProfileRepository(this._service);

  final ProfileFirestoreService _service;

  Future<AppUser?> getCurrentUserProfile() async {
    try {
      return await _service.getCurrentUserProfile();
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger le profil.');
    }
  }

  Future<AppUser?> getUserById(String uid) async {
    try {
      return await _service.getUserById(uid);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger le profil.');
    }
  }

  Future<List<AppUser>> getAllUsers({int limit = 200}) async {
    try {
      return await _service.getAllUsers(limit: limit);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger les utilisateurs.');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    int? dailyCalorieGoal,
    String? photoUrl,
    bool? isProfileComplete,
  }) async {
    try {
      await _service.updateUserProfile(
        uid: uid,
        fullName: fullName,
        dailyCalorieGoal: dailyCalorieGoal,
        photoUrl: photoUrl,
        isProfileComplete: isProfileComplete,
      );
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de mettre à jour le profil.');
    }
  }

  Future<void> updateDailyCalorieGoal({
    required String uid,
    required int dailyCalorieGoal,
  }) async {
    try {
      await _service.updateDailyCalorieGoal(
        uid: uid,
        dailyCalorieGoal: dailyCalorieGoal,
      );
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de mettre à jour l’objectif.');
    }
  }

  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    try {
      await _service.updateUserRole(uid: uid, role: role);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de mettre à jour le rôle.');
    }
  }
}
