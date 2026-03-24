import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../services/super_admin_service.dart';

class SuperAdminRepository {
  SuperAdminRepository(this._service);

  final SuperAdminService _service;

  Future<List<AppUser>> getAllUsers({int limit = 200}) async {
    try {
      return await _service.getAllUsers(limit: limit);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger les utilisateurs.');
    }
  }

  Future<AppUser?> getUserById(String uid) async {
    try {
      return await _service.getUserById(uid);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger l’utilisateur.');
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
