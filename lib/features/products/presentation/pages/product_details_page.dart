import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/info_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../scanner/data/models/scan_result_model.dart';
import '../../../scanner/data/repositories/scanner_repository.dart';
import '../../data/models/product_model.dart';
import '../widgets/nutrition_table.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.state.user;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Fiche produit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.fastfood, size: 64),
              ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text('${product.brand} • ${product.category}'),
            const SizedBox(height: 16),
            if (product.nutriScore != null ||
                product.novaGroup != null ||
                product.ecoScore != null) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (product.nutriScore != null)
                    InfoCard(
                      title: 'Nutri-Score',
                      subtitle: product.nutriScore!,
                      icon: Icons.health_and_safety,
                    ),
                  if (product.novaGroup != null)
                    InfoCard(
                      title: 'Groupe NOVA',
                      subtitle: product.novaGroup!.toString(),
                      icon: Icons.category,
                    ),
                  if (product.ecoScore != null)
                    InfoCard(
                      title: 'Eco-score',
                      subtitle: product.ecoScore!,
                      icon: Icons.eco,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                InfoCard(
                  title: 'Calories',
                  subtitle: '${product.calories.toStringAsFixed(0)} kcal',
                  icon: Icons.local_fire_department,
                ),
                InfoCard(
                  title: 'Proteines',
                  subtitle: '${product.proteins.toStringAsFixed(1)} g',
                  icon: Icons.fitness_center,
                ),
                InfoCard(
                  title: 'Glucides',
                  subtitle: '${product.carbs.toStringAsFixed(1)} g',
                  icon: Icons.bubble_chart,
                ),
                InfoCard(
                  title: 'Lipides',
                  subtitle: '${product.fats.toStringAsFixed(1)} g',
                  icon: Icons.oil_barrel,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (product.quantity != null && product.quantity!.isNotEmpty) ...[
              InfoCard(
                title: 'Quantité',
                subtitle: product.quantity!,
                icon: Icons.scale,
              ),
              const SizedBox(height: 12),
            ],
            if (product.countries != null && product.countries!.isNotEmpty) ...[
              InfoCard(
                title: 'Pays',
                subtitle: product.countries!,
                icon: Icons.public,
              ),
              const SizedBox(height: 12),
            ],
            if (product.labels != null && product.labels!.isNotEmpty) ...[
              InfoCard(
                title: 'Labels',
                subtitle: product.labels!,
                icon: Icons.loyalty,
              ),
              const SizedBox(height: 12),
            ],
            if (product.packaging != null && product.packaging!.isNotEmpty) ...[
              InfoCard(
                title: 'Emballage',
                subtitle: product.packaging!,
                icon: Icons.all_inbox,
              ),
              const SizedBox(height: 12),
            ],
            InfoCard(
              title: 'Ingredients',
              subtitle: product.ingredients.isEmpty
                  ? 'Non renseigne'
                  : product.ingredients,
              icon: Icons.list_alt,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Allergenes',
              subtitle:
                  product.allergens.isEmpty ? 'Aucun' : product.allergens,
              icon: Icons.warning_amber,
            ),
            if (hasNutrition) ...[
              const SizedBox(height: 12),
              NutritionTable(nutrients: nutritionRows),
            ],
            const SizedBox(height: 12),
            InfoCard(
              title: 'Code-barres',
              subtitle: product.barcode ?? 'Non disponible',
              icon: Icons.document_scanner,
            ),
            const SizedBox(height: 24),
            if (user != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final repository = context.read<ScannerRepository>();
                    final rawValue = product.barcode ?? product.id;
                    final scanResult = ScanResultModel(
                      rawValue: rawValue,
                      sourceType: ScanSourceType.manual,
                    );
                    await repository.saveScan(
                      userId: user.uid,
                      product: product,
                      scanResult: scanResult,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Produit ajoute au dashboard."),
                      ),
                    );
                  },
                  child: const Text("J'ai mange ce produit"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
