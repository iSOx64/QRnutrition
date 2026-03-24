import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../models/admin_log_model.dart';
import '../models/admin_stats_model.dart';
import '../services/admin_firestore_service.dart';

class AdminRepository {
  AdminRepository(this._service);

  final AdminFirestoreService _service;

  Future<void> createAdminLog(AdminLog log) async {
    try {
      await _service.createAdminLog(log);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de journaliser l’action.');
    }
  }

  Future<List<AdminLog>> getAdminLogs({
    String? action,
    int limit = 200,
  }) async {
    try {
      return await _service.getAdminLogs(action: action, limit: limit);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger les logs.');
    }
  }

  Future<List<AdminLog>> getSystemLogs({int limit = 200}) async {
    try {
      return await _service.getSystemLogs(limit: limit);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger les logs système.');
    }
  }

  Future<AdminStats> getAdminStats() async {
    try {
      return await _service.getAdminStats();
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger les statistiques.');
    }
  }
}
