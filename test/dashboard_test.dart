import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/features/dashboard/data/services/dashboard_service.dart';
import 'package:first_app/features/history/data/models/scan_history_item_model.dart';

void main() {
  test('dashboard daily summary totals are correct', () {
    final service = DashboardService();
    final date = DateTime(2026, 3, 13);
    final scans = [
      ScanHistoryItem(
        id: '1',
        productId: 'p1',
        barcode: '123',
        qrCodeValue: null,
        productName: 'Item 1',
        calories: 100,
        proteins: 5,
        carbs: 10,
        fats: 2,
        scannedAt: date,
        sourceType: 'barcode',
      ),
      ScanHistoryItem(
        id: '2',
        productId: 'p2',
        barcode: '456',
        qrCodeValue: null,
        productName: 'Item 2',
        calories: 200,
        proteins: 10,
        carbs: 20,
        fats: 4,
        scannedAt: date,
        sourceType: 'barcode',
      ),
    ];

    final summary = service.calculateDailyNutritionTotals(
      date: date,
      scans: scans,
      goalCalories: 2000,
    );

    expect(summary.totalCalories, 300);
    expect(summary.totalProteins, 15);
    expect(summary.totalCarbs, 30);
    expect(summary.totalFats, 6);
  });
}
