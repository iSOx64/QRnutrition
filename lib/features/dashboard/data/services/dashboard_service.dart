import '../../../history/data/models/scan_history_item_model.dart';
import '../models/daily_nutrition_summary.dart';
import '../models/weekly_nutrition_summary.dart';

class DashboardService {
  DailyNutritionSummary calculateDailyNutritionTotals({
    required DateTime date,
    required List<ScanHistoryItem> scans,
    required int goalCalories,
  }) {
    final dayScans = scans.where((s) => _isSameDay(s.scannedAt, date)).toList();
    return _buildDailySummary(date, dayScans, goalCalories);
  }

  WeeklyNutritionSummary calculateWeeklyNutritionTotals({
    required DateTime weekStart,
    required List<ScanHistoryItem> scans,
    required int goalCalories,
  }) {
    final days = List.generate(7, (index) {
      final date = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + index,
      );
      final dayScans = scans.where((s) => _isSameDay(s.scannedAt, date)).toList();
      return _buildDailySummary(date, dayScans, goalCalories);
    });
    return WeeklyNutritionSummary(days: days);
  }

  double compareToGoal(DailyNutritionSummary summary) {
    return summary.totalCalories - summary.goalCalories;
  }

  DailyNutritionSummary _buildDailySummary(
    DateTime date,
    List<ScanHistoryItem> scans,
    int goalCalories,
  ) {
    final totalCalories =
        scans.fold<double>(0, (sum, s) => sum + s.calories);
    final totalProteins =
        scans.fold<double>(0, (sum, s) => sum + s.proteins);
    final totalCarbs = scans.fold<double>(0, (sum, s) => sum + s.carbs);
    final totalFats = scans.fold<double>(0, (sum, s) => sum + s.fats);
    return DailyNutritionSummary(
      date: date,
      totalCalories: totalCalories,
      totalProteins: totalProteins,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      goalCalories: goalCalories.toDouble(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
