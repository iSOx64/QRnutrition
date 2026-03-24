import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../data/models/admin_stats_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminStatsController extends ChangeNotifier {
  AdminStatsController(this._repository);

  final AdminRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  AdminStats? _stats;
  AdminStats? get stats => _stats;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadStats() async {
    _setState(ViewStatus.loading);
    try {
      final stats = await _repository.getAdminStats();
      _stats = stats;
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les statistiques.');
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
