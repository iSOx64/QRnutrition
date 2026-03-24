import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/presentation/widgets/product_form.dart';
import '../../data/repositories/admin_repository.dart';
import '../controllers/admin_products_controller.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final adminId = auth.state.user?.uid;

    if (adminId == null) {
      return const Scaffold(body: LoadingState());
    }

    return ChangeNotifierProvider(
      create: (context) => AdminProductsController(
        context.read<ProductRepository>(),
        context.read<AdminRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajouter un produit')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<AdminProductsController>(
            builder: (context, controller, _) {
              return ProductForm(
                showQrCodeField: false,
                onSubmit: (data) async {
                  final now = DateTime.now();
                  final product = Product(
                    id: '',
                    name: data.name,
                    brand: data.brand,
                    barcode: data.barcode,
                    qrCodeValue: data.qrCodeValue,
                    category: data.category,
                    calories: data.calories,
                    proteins: data.proteins,
                    carbs: data.carbs,
                    fats: data.fats,
                    ingredients: data.ingredients,
                    allergens: data.allergens,
                    extraNutrients: data.extraNutrients
                        .map((e) => NutrientEntry(
                              label: e.label,
                              value: double.tryParse(e.value) ?? 0,
                              unit: e.unit,
                            ))
                        .toList(),
                    imageUrl: data.imageUrl,
                    isActive: data.isActive,
                    createdAt: now,
                    updatedAt: now,
                    createdBy: adminId,
                  );
                  await controller.createProduct(
                    product: product,
                    adminId: adminId,
                    imageFile: data.imageFile,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
