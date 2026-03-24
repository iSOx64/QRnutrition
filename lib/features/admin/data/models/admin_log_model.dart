import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLog {
  AdminLog({
    required this.id,
    required this.adminId,
    required this.action,
    required this.targetId,
    required this.details,
    required this.createdAt,
  });

  final String id;
  final String adminId;
  final String action;
  final String targetId;
  final String details;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'action': action,
      'targetId': targetId,
      'details': details,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AdminLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtTs = data['createdAt'] as Timestamp?;

    return AdminLog(
      id: doc.id,
      adminId: data['adminId'] as String? ?? '',
      action: data['action'] as String? ?? '',
      targetId: data['targetId'] as String? ?? '',
      details: data['details'] as String? ?? '',
      createdAt: createdAtTs?.toDate() ?? DateTime.now(),
    );
  }
}

