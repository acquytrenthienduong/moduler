import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

part 'product_provider.g.dart';

// Repository Provider
@riverpod
ProductRepository productRepository(Ref ref) {
  return GetIt.instance<ProductRepository>();
}

// Product List Provider
@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<Product>> build() async {
    // Load initial data
    return _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final repository = ref.read(productRepositoryProvider);
    return await repository.getProducts();
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProducts());
  }

  /// Search products
  Future<void> search(String query) async {
    if (query.isEmpty) {
      await refresh();
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      return await repository.searchProducts(query);
    });
  }
}

// Product Detail Provider (by ID)
@riverpod
Future<Product> productDetail(Ref ref, String productId) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getProductById(productId);
}
