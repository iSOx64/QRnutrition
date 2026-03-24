import 'package:flutter/material.dart';

import '../../../products/data/models/product_model.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onOpenDetails,
                  child: const Text('Voir la fiche'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
