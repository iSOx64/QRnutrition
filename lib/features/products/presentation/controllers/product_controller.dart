import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductController extends ChangeNotifier {
  ProductController(this._repository);

  final ProductRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  List<Product> _products = [];
  List<Product> get products => _products;

  Product? _selected;
  Product? get selected => _selected;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllProducts() async {
    _setState(ViewStatus.loading);
    try {
      final list = await _repository.getAllProducts();
      _products = list;
      _setState(list.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les produits.');
    }
  }

  Future<void> loadProductById(String productId) async {
    _setState(ViewStatus.loading);
    try {
      final product = await _repository.getProductById(productId);
      if (product == null) {
        _selected = null;
        _setState(ViewStatus.empty);
      } else {
        _selected = product;
        _setState(ViewStatus.success);
      }
    } catch (_) {
      _setError('Produit introuvable.');
    }
  }

  Future<Product?> getByBarcode(String barcode) async {
    try {
      return await _repository.getProductByBarcode(barcode);
    } catch (_) {
      _setError('Produit introuvable.');
      return null;
    }
  }

  Future<Product?> getByQrValue(String qrCodeValue) async {
    try {
      return await _repository.getProductByQrValue(qrCodeValue);
    } catch (_) {
      _setError('Produit introuvable.');
      return null;
    }
  }

  Future<void> createProduct(Product product) async {
    _setState(ViewStatus.loading);
    try {
      final created = await _repository.createProduct(product);
      _products = [created, ..._products];
      _selected = created;
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de créer le produit.');
    }
  }

  Future<void> updateProduct(Product product) async {
    _setState(ViewStatus.loading);
    try {
      await _repository.updateProduct(product);
      _products = _products
          .map((p) => p.id == product.id ? product : p)
          .toList();
      _selected = product;
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de mettre à jour le produit.');
    }
  }

  Future<void> deleteProduct(String productId) async {
    _setState(ViewStatus.loading);
    try {
      await _repository.deleteProduct(productId);
      _products = _products.where((p) => p.id != productId).toList();
      if (_selected?.id == productId) {
        _selected = null;
      }
      _setState(_products.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de supprimer le produit.');
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
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
