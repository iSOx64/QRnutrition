import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';

class NutritionTable extends StatelessWidget {
  const NutritionTable({
    super.key,
    required this.nutrients,
    this.maxRows = 20,
    this.showTitle = true,
  });

  final List<NutrientEntry> nutrients;
  final int maxRows;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final rows = nutrients.take(maxRows).toList(growable: false);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Text(
            'Tableau nutritionnel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (showTitle) const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith(
              (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            columns: const [
              DataColumn(label: Text('Nutriment')),
              DataColumn(label: Text('Quantité')),
            ],
            rows: rows
                .map(
                  (e) => DataRow(
                    cells: [
                      DataCell(Text(e.label)),
                      DataCell(Text('${e.value.toStringAsFixed(1)} ${e.unit}')),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

