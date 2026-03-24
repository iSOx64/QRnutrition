import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/view_state.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../data/models/admin_log_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminProductsController extends ChangeNotifier {
  AdminProductsController(this._productRepository, this._adminRepository);

  final ProductRepository _productRepository;
  final AdminRepository _adminRepository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  List<Product> _products = [];
  List<Product> get products => _products;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _setState(ViewStatus.loading);
    try {
      final list = await _productRepository.getAllProducts();
      _products = list;
      _setState(list.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les produits.');
    }
  }

  Future<void> createProduct({
    required Product product,
    required String adminId,
    XFile? imageFile,
  }) async {
    _setState(ViewStatus.loading);
    try {
      var created = await _productRepository.createProduct(product);

      if (imageFile != null) {
        final imageUrl = await _productRepository.uploadProductImage(
          productId: created.id,
          imageFile: imageFile,
        );
        final withImage = created.copyWith(imageUrl: imageUrl);
        await _productRepository.updateProduct(withImage);
        created = withImage;
      }

      _products = [created, ..._products];
      await _adminRepository.createAdminLog(
        AdminLog(
          id: '',
          adminId: adminId,
          action: 'create_product',
          targetId: created.id,
          details: 'Produit cree: ${created.name}',
          createdAt: DateTime.now(),
        ),
      );
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de creer le produit.');
    }
  }

  Future<void> updateProduct({
    required Product product,
    required String adminId,
    XFile? imageFile,
    bool removeImage = false,
  }) async {
    _setState(ViewStatus.loading);
    try {
      var updated = product;
      if (removeImage) {
        updated = updated.copyWith(imageUrl: null);
      }
      if (imageFile != null) {
        final imageUrl = await _productRepository.uploadProductImage(
          productId: product.id,
          imageFile: imageFile,
        );
        updated = updated.copyWith(imageUrl: imageUrl);
      }

      await _productRepository.updateProduct(updated);
      _products =
          _products.map((p) => p.id == updated.id ? updated : p).toList();
      await _adminRepository.createAdminLog(
        AdminLog(
          id: '',
          adminId: adminId,
          action: 'update_product',
          targetId: updated.id,
          details: 'Produit modifie: ${updated.name}',
          createdAt: DateTime.now(),
        ),
      );
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de mettre a jour le produit.');
    }
  }

  Future<void> deleteProduct({
    required String productId,
    required String adminId,
    String? productName,
  }) async {
    _setState(ViewStatus.loading);
    try {
      await _productRepository.deleteProduct(productId);
      _products = _products.where((p) => p.id != productId).toList();
      await _adminRepository.createAdminLog(
        AdminLog(
          id: '',
          adminId: adminId,
          action: 'delete_product',
          targetId: productId,
          details: 'Produit supprime: ${productName ?? productId}',
          createdAt: DateTime.now(),
        ),
      );
      _setState(_products.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de supprimer le produit.');
    }
  }

  void _setState(ViewStatus status) {
    _status = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ViewStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
