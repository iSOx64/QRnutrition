import 'package:flutter/material.dart';

import '../../../../core/utils/role_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/models/scan_result_model.dart';
import '../../data/repositories/scanner_repository.dart';

class ScannerController extends ChangeNotifier {
  ScannerController(this._repository);

  final ScannerRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  ScanResultModel? _lastResult;
  ScanResultModel? get lastResult => _lastResult;

  Product? _product;
  Product? get product => _product;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _canAddProduct = false;
  bool get canAddProduct => _canAddProduct;

  Future<void> processScannedCode({
    required String rawValue,
    required String userId,
    required AppUser? currentUser,
    ScanSourceType? hint,
  }) async {
    _setState(ViewStatus.loading);
    _canAddProduct = isAdmin(currentUser);
    try {
      final result = _repository.parseRawValue(rawValue, hint: hint);
      _lastResult = result;
      final found = await _repository.findProduct(result);
      if (found == null) {
        _product = null;
        _setState(ViewStatus.empty);
        return;
      }
      _product = found;
      await _repository.saveScan(
        userId: userId,
        product: found,
        scanResult: result,
      );
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Erreur lors du scan.');
    }
  }

  void reset() {
    _status = ViewStatus.initial;
    _lastResult = null;
    _product = null;
    _errorMessage = null;
    _canAddProduct = false;
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
