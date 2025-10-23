import 'package:injectable/injectable.dart';
import '../models/product.dart';

@singleton
class ProductRepository {
  // final ApiClient _apiClient;  // Uncomment khi cần call API
  
  // ProductRepository(this._apiClient);
  ProductRepository();

  /// Lấy danh sách products
  Future<List<Product>> getProducts() async {
    try {
      // Mock data - thay bằng API thật
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        Product(
          id: '1',
          name: 'iPhone 15 Pro',
          description: 'Flagship phone từ Apple',
          price: 29990000,
          imageUrl: null,
          stock: 10,
        ),
        Product(
          id: '2',
          name: 'MacBook Pro M3',
          description: 'Laptop hiệu năng cao',
          price: 45990000,
          imageUrl: null,
          stock: 5,
        ),
        Product(
          id: '3',
          name: 'AirPods Pro 2',
          description: 'Tai nghe không dây',
          price: 6990000,
          imageUrl: null,
          stock: 20,
        ),
      ];
    } catch (e) {
      throw Exception('Lấy danh sách sản phẩm thất bại: $e');
    }
  }

  /// Lấy chi tiết product
  Future<Product> getProductById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final products = await getProducts();
      return products.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Không tìm thấy sản phẩm'),
      );
    } catch (e) {
      throw Exception('Lấy chi tiết sản phẩm thất bại: $e');
    }
  }

  /// Tìm kiếm products
  Future<List<Product>> searchProducts(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final products = await getProducts();
      return products.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        p.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Tìm kiếm thất bại: $e');
    }
  }
}
