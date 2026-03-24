import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../data/models/admin_log_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminController extends ChangeNotifier {
  AdminController(this._repository);

  final AdminRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> logAction(AdminLog log) async {
    _setState(ViewStatus.loading);
    try {
      await _repository.createAdminLog(log);
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible d’enregistrer le log.');
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
