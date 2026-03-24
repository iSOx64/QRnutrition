class DailyNutritionSummary {
  DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    required this.totalFats,
    required this.goalCalories,
  });

  final DateTime date;
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;
  final double goalCalories;

  double get caloriesProgress =>
      goalCalories <= 0 ? 0 : (totalCalories / goalCalories).clamp(0, 2);
}

