import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:first_app/features/products/data/models/product_model.dart';
import 'package:first_app/features/products/data/repositories/product_repository.dart';
import 'package:first_app/features/products/presentation/controllers/product_controller.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> _items = [];

  @override
  Future<Product> createProduct(Product product) async {
    final created = _withId(product, 'p${_items.length + 1}');
    _items.add(created);
    return created;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _items[index] = product;
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    _items.removeWhere((p) => p.id == productId);
  }

  @override
  Future<Product?> getProductById(String productId) async {
    for (final item in _items) {
      if (item.id == productId) return item;
    }
    return null;
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    for (final item in _items) {
      if (item.barcode == barcode) return item;
    }
    return null;
  }

  @override
  Future<Product?> getProductByQrValue(String qrCodeValue) async {
    for (final item in _items) {
      if (item.qrCodeValue == qrCodeValue) return item;
    }
    return null;
  }

  @override
  Future<List<Product>> searchProductsByName(String query) async {
    return _items
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Product>> getAllProducts({int limit = 200}) async {
    return _items.take(limit).toList();
  }

  @override
  Future<String> uploadProductImage({
    required String productId,
    required XFile imageFile,
  }) async {
    return 'https://example.com/$productId.png';
  }

  Product _withId(Product product, String id) {
    return Product(
      id: id,
      name: product.name,
      brand: product.brand,
      barcode: product.barcode,
      qrCodeValue: product.qrCodeValue,
      category: product.category,
      calories: product.calories,
      proteins: product.proteins,
      carbs: product.carbs,
      fats: product.fats,
      ingredients: product.ingredients,
      allergens: product.allergens,
      extraNutrients: product.extraNutrients,
      imageUrl: product.imageUrl,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      createdBy: product.createdBy,
    );
  }
}

void main() {
  test('ProductController createProduct adds item', () async {
    final repository = FakeProductRepository();
    final controller = ProductController(repository);

    final now = DateTime.now();
    final product = Product(
      id: '',
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

    await controller.createProduct(product);

    expect(controller.products.length, 1);
    expect(controller.products.first.name, 'Test');
  });
}
