import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../../admin/data/models/admin_log_model.dart';
import '../../../admin/data/repositories/admin_repository.dart';

class SystemLogsController extends ChangeNotifier {
  SystemLogsController(this._repository);

  final AdminRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  List<AdminLog> _logs = [];
  List<AdminLog> get logs => _logs;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadSystemLogs() async {
    _setState(ViewStatus.loading);
    try {
      _logs = await _repository.getSystemLogs();
      _setState(_logs.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger les logs système.');
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
