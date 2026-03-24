import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/features/history/data/models/scan_history_item_model.dart';
import 'package:first_app/features/history/data/models/scan_model.dart';
import 'package:first_app/features/history/data/repositories/history_repository.dart';
import 'package:first_app/features/history/presentation/controllers/history_controller.dart';

class FakeHistoryRepository implements HistoryRepository {
  final List<ScanHistoryItem> _items;

  FakeHistoryRepository(this._items);

  @override
  Future<List<ScanHistoryItem>> getUserScanHistory({
    required String userId,
    int limit = 100,
  }) async {
    return _items;
  }

  @override
  Future<List<Scan>> getGlobalScans({int limit = 200}) async {
    return [];
  }

  @override
  Future<void> deleteHistoryItem({
    required String userId,
    required String scanId,
    bool deleteGlobal = false,
  }) async {}
}

void main() {
  test('HistoryController loads user history', () async {
    final items = [
      ScanHistoryItem(
        id: 's1',
        productId: 'p1',
        barcode: '123',
        qrCodeValue: null,
        productName: 'Item',
        calories: 100,
        proteins: 5,
        carbs: 10,
        fats: 2,
        scannedAt: DateTime.now(),
        sourceType: 'barcode',
      ),
    ];
    final controller = HistoryController(FakeHistoryRepository(items));

    await controller.loadUserHistory('u1');

    expect(controller.history.length, 1);
  });
}
