import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../core/utils/view_state.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../../openfoodfacts/data/services/openfoodfacts_service.dart';

class ProductSearchController extends ChangeNotifier {
  ProductSearchController(
    this._repository,
    this._openFoodFactsService,
  );

  final ProductRepository _repository;
  final OpenFoodFactsService _openFoodFactsService;

  Timer? _debounce;

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
      // Important: même si Firestore est vide, on doit pouvoir chercher
      // via OpenFoodFacts. Donc on reste en "success".
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les produits.');
    }
  }

  Future<void> searchByName(String query) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      _query = query;
      final normalized = query.trim();
      if (normalized.isEmpty) {
        _results = _all;
        _setState(_results.isEmpty ? ViewStatus.empty : ViewStatus.success);
        return;
      }

      // Exemple: "1 234 567 890" ou "1-234-567-890" => chiffres uniquement.
      final asDigits = normalized.replaceAll(RegExp(r'\D'), '');
      final looksLikeBarcode =
          RegExp(r'^\d{8,14}$').hasMatch(asDigits);

      if (looksLikeBarcode) {
        await _searchByBarcode(asDigits);
        return;
      }

      await _searchByNameText(normalized);
    });
  }

  Future<void> _searchByBarcode(String code) async {
    _setState(ViewStatus.loading);

    try {
      final local = await _repository.getProductByBarcode(code);
      if (local != null && local.isActive) {
        _results = [local];
        _setState(ViewStatus.success);
        return;
      }
    } catch (_) {
      // Fall back OpenFoodFacts.
    }

    try {
      final remote = await _openFoodFactsService.getProductByBarcode(code);
      _results = remote == null ? <Product>[] : [remote];
      _setState(_results.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Erreur lors de la recherche.');
    }
  }

  Future<void> _searchByNameText(String text) async {
    _setState(ViewStatus.loading);

    final normalized = text.toLowerCase();

    // 1) Firestore local (si tu as encore quelques produits actifs)
    if (_all.isNotEmpty) {
      final filtered = _all.where((p) {
        final name = p.name.toLowerCase();
        final brand = p.brand.toLowerCase();
        return name.contains(normalized) || brand.contains(normalized);
      }).toList();

      if (filtered.isNotEmpty) {
        _results = filtered;
        _setState(ViewStatus.success);
        return;
      }
    }

    // 2) OpenFoodFacts fallback
    try {
      final remote = await _openFoodFactsService.searchProductsByQuery(
        text,
        limit: 10,
      );
      _results = remote;
      _setState(remote.isEmpty ? ViewStatus.empty : ViewStatus.success);
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
