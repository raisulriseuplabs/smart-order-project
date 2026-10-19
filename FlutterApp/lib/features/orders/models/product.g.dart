// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  sku: json['sku'] as String,
  supplier: json['supplier'] as String,
  hasPromo: json['hasPromo'] as bool? ?? false,
  inStock: json['inStock'] as bool? ?? true,
  description: json['description'] as String?,
  category: json['category'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'sku': instance.sku,
  'supplier': instance.supplier,
  'hasPromo': instance.hasPromo,
  'inStock': instance.inStock,
  'description': instance.description,
  'category': instance.category,
};

_ProductPurchaseHistory _$ProductPurchaseHistoryFromJson(
  Map<String, dynamic> json,
) => _ProductPurchaseHistory(
  month: json['month'] as String,
  year: json['year'] as String,
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$ProductPurchaseHistoryToJson(
  _ProductPurchaseHistory instance,
) => <String, dynamic>{
  'month': instance.month,
  'year': instance.year,
  'quantity': instance.quantity,
};
