import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_failure.dart';
import '../models/product_model.dart';
import '../services/product_firestore_service.dart';
import '../services/product_storage_service.dart';

class ProductRepository {
  ProductRepository(this._service, this._storageService);

  final ProductFirestoreService _service;
  final ProductStorageService _storageService;

  Future<Product> createProduct(Product product) async {
    try {
      return await _service.createProduct(product);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de creer le produit.');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _service.updateProduct(product);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de mettre a jour le produit.');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _service.deleteProduct(productId);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de supprimer le produit.');
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      return await _service.getProductById(productId);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Produit introuvable.');
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      return await _service.getProductByBarcode(barcode);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Produit introuvable.');
    }
  }

  Future<Product?> getProductByQrValue(String qrCodeValue) async {
    try {
      return await _service.getProductByQrValue(qrCodeValue);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Produit introuvable.');
    }
  }

  Future<List<Product>> searchProductsByName(String query) async {
    try {
      return await _service.searchProductsByName(query);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Erreur de recherche.');
    }
  }

  Future<List<Product>> getAllProducts({int limit = 200}) async {
    try {
      return await _service.getAllProducts(limit: limit);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger les produits.');
    }
  }

  Future<String> uploadProductImage({
    required String productId,
    required XFile imageFile,
  }) async {
    try {
      return await _storageService.uploadProductImage(
        productId: productId,
        imageFile: imageFile,
      );
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de televerser l image.');
    }
  }
}
