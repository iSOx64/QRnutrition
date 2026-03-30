import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/loading_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/presentation/widgets/product_form.dart';
import '../../data/repositories/admin_repository.dart';
import '../controllers/admin_products_controller.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

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
        appBar: AppBar(
          title: const Text('Modifier produit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final controller =
                    context.read<AdminProductsController>();
                await controller.deleteProduct(
                  productId: _product.id,
                  adminId: adminId,
                  productName: _product.name,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<AdminProductsController>(
            builder: (context, controller, _) {
              return ProductForm(
                initialData: ProductFormData(
                  name: _product.name,
                  brand: _product.brand,
                  barcode: _product.barcode,
                  qrCodeValue: _product.qrCodeValue,
                  category: _product.category,
                  calories: _product.calories,
                  proteins: _product.proteins,
                  carbs: _product.carbs,
                  fats: _product.fats,
                  ingredients: _product.ingredients,
                  allergens: _product.allergens,
                  extraNutrients: _product.extraNutrients
                      .map(
                        (e) => ExtraNutrientInput(
                          label: e.label,
                          value: e.value.toString(),
                          unit: e.unit,
                        ),
                      )
                      .toList(),
                  imageUrl: _product.imageUrl,
                  imageFile: null,
                  removeImage: false,
                  isActive: _product.isActive,
                ),
                showQrCodeField: false,
                onSubmit: (data) async {
                  final updated = _product.copyWith(
                    name: data.name,
                    brand: data.brand,
                    barcode: data.barcode,
                    category: data.category,
                    calories: data.calories,
                    proteins: data.proteins,
                    carbs: data.carbs,
                    fats: data.fats,
                    ingredients: data.ingredients,
                    allergens: data.allergens,
                    extraNutrients: data.extraNutrients
                        .map(
                          (e) => NutrientEntry(
                            label: e.label,
                            value: double.tryParse(e.value) ?? 0,
                            unit: e.unit,
                          ),
                        )
                        .toList(),
                    isActive: data.isActive,
                    updatedAt: DateTime.now(),
                  );
                  await controller.updateProduct(
                    product: updated,
                    adminId: adminId,
                    imageFile: data.imageFile,
                    removeImage: data.removeImage,
                  );
                  if (mounted) {
                    setState(() => _product = updated);
                  }
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
