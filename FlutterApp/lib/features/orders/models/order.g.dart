// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderLine _$OrderLineFromJson(Map<String, dynamic> json) => _OrderLine(
  id: json['id'] as String,
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
  freeQuantity: (json['freeQuantity'] as num?)?.toInt() ?? 0,
  price: (json['price'] as num).toDouble(),
  totalExcl: (json['totalExcl'] as num).toDouble(),
  vat: (json['vat'] as num).toDouble(),
  totalIncl: (json['totalIncl'] as num).toDouble(),
  saving: (json['saving'] as num).toDouble(),
);

Map<String, dynamic> _$OrderLineToJson(_OrderLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'freeQuantity': instance.freeQuantity,
      'price': instance.price,
      'totalExcl': instance.totalExcl,
      'vat': instance.vat,
      'totalIncl': instance.totalIncl,
      'saving': instance.saving,
    };

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String?,
  orderNumber: json['orderNumber'] as String?,
  customerCategory: json['customerCategory'] as String,
  customerRoute: json['customerRoute'] as String,
  lines: (json['lines'] as List<dynamic>)
      .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalSaving: (json['totalSaving'] as num).toDouble(),
  totalVat: (json['totalVat'] as num).toDouble(),
  totalInclusive: (json['totalInclusive'] as num).toDouble(),
  status: json['status'] as String?,
  orderDate: json['orderDate'] == null
      ? null
      : DateTime.parse(json['orderDate'] as String),
  invoice: json['invoice'] as String?,
  invoiceDate: json['invoiceDate'] == null
      ? null
      : DateTime.parse(json['invoiceDate'] as String),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderNumber': instance.orderNumber,
  'customerCategory': instance.customerCategory,
  'customerRoute': instance.customerRoute,
  'lines': instance.lines,
  'totalSaving': instance.totalSaving,
  'totalVat': instance.totalVat,
  'totalInclusive': instance.totalInclusive,
  'status': instance.status,
  'orderDate': instance.orderDate?.toIso8601String(),
  'invoice': instance.invoice,
  'invoiceDate': instance.invoiceDate?.toIso8601String(),
};

_OrderHistory _$OrderHistoryFromJson(Map<String, dynamic> json) =>
    _OrderHistory(
      id: json['id'] as String,
      company: json['company'] as String,
      account: json['account'] as String,
      orderNumber: json['orderNumber'] as String,
      orderDate: json['orderDate'] as String,
      invoice: json['invoice'] as String,
      invoiceDate: json['invoiceDate'] as String,
      orderTotalIncl: (json['orderTotalIncl'] as num).toDouble(),
      invTotalIncl: (json['invTotalIncl'] as num).toDouble(),
      saving: (json['saving'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$OrderHistoryToJson(_OrderHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company': instance.company,
      'account': instance.account,
      'orderNumber': instance.orderNumber,
      'orderDate': instance.orderDate,
      'invoice': instance.invoice,
      'invoiceDate': instance.invoiceDate,
      'orderTotalIncl': instance.orderTotalIncl,
      'invTotalIncl': instance.invTotalIncl,
      'saving': instance.saving,
      'status': instance.status,
    };
