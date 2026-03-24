import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../data/repositories/product_repository.dart';
import '../controllers/product_search_controller.dart';
import '../widgets/product_result_tile.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ProductSearchController(context.read<ProductRepository>())
            ..loadActiveProducts(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Recherche')),
        body: Consumer<ProductSearchController>(
          builder: (context, controller, _) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchBarWidget(
                          controller: _controller,
                          hintText: 'Rechercher un produit',
                          onChanged: controller.searchByName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildResults(context, controller),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    ProductSearchController controller,
  ) {
    switch (controller.status) {
      case ViewStatus.loading:
        return const LoadingState(message: 'Recherche...');
      case ViewStatus.empty:
        return const EmptyState(
          title: 'Aucun produit',
          message: 'Aucun resultat pour cette recherche.',
        );
      case ViewStatus.error:
        return EmptyState(
          title: 'Erreur',
          message: controller.errorMessage ?? 'Erreur inconnue.',
        );
      case ViewStatus.success:
        return ListView.separated(
          itemCount: controller.results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final product = controller.results[index];
            return ProductResultTile(
              product: product,
              onTap: () => context.push(
                AppRoute.productDetails.path,
                extra: product,
              ),
            );
          },
        );
      case ViewStatus.initial:
      default:
        return const EmptyState(
          title: 'Aucun produit',
          message: 'Aucun produit actif disponible.',
        );
    }
  }
}
