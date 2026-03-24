import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../../admin/data/models/admin_stats_model.dart';
import '../../../admin/data/repositories/admin_repository.dart';

class SuperAdminController extends ChangeNotifier {
  SuperAdminController(this._adminRepository);

  final AdminRepository _adminRepository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  AdminStats? _stats;
  AdminStats? get stats => _stats;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadSummary() async {
    _setState(ViewStatus.loading);
    try {
      _stats = await _adminRepository.getAdminStats();
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger le résumé.');
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
