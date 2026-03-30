import 'package:flutter/material.dart';

import '../../../../core/utils/view_state.dart';
import '../../../history/data/models/scan_history_item_model.dart';
import '../../../history/data/repositories/history_repository.dart';
import '../../data/models/daily_nutrition_summary.dart';
import '../../data/models/weekly_nutrition_summary.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._historyRepository, this._dashboardRepository);

  final HistoryRepository _historyRepository;
  final DashboardRepository _dashboardRepository;

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  DailyNutritionSummary? _dailySummary;
  DailyNutritionSummary? get dailySummary => _dailySummary;

  WeeklyNutritionSummary? _weeklySummary;
  WeeklyNutritionSummary? get weeklySummary => _weeklySummary;

  List<ScanHistoryItem> _history = [];
  List<ScanHistoryItem> get history => _history;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  DateTime _weekStart = DateTime.now();
  DateTime get weekStart => _weekStart;

  String? _userId;
  int? _goalCalories;

  Future<void> loadDaily({
    required String userId,
    required int goalCalories,
    DateTime? date,
  }) async {
    _setState(ViewStatus.loading);
    _selectedDate = date ?? DateTime.now();
    _userId = userId;
    _goalCalories = goalCalories;
    try {
      _history = await _historyRepository.getUserScanHistory(userId: userId);
      _dailySummary = _dashboardRepository.calculateDailyNutritionTotals(
        date: _selectedDate,
        scans: _history,
        goalCalories: goalCalories,
      );
      _setState(_history.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger le dashboard.');
    }
  }

  Future<void> loadWeekly({
    required String userId,
    required int goalCalories,
    DateTime? weekStart,
  }) async {
    _setState(ViewStatus.loading);
    _weekStart = weekStart ?? _startOfWeek(DateTime.now());
    _userId = userId;
    _goalCalories = goalCalories;
    try {
      _history = await _historyRepository.getUserScanHistory(userId: userId);
      _weeklySummary = _dashboardRepository.calculateWeeklyNutritionTotals(
        weekStart: _weekStart,
        scans: _history,
        goalCalories: goalCalories,
      );
      _setState(_history.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de charger le dashboard.');
    }
  }

  Future<void> deleteMeal({
    required String scanId,
  }) async {
    final userId = _userId;
    final goal = _goalCalories;
    if (userId == null || goal == null) return;

    _setState(ViewStatus.loading);
    try {
      await _historyRepository.deleteHistoryItem(
        userId: userId,
        scanId: scanId,
        deleteGlobal: false,
      );

      _history = _history.where((h) => h.id != scanId).toList();
      _dailySummary = _dashboardRepository.calculateDailyNutritionTotals(
        date: _selectedDate,
        scans: _history,
        goalCalories: goal,
      );
      _weeklySummary = _dashboardRepository.calculateWeeklyNutritionTotals(
        weekStart: _weekStart,
        scans: _history,
        goalCalories: goal,
      );
      _setState(_history.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de supprimer le repas.');
    }
  }

  Future<void> updateManualMeal({
    required ScanHistoryItem updated,
  }) async {
    final userId = _userId;
    final goal = _goalCalories;
    if (userId == null || goal == null) return;

    _setState(ViewStatus.loading);
    try {
      await _historyRepository.updateHistoryItem(
        userId: userId,
        scanId: updated.id,
        updated: updated,
      );

      _history = _history
          .map((h) => h.id == updated.id ? updated : h)
          .toList();
      _dailySummary = _dashboardRepository.calculateDailyNutritionTotals(
        date: _selectedDate,
        scans: _history,
        goalCalories: goal,
      );
      _weeklySummary = _dashboardRepository.calculateWeeklyNutritionTotals(
        weekStart: _weekStart,
        scans: _history,
        goalCalories: goal,
      );
      _setState(_history.isEmpty ? ViewStatus.empty : ViewStatus.success);
    } catch (_) {
      _setError('Impossible de modifier le repas.');
    }
  }

  double compareToGoal() {
    final summary = _dailySummary;
    if (summary == null) return 0;
    return _dashboardRepository.compareToGoal(summary);
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    final diff = weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
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
