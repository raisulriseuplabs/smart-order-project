import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_orders_desktop/features/orders/models/product.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class OrderLine with _$OrderLine {
  const factory OrderLine({
    required String id,
    required Product product,
    required int quantity,
    @Default(0) int freeQuantity,
    required double price,
    required double totalExcl,
    required double vat,
    required double totalIncl,
    required double saving,
  }) = _OrderLine;

  factory OrderLine.fromJson(Map<String, dynamic> json) =>
      _$OrderLineFromJson(json);
}

@freezed
abstract class Order with _$Order {
  const factory Order({
    String? id,
    String? orderNumber,
    required String customerCategory,
    required String customerRoute,
    required List<OrderLine> lines,
    required double totalSaving,
    required double totalVat,
    required double totalInclusive,
    String? status,
    DateTime? orderDate,
    String? invoice,
    DateTime? invoiceDate,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
abstract class OrderHistory with _$OrderHistory {
  const factory OrderHistory({
    required String id,
    required String company,
    required String account,
    required String orderNumber,
    required String orderDate,
    required String invoice,
    required String invoiceDate,
    required double orderTotalIncl,
    required double invTotalIncl,
    required double saving,
    required String status,
  }) = _OrderHistory;

  factory OrderHistory.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryFromJson(json);
}
