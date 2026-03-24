import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_failure.dart';
import '../models/app_settings_model.dart';
import '../services/app_settings_service.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._service);

  final AppSettingsService _service;

  Future<AppSettings> getAppSettings() async {
    try {
      return await _service.getAppSettings();
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de charger la configuration.');
    }
  }

  Future<void> updateAppSettings(AppSettings settings) async {
    try {
      await _service.updateAppSettings(settings);
    } on FirebaseException catch (e) {
      throw AppFailure(e.code, 'Impossible de mettre à jour la configuration.');
    }
  }
}
