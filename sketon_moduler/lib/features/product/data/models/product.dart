import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    @Default(0) int stock,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => 
      _$ProductFromJson(json);
}
