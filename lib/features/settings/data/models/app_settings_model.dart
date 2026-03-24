import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  AppSettings({
    required this.notificationsEnabled,
    required this.supportedCategories,
    required this.maxDailyCaloriesDefault,
    required this.updatedAt,
  });

  final bool notificationsEnabled;
  final List<String> supportedCategories;
  final int maxDailyCaloriesDefault;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'supportedCategories': supportedCategories,
      'maxDailyCaloriesDefault': maxDailyCaloriesDefault,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AppSettings.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final updatedAtTs = data['updatedAt'] as Timestamp?;

    return AppSettings(
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      supportedCategories:
          List<String>.from(data['supportedCategories'] ?? const <String>[]),
      maxDailyCaloriesDefault:
          (data['maxDailyCaloriesDefault'] as num?)?.toInt() ?? 2000,
      updatedAt: updatedAtTs?.toDate() ?? DateTime.now(),
    );
  }

  AppSettings copyWith({
    bool? notificationsEnabled,
    List<String>? supportedCategories,
    int? maxDailyCaloriesDefault,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      supportedCategories: supportedCategories ?? this.supportedCategories,
      maxDailyCaloriesDefault:
          maxDailyCaloriesDefault ?? this.maxDailyCaloriesDefault,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

