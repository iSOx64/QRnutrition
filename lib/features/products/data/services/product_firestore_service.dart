import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductFirestoreService {
  ProductFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  Future<Product> createProduct(Product product) async {
    final now = DateTime.now();
    final docRef = _productsRef.doc();
    final qrCodeValue = product.qrCodeValue == null ||
            product.qrCodeValue!.trim().isEmpty
        ? 'QR-${docRef.id}-${now.millisecondsSinceEpoch}'
        : product.qrCodeValue;
    final created = Product(
      id: docRef.id,
      name: product.name,
      brand: product.brand,
      barcode: product.barcode,
      qrCodeValue: qrCodeValue,
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
      createdAt: now,
      updatedAt: now,
      createdBy: product.createdBy,
    );
    await docRef.set(created.toMap());
    return created;
  }

  Future<void> updateProduct(Product product) async {
    final updated = product.copyWith(updatedAt: DateTime.now());
    await _productsRef.doc(product.id).update(updated.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }

  Future<Product?> getProductById(String productId) async {
    final snapshot = await _productsRef.doc(productId).get();
    if (!snapshot.exists) return null;
    return Product.fromDoc(snapshot);
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
    if (snapshot.docs.isEmpty) return null;
    return Product.fromDoc(snapshot.docs.first);
  }

  Future<List<Product>> searchProductsByName(String query) async {
    if (query.trim().isEmpty) return [];
    final normalized = query.trim();
    final snapshot = await _productsRef
        .orderBy('name')
        .startAt([normalized])
        .endAt(['$normalized\uf8ff'])
        .get();
    return snapshot.docs.map(Product.fromDoc).toList();
  }

  Future<List<Product>> getAllProducts({int limit = 200}) async {
    final snapshot =
        await _productsRef.orderBy('name').limit(limit).get();
    return snapshot.docs.map(Product.fromDoc).toList();
  }
}
