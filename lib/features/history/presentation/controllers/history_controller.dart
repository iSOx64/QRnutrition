import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../data/models/scan_history_item_model.dart';
import '../../data/models/scan_model.dart';
import '../../data/repositories/history_repository.dart';

class HistoryController extends ChangeNotifier {
  HistoryController(this._repository);

  final HistoryRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  List<ScanHistoryItem> _history = [];
  List<ScanHistoryItem> get history => _history;

  List<Scan> _globalScans = [];
  List<Scan> get globalScans => _globalScans;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserHistory(String userId) async {
    _setState(ViewStatus.loading);
    try {
      final list = await _repository.getUserScanHistory(userId: userId);
      _history = list;
      _setState(list.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger l’historique.');
    }
  }

  Future<void> loadGlobalScans() async {
    _setState(ViewStatus.loading);
    try {
      final list = await _repository.getGlobalScans();
      _globalScans = list;
      _setState(list.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les scans.');
    }
  }

  Future<void> deleteHistoryItem({
    required String userId,
    required String scanId,
    bool deleteGlobal = false,
  }) async {
    _setState(ViewStatus.loading);
    try {
      await _repository.deleteHistoryItem(
        userId: userId,
        scanId: scanId,
        deleteGlobal: deleteGlobal,
      );
      _history = _history.where((item) => item.id != scanId).toList();
      _setState(_history.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de supprimer l’élément.');
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
