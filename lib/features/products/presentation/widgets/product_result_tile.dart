import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';

class ProductResultTile extends StatelessWidget {
  const ProductResultTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.fastfood),
      ),
      title: Text(product.name),
      subtitle: Text('${product.brand} • ${product.category}'),
      trailing: Text('${product.calories.toStringAsFixed(0)} kcal'),
    );
  }
}
