import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/features/scanner/data/models/scan_result_model.dart';
import 'package:first_app/features/scanner/data/repositories/scanner_repository.dart';
import 'package:first_app/features/scanner/presentation/controllers/scanner_controller.dart';
import 'package:first_app/features/products/data/models/product_model.dart';
import 'package:first_app/features/auth/data/models/app_user_model.dart';

class FakeScannerRepository implements ScannerRepository {
  FakeScannerRepository(this._product);

  final Product _product;
  int saved = 0;

  @override
  ScanResultModel parseRawValue(String rawValue, {ScanSourceType? hint}) {
    return ScanResultModel(
      rawValue: rawValue,
      sourceType: hint ?? ScanSourceType.barcode,
    );
  }

  @override
  Future<Product?> findProduct(ScanResultModel result) async {
    return _product;
  }

  @override
  Future<void> saveScan({
    required String userId,
    required Product product,
    required ScanResultModel scanResult,
  }) async {
    saved += 1;
  }
}

void main() {
  test('ScannerController processes scan and saves history', () async {
    final now = DateTime.now();
    final product = Product(
      id: 'p1',
      name: 'Test',
      brand: 'Brand',
      barcode: '123',
      qrCodeValue: null,
      category: 'Cat',
      calories: 100,
      proteins: 10,
      carbs: 20,
      fats: 5,
      ingredients: '',
      allergens: '',
      extraNutrients: const [],
      imageUrl: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      createdBy: 'admin',
    );

    final repository = FakeScannerRepository(product);
    final controller = ScannerController(repository);
    final user = AppUser.initial('u1', 'user@test.com');

    await controller.processScannedCode(
      rawValue: '123',
      userId: user.uid,
      currentUser: user,
      hint: ScanSourceType.barcode,
    );

    expect(controller.product?.id, 'p1');
    expect(repository.saved, 1);
  });
}
