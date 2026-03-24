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
    if (result.isBarcode) {
      // Try barcode first, then fall back to QR lookup
      final byBarcode = await getProductByBarcode(result.rawValue);
      if (byBarcode != null) return byBarcode;
      return getProductByQrValue(result.rawValue);
    }
    if (result.isQrCode) {
      return getProductByQrValue(result.rawValue);
    }
    // Unknown format: try both lookups
    final byQr = await getProductByQrValue(result.rawValue);
    if (byQr != null) return byQr;
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

  Future<Product?> getProductByQrValue(String qrCodeValue) async {
    final snapshot = await _productsRef
        .where('qrCodeValue', isEqualTo: qrCodeValue)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return Product.fromDoc(snapshot.docs.first);
    }

    // Fallback: if QR contient l'id du produit (ex: QR-<id>-<ts>),
    // on tente de retrouver directement le document.
    final productId = _extractProductId(qrCodeValue);
    if (productId == null) return null;
    final doc = await _productsRef.doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromDoc(doc);
  }

  String? _extractProductId(String value) {
    // Pattern: QR-<productId>-<timestamp>
    final match = RegExp(r'^QR-([A-Za-z0-9_-]+)-\d+$').firstMatch(value);
    if (match == null) return null;
    return match.group(1);
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
