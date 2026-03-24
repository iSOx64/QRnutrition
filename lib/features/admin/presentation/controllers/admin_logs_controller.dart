import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../data/models/admin_log_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminLogsController extends ChangeNotifier {
  AdminLogsController(this._repository);

  final AdminRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  List<AdminLog> _logs = [];
  List<AdminLog> get logs => _logs;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadAdminLogs({String? action}) async {
    _setState(ViewStatus.loading);
    try {
      final list = await _repository.getAdminLogs(action: action);
      _logs = list;
      _setState(list.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les logs.');
    }
  }

  Future<void> loadSystemLogs() async {
    _setState(ViewStatus.loading);
    try {
      final list = await _repository.getSystemLogs();
      _logs = list;
      _setState(list.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les logs.');
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
