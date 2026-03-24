import 'daily_nutrition_summary.dart';

class WeeklyNutritionSummary {
  WeeklyNutritionSummary({
    required this.days,
  });

  final List<DailyNutritionSummary> days;

  double get totalCalories =>
      days.fold(0, (sum, d) => sum + d.totalCalories);

  double get totalProteins =>
      days.fold(0, (sum, d) => sum + d.totalProteins);

  double get totalCarbs =>
      days.fold(0, (sum, d) => sum + d.totalCarbs);

  double get totalFats =>
      days.fold(0, (sum, d) => sum + d.totalFats);
}

