import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../products/data/models/product_model.dart';
import '../models/scan_result_model.dart';
import '../services/scanner_firestore_service.dart';
import '../services/scanner_service.dart';

class ScannerRepository {
  ScannerRepository(this._scannerService, this._firestoreService);

  final ScannerService _scannerService;
  final ScannerFirestoreService _firestoreService;

  ScanResultModel parseRawValue(String rawValue, {ScanSourceType? hint}) {
    return _scannerService.parseRawValue(rawValue, hint: hint);
  }

  Future<Product?> findProduct(ScanResultModel result) async {
    try {
      return await _firestoreService.findProductByCode(result);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Erreur lors de la recherche du produit.');
    }
  }

  Future<void> saveScan({
    required String userId,
    required Product product,
    required ScanResultModel scanResult,
  }) async {
    try {
      await _firestoreService.saveScan(
        userId: userId,
        product: product,
        scanResult: scanResult,
      );
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Erreur lors de l’enregistrement du scan.');
    }
  }
}
