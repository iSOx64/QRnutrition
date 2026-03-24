import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../controllers/admin_products_controller.dart';

class AdminProductsListPage extends StatefulWidget {
  const AdminProductsListPage({super.key});

  @override
  State<AdminProductsListPage> createState() => _AdminProductsListPageState();
}

class _AdminProductsListPageState extends State<AdminProductsListPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminProductsController(
        context.read<ProductRepository>(),
        context.read<AdminRepository>(),
      )..loadProducts(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Produits'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push(AppRoute.addProduct.path),
            ),
          ],
        ),
        body: Consumer<AdminProductsController>(
          builder: (context, controller, _) {
            if (controller.status == ViewStatus.loading) {
              return const LoadingState();
            }

            final list = controller.products
                .where((p) =>
                    p.name.toLowerCase().contains(_query.toLowerCase()))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SearchBarWidget(
                    controller: _searchController,
                    hintText: 'Rechercher un produit',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = list[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push(
                            AppRoute.editProduct.path,
                            extra: product,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final auth = context.read<AuthController>();
                              final adminId = auth.state.user?.uid ?? '';
                              await controller.deleteProduct(
                                productId: product.id,
                                adminId: adminId,
                                productName: product.name,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
