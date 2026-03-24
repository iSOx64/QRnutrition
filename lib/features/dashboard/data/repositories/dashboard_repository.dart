import '../../../../core/errors/app_failure.dart';
import '../../../history/data/models/scan_history_item_model.dart';
import '../models/daily_nutrition_summary.dart';
import '../models/weekly_nutrition_summary.dart';
import '../services/dashboard_service.dart';

class DashboardRepository {
  DashboardRepository(this._service);

  final DashboardService _service;

  DailyNutritionSummary calculateDailyNutritionTotals({
    required DateTime date,
    required List<ScanHistoryItem> scans,
    required int goalCalories,
  }) {
    try {
      return _service.calculateDailyNutritionTotals(
        date: date,
        scans: scans,
        goalCalories: goalCalories,
      );
    } catch (_) {
      throw AppFailure('calc', 'Impossible de calculer les totaux.');
    }
  }

  WeeklyNutritionSummary calculateWeeklyNutritionTotals({
    required DateTime weekStart,
    required List<ScanHistoryItem> scans,
    required int goalCalories,
  }) {
    try {
      return _service.calculateWeeklyNutritionTotals(
        weekStart: weekStart,
        scans: scans,
        goalCalories: goalCalories,
      );
    } catch (_) {
      throw AppFailure('calc', 'Impossible de calculer la semaine.');
    }
  }

  double compareToGoal(DailyNutritionSummary summary) {
    return _service.compareToGoal(summary);
  }
}
