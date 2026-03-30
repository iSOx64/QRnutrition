import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../models/scan_history_item_model.dart';
import '../models/scan_model.dart';
import '../services/history_firestore_service.dart';

class HistoryRepository {
  HistoryRepository(this._service);

  final HistoryFirestoreService _service;

  Future<List<ScanHistoryItem>> getUserScanHistory({
    required String userId,
    int limit = 100,
  }) async {
    try {
      return await _service.getUserScanHistory(userId: userId, limit: limit);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger l’historique.');
    }
  }

  Future<List<Scan>> getGlobalScans({int limit = 200}) async {
    try {
      return await _service.getGlobalScans(limit: limit);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger les scans.');
    }
  }

  Future<void> deleteHistoryItem({
    required String userId,
    required String scanId,
    bool deleteGlobal = false,
  }) async {
    try {
      await _service.deleteHistoryItem(
        userId: userId,
        scanId: scanId,
        deleteGlobal: deleteGlobal,
      );
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de supprimer l’élément.');
    }
  }

  Future<void> updateHistoryItem({
    required String userId,
    required String scanId,
    required ScanHistoryItem updated,
  }) async {
    try {
      await _service.updateHistoryItem(
        userId: userId,
        scanId: scanId,
        updated: updated,
      );
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de modifier le repas.');
    }
  }
}
