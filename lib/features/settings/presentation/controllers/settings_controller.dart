import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/repositories/app_settings_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final AppSettingsRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  AppSettings? _settings;
  AppSettings? get settings => _settings;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    _setState(ViewStatus.loading);
    try {
      _settings = await _repository.getAppSettings();
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger la configuration.');
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    _setSaving(true);
    try {
      await _repository.updateAppSettings(settings);
      _settings = settings;
      _setState(ViewStatus.success);
    } catch (_) {
      _setError('Impossible de mettre à jour la configuration.');
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool value) {
    _isSaving = value;
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
