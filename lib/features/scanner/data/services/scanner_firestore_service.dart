import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/scan_result_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../../history/data/models/scan_model.dart';
import '../../../history/data/models/scan_history_item_model.dart';

class ScannerFirestoreService {
  ScannerFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _scansRef =>
      _firestore.collection('scans');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<Product?> findProductByCode(ScanResultModel result) async {
    if (result.rawValue.trim().isEmpty) return null;
    return getProductByBarcode(result.rawValue);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final snapshot = await _productsRef
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Product.fromDoc(snapshot.docs.first);
  }

  Future<void> saveScan({
    required String userId,
    required Product product,
    required ScanResultModel scanResult,
  }) async {
    final now = DateTime.now();
    final scanId = _scansRef.doc().id;

    final scan = Scan(
      id: scanId,
      userId: userId,
      productId: product.id,
      barcode: product.barcode,
      qrCodeValue: product.qrCodeValue,
      productName: product.name,
      calories: product.calories,
      proteins: product.proteins,
      carbs: product.carbs,
      fats: product.fats,
      scannedAt: now,
      sourceType: scanResult.sourceType.value,
    );

    final historyItem = ScanHistoryItem(
      id: scanId,
      productId: product.id,
      barcode: product.barcode,
      qrCodeValue: product.qrCodeValue,
      productName: product.name,
      calories: product.calories,
      proteins: product.proteins,
      carbs: product.carbs,
      fats: product.fats,
      scannedAt: now,
      sourceType: scanResult.sourceType.value,
    );

    final batch = _firestore.batch();
    batch.set(_scansRef.doc(scanId), scan.toMap());
    batch.set(
      _usersRef
          .doc(userId)
          .collection('scan_history')
          .doc(scanId),
      historyItem.toMap(),
    );
    await batch.commit();
  }
}
