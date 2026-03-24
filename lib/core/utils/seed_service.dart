import '../../features/products/data/repositories/product_repository.dart';
import 'demo_data.dart';

class SeedService {
  SeedService(this._productRepository);

  final ProductRepository _productRepository;

  Future<void> seedProducts(String adminId) async {
    final products = demoProducts(adminId);
    for (final product in products) {
      await _productRepository.createProduct(product);
    }
  }
}
