import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/qr_utils.dart';
import '../../../../core/widgets/qr_preview.dart';
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
                final qrValue = _product.qrCodeValue ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'QR interne',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (qrValue.isNotEmpty) ...[
                    QrPreview(value: qrValue),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: qrValue));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('QR copie'),
                              ),
                            );
                          },
                          child: const Text('Copier'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () async {
                            final newValue = generateQrValue(_product.id);
                            final updated =
                                _product.copyWith(qrCodeValue: newValue);
                            await controller.updateProduct(
                              product: updated,
                              adminId: adminId,
                            );
                            if (mounted) {
                              setState(() => _product = updated);
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('QR regenere'),
                              ),
                            );
                          },
                          child: const Text('Regenerer'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () =>
                              _exportQrImage(context, qrValue, _product.name),
                          child: const Text('Exporter'),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text('Aucun QR.'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () async {
                        final newValue = generateQrValue(_product.id);
                        final updated =
                            _product.copyWith(qrCodeValue: newValue);
                        await controller.updateProduct(
                          product: updated,
                          adminId: adminId,
                        );
                        if (mounted) {
                          setState(() => _product = updated);
                        }
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('QR genere'),
                          ),
                        );
                      },
                      child: const Text('Generer'),
                    ),
                  ],
                  const SizedBox(height: 24),
                    ProductForm(
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _exportQrImage(
  BuildContext context,
  String value,
  String productName,
) async {
  try {
    final bytes = await generateQrPngBytes(value, size: 600);
    final tempDir = await getTemporaryDirectory();
    final safeName = productName
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${tempDir.path}/qr_$safeName.png');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'QR produit: $productName',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR exporte.')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur export QR.')),
      );
    }
  }
}
