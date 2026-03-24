import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_settings_model.dart';

class AppSettingsService {
  AppSettingsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _firestore.collection('settings').doc('app_config');

  Future<AppSettings> getAppSettings() async {
    final snapshot = await _settingsDoc.get();
    if (!snapshot.exists) {
      final defaultSettings = AppSettings(
        notificationsEnabled: true,
        supportedCategories: const <String>[],
        maxDailyCaloriesDefault: 2000,
        updatedAt: DateTime.now(),
      );
      await _settingsDoc.set(defaultSettings.toMap());
      return defaultSettings;
    }
    return AppSettings.fromDoc(snapshot);
  }

  Future<void> updateAppSettings(AppSettings settings) async {
    final updated = settings.copyWith(updatedAt: DateTime.now());
    await _settingsDoc.set(updated.toMap(), SetOptions(merge: true));
  }
}
