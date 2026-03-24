import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/qr_preview.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../scanner/data/models/scan_result_model.dart';
import '../../../scanner/data/repositories/scanner_repository.dart';
import '../../data/models/product_model.dart';

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
            if (product.extraNutrients.isNotEmpty) ...[
              const SizedBox(height: 12),
              InfoCard(
                title: 'Nutriments supplementaires',
                subtitle: product.extraNutrients
                    .map((e) => '${e.label}: ${e.value} ${e.unit}')
                    .join('\n'),
                icon: Icons.science,
              ),
            ],
            const SizedBox(height: 12),
            InfoCard(
              title: 'Barcode',
              subtitle: product.barcode ?? 'Non disponible',
              icon: Icons.qr_code,
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'QR interne',
              subtitle: product.qrCodeValue ?? 'Non disponible',
              icon: Icons.qr_code_2,
            ),
            if (product.qrCodeValue != null &&
                product.qrCodeValue!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'QR du produit',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              QrPreview(value: product.qrCodeValue!, size: 180),
            ],
            const SizedBox(height: 24),
            if (user != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final repository = context.read<ScannerRepository>();
                    final rawValue = product.barcode ??
                        product.qrCodeValue ??
                        product.id;
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
