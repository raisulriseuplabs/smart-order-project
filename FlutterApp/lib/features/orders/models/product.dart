import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    required String sku,
    required String supplier,
    @Default(false) bool hasPromo,
    @Default(true) bool inStock,
    String? description,
    String? category,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
abstract class ProductPurchaseHistory with _$ProductPurchaseHistory {
  const factory ProductPurchaseHistory({
    required String month,
    required String year,
    required int quantity,
  }) = _ProductPurchaseHistory;

  factory ProductPurchaseHistory.fromJson(Map<String, dynamic> json) =>
      _$ProductPurchaseHistoryFromJson(json);
}
