import 'package:cloud_firestore/cloud_firestore.dart';

class Scan {
  Scan({
    required this.id,
    required this.userId,
    required this.productId,
    required this.barcode,
    required this.qrCodeValue,
    required this.productName,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.scannedAt,
    required this.sourceType,
  });

  final String id;
  final String userId;
  final String productId;
  final String? barcode;
  final String? qrCodeValue;
  final String productName;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final DateTime scannedAt;
  final String sourceType;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'barcode': barcode,
      'qrCodeValue': qrCodeValue,
      'productName': productName,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'sourceType': sourceType,
    };
  }

  factory Scan.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final scannedAtTs = data['scannedAt'] as Timestamp?;

    return Scan(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      barcode: data['barcode'] as String?,
      qrCodeValue: data['qrCodeValue'] as String?,
      productName: data['productName'] as String? ?? '',
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      proteins: (data['proteins'] as num?)?.toDouble() ?? 0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0,
      fats: (data['fats'] as num?)?.toDouble() ?? 0,
      scannedAt: scannedAtTs?.toDate() ?? DateTime.now(),
      sourceType: data['sourceType'] as String? ?? 'unknown',
    );
  }
}

