import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/scan_history_item_model.dart';
import '../models/scan_model.dart';

class HistoryFirestoreService {
  HistoryFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _scansRef =>
      _firestore.collection('scans');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<List<ScanHistoryItem>> getUserScanHistory({
    required String userId,
    int limit = 100,
  }) async {
    final snapshot = await _usersRef
        .doc(userId)
        .collection('scan_history')
        .orderBy('scannedAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(ScanHistoryItem.fromDoc).toList();
  }

  Future<List<Scan>> getGlobalScans({int limit = 200}) async {
    final snapshot = await _scansRef
        .orderBy('scannedAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(Scan.fromDoc).toList();
  }

  Future<void> deleteHistoryItem({
    required String userId,
    required String scanId,
    bool deleteGlobal = false,
  }) async {
    final batch = _firestore.batch();
    batch.delete(
      _usersRef.doc(userId).collection('scan_history').doc(scanId),
    );
    if (deleteGlobal) {
      batch.delete(_scansRef.doc(scanId));
    }
    await batch.commit();
  }
}
