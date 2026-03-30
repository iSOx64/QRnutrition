import 'package:flutter/material.dart';

import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/widgets/nutrition_table.dart';

class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({
    super.key,
    required this.product,
    required this.onOpenDetails,
  });

  final Product product;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final hasNutrition = product.calories > 0 ||
        product.proteins > 0 ||
        product.carbs > 0 ||
        product.fats > 0 ||
        product.extraNutrients.isNotEmpty;

    final nutritionRows = <NutrientEntry>[
      NutrientEntry(
        label: 'Calories',
        value: product.calories,
        unit: 'kcal',
      ),
      NutrientEntry(
        label: 'Protéines',
        value: product.proteins,
        unit: 'g',
      ),
      NutrientEntry(
        label: 'Glucides',
        value: product.carbs,
        unit: 'g',
      ),
      NutrientEntry(
        label: 'Lipides',
        value: product.fats,
        unit: 'g',
      ),
      ...product.extraNutrients,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.fastfood, size: 64),
              ),
            const SizedBox(height: 12),
            Text(
              'Produit trouvé',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('${product.brand} • ${product.category}'),
            if (product.nutriScore != null ||
                product.novaGroup != null ||
                product.ecoScore != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (product.nutriScore != null)
                    Chip(
                      label: Text('Nutri-Score: ${product.nutriScore}'),
                    ),
                  if (product.novaGroup != null)
                    Chip(
                      label: Text('NOVA: ${product.novaGroup}'),
                    ),
                  if (product.ecoScore != null)
                    Chip(
                      label: Text('Eco: ${product.ecoScore}'),
                    ),
                ],
              ),
            ],
            if (hasNutrition) ...[
              const SizedBox(height: 12),
              NutritionTable(
                nutrients: nutritionRows,
                maxRows: 10,
                showTitle: false,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onOpenDetails,
              child: const Text('Voir la fiche'),
            ),
          ],
        ),
      ),
    );
  }
}
