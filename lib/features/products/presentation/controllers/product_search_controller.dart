import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductSearchController extends ChangeNotifier {
  ProductSearchController(this._repository);

  final ProductRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  List<Product> _all = [];
  List<Product> _results = [];
  List<Product> get results => _results;

  String _query = '';
  String get query => _query;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadActiveProducts() async {
    _setState(ViewStatus.loading);
    try {
      final list = await _repository.getAllProducts();
      final active = list.where((p) => p.isActive).toList();
      _all = active;
      _results = active;
      _setState(active.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les produits.');
    }
  }

  Future<void> searchByName(String query) async {
    _query = query;
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      _results = _all;
      _setState(_results.isEmpty ? ViewStatus.empty : ViewStatus.success);
      return;
    }
    final filtered = _all.where((p) {
      final name = p.name.toLowerCase();
      final brand = p.brand.toLowerCase();
      return name.contains(normalized) || brand.contains(normalized);
    }).toList();
    _results = filtered;
    _setState(filtered.isEmpty ? ViewStatus.empty : ViewStatus.success);
  }

  Future<void> searchByCode(String code) async {
    if (code.trim().isEmpty) return;
    _setState(ViewStatus.loading);
    try {
      Product? product = await _repository.getProductByBarcode(code);
      product ??= await _repository.getProductByQrValue(code);
      final list = product == null ? <Product>[] : [product];
      _results = list.where((p) => p.isActive).toList();
      _setState(_results.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Erreur lors de la recherche.');
    }
  }

  void clear() {
    _query = '';
    _results = _all;
    _status = _results.isEmpty ? ViewStatus.empty : ViewStatus.success;
    _errorMessage = null;
    notifyListeners();
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
