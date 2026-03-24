import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_log_model.dart';
import '../models/admin_stats_model.dart';

class AdminFirestoreService {
  AdminFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _scansRef =>
      _firestore.collection('scans');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _adminLogsRef =>
      _firestore.collection('admin_logs');

  Future<void> createAdminLog(AdminLog log) async {
    final docRef = _adminLogsRef.doc();
    await docRef.set(log.toMap());
  }

  Future<List<AdminLog>> getAdminLogs({
    String? action,
    int limit = 200,
  }) async {
    Query<Map<String, dynamic>> query =
        _adminLogsRef.orderBy('createdAt', descending: true);
    if (action != null && action.isNotEmpty) {
      query = query.where('action', isEqualTo: action);
    }
    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map(AdminLog.fromDoc).toList();
  }

  Future<List<AdminLog>> getSystemLogs({int limit = 200}) async {
    final snapshot = await _adminLogsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(AdminLog.fromDoc).toList();
  }

  Future<AdminStats> getAdminStats() async {
    final totalProducts = await _safeCount(_productsRef);
    final totalScans = await _safeCount(_scansRef);
    final totalUsers = await _safeCount(_usersRef);

    final scansSnapshot = await _scansRef
        .orderBy('scannedAt', descending: true)
        .limit(200)
        .get();

    final scanCounts = <String, PopularProductStat>{};
    final recentScans = <RecentScanActivity>[];

    for (final doc in scansSnapshot.docs) {
      final data = doc.data();
      final productId = data['productId'] as String? ?? '';
      final productName = data['productName'] as String? ?? 'Produit';
      final scannedAtTs = data['scannedAt'] as Timestamp?;
      if (scannedAtTs != null) {
        recentScans.add(
          RecentScanActivity(
            scanId: doc.id,
            productName: productName,
            scannedAt: scannedAtTs.toDate(),
          ),
        );
      }
      if (productId.isEmpty) continue;
      final existing = scanCounts[productId];
      if (existing == null) {
        scanCounts[productId] = PopularProductStat(
          productId: productId,
          productName: productName,
          scanCount: 1,
        );
      } else {
        scanCounts[productId] = PopularProductStat(
          productId: productId,
          productName: productName,
          scanCount: existing.scanCount + 1,
        );
      }
    }

    final popularProducts = scanCounts.values.toList()
      ..sort((a, b) => b.scanCount.compareTo(a.scanCount));

    return AdminStats(
      totalProducts: totalProducts,
      totalScans: totalScans,
      totalUsers: totalUsers,
      popularProducts: popularProducts.take(5).toList(),
      recentScans: recentScans.take(10).toList(),
    );
  }

  Future<int> _safeCount(Query<Map<String, dynamic>> query) async {
    try {
      final result = await query.count().get();
      return result.count ?? 0;
    } catch (_) {
      final snapshot = await query.get();
      return snapshot.size;
    }
  }
}
