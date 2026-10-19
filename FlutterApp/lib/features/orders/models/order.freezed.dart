// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderLine {

 String get id; Product get product; int get quantity; int get freeQuantity; double get price; double get totalExcl; double get vat; double get totalIncl; double get saving;
/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderLineCopyWith<OrderLine> get copyWith => _$OrderLineCopyWithImpl<OrderLine>(this as OrderLine, _$identity);

  /// Serializes this OrderLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.freeQuantity, freeQuantity) || other.freeQuantity == freeQuantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.totalExcl, totalExcl) || other.totalExcl == totalExcl)&&(identical(other.vat, vat) || other.vat == vat)&&(identical(other.totalIncl, totalIncl) || other.totalIncl == totalIncl)&&(identical(other.saving, saving) || other.saving == saving));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,quantity,freeQuantity,price,totalExcl,vat,totalIncl,saving);

@override
String toString() {
  return 'OrderLine(id: $id, product: $product, quantity: $quantity, freeQuantity: $freeQuantity, price: $price, totalExcl: $totalExcl, vat: $vat, totalIncl: $totalIncl, saving: $saving)';
}


}

/// @nodoc
abstract mixin class $OrderLineCopyWith<$Res>  {
  factory $OrderLineCopyWith(OrderLine value, $Res Function(OrderLine) _then) = _$OrderLineCopyWithImpl;
@useResult
$Res call({
 String id, Product product, int quantity, int freeQuantity, double price, double totalExcl, double vat, double totalIncl, double saving
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class _$OrderLineCopyWithImpl<$Res>
    implements $OrderLineCopyWith<$Res> {
  _$OrderLineCopyWithImpl(this._self, this._then);

  final OrderLine _self;
  final $Res Function(OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? quantity = null,Object? freeQuantity = null,Object? price = null,Object? totalExcl = null,Object? vat = null,Object? totalIncl = null,Object? saving = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,freeQuantity: null == freeQuantity ? _self.freeQuantity : freeQuantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,totalExcl: null == totalExcl ? _self.totalExcl : totalExcl // ignore: cast_nullable_to_non_nullable
as double,vat: null == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as double,totalIncl: null == totalIncl ? _self.totalIncl : totalIncl // ignore: cast_nullable_to_non_nullable
as double,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderLine].
extension OrderLinePatterns on OrderLine {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderLine value)  $default,){
final _that = this;
switch (_that) {
case _OrderLine():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderLine value)?  $default,){
final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Product product,  int quantity,  int freeQuantity,  double price,  double totalExcl,  double vat,  double totalIncl,  double saving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.id,_that.product,_that.quantity,_that.freeQuantity,_that.price,_that.totalExcl,_that.vat,_that.totalIncl,_that.saving);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Product product,  int quantity,  int freeQuantity,  double price,  double totalExcl,  double vat,  double totalIncl,  double saving)  $default,) {final _that = this;
switch (_that) {
case _OrderLine():
return $default(_that.id,_that.product,_that.quantity,_that.freeQuantity,_that.price,_that.totalExcl,_that.vat,_that.totalIncl,_that.saving);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Product product,  int quantity,  int freeQuantity,  double price,  double totalExcl,  double vat,  double totalIncl,  double saving)?  $default,) {final _that = this;
switch (_that) {
case _OrderLine() when $default != null:
return $default(_that.id,_that.product,_that.quantity,_that.freeQuantity,_that.price,_that.totalExcl,_that.vat,_that.totalIncl,_that.saving);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderLine implements OrderLine {
  const _OrderLine({required this.id, required this.product, required this.quantity, this.freeQuantity = 0, required this.price, required this.totalExcl, required this.vat, required this.totalIncl, required this.saving});
  factory _OrderLine.fromJson(Map<String, dynamic> json) => _$OrderLineFromJson(json);

@override final  String id;
@override final  Product product;
@override final  int quantity;
@override@JsonKey() final  int freeQuantity;
@override final  double price;
@override final  double totalExcl;
@override final  double vat;
@override final  double totalIncl;
@override final  double saving;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderLineCopyWith<_OrderLine> get copyWith => __$OrderLineCopyWithImpl<_OrderLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderLine&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.freeQuantity, freeQuantity) || other.freeQuantity == freeQuantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.totalExcl, totalExcl) || other.totalExcl == totalExcl)&&(identical(other.vat, vat) || other.vat == vat)&&(identical(other.totalIncl, totalIncl) || other.totalIncl == totalIncl)&&(identical(other.saving, saving) || other.saving == saving));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,quantity,freeQuantity,price,totalExcl,vat,totalIncl,saving);

@override
String toString() {
  return 'OrderLine(id: $id, product: $product, quantity: $quantity, freeQuantity: $freeQuantity, price: $price, totalExcl: $totalExcl, vat: $vat, totalIncl: $totalIncl, saving: $saving)';
}


}

/// @nodoc
abstract mixin class _$OrderLineCopyWith<$Res> implements $OrderLineCopyWith<$Res> {
  factory _$OrderLineCopyWith(_OrderLine value, $Res Function(_OrderLine) _then) = __$OrderLineCopyWithImpl;
@override @useResult
$Res call({
 String id, Product product, int quantity, int freeQuantity, double price, double totalExcl, double vat, double totalIncl, double saving
});


@override $ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$OrderLineCopyWithImpl<$Res>
    implements _$OrderLineCopyWith<$Res> {
  __$OrderLineCopyWithImpl(this._self, this._then);

  final _OrderLine _self;
  final $Res Function(_OrderLine) _then;

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? quantity = null,Object? freeQuantity = null,Object? price = null,Object? totalExcl = null,Object? vat = null,Object? totalIncl = null,Object? saving = null,}) {
  return _then(_OrderLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,freeQuantity: null == freeQuantity ? _self.freeQuantity : freeQuantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,totalExcl: null == totalExcl ? _self.totalExcl : totalExcl // ignore: cast_nullable_to_non_nullable
as double,vat: null == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as double,totalIncl: null == totalIncl ? _self.totalIncl : totalIncl // ignore: cast_nullable_to_non_nullable
as double,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of OrderLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$Order {

 String? get id; String? get orderNumber; String get customerCategory; String get customerRoute; List<OrderLine> get lines; double get totalSaving; double get totalVat; double get totalInclusive; String? get status; DateTime? get orderDate; String? get invoice; DateTime? get invoiceDate;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.customerCategory, customerCategory) || other.customerCategory == customerCategory)&&(identical(other.customerRoute, customerRoute) || other.customerRoute == customerRoute)&&const DeepCollectionEquality().equals(other.lines, lines)&&(identical(other.totalSaving, totalSaving) || other.totalSaving == totalSaving)&&(identical(other.totalVat, totalVat) || other.totalVat == totalVat)&&(identical(other.totalInclusive, totalInclusive) || other.totalInclusive == totalInclusive)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.invoice, invoice) || other.invoice == invoice)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,customerCategory,customerRoute,const DeepCollectionEquality().hash(lines),totalSaving,totalVat,totalInclusive,status,orderDate,invoice,invoiceDate);

@override
String toString() {
  return 'Order(id: $id, orderNumber: $orderNumber, customerCategory: $customerCategory, customerRoute: $customerRoute, lines: $lines, totalSaving: $totalSaving, totalVat: $totalVat, totalInclusive: $totalInclusive, status: $status, orderDate: $orderDate, invoice: $invoice, invoiceDate: $invoiceDate)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String? id, String? orderNumber, String customerCategory, String customerRoute, List<OrderLine> lines, double totalSaving, double totalVat, double totalInclusive, String? status, DateTime? orderDate, String? invoice, DateTime? invoiceDate
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? orderNumber = freezed,Object? customerCategory = null,Object? customerRoute = null,Object? lines = null,Object? totalSaving = null,Object? totalVat = null,Object? totalInclusive = null,Object? status = freezed,Object? orderDate = freezed,Object? invoice = freezed,Object? invoiceDate = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,customerCategory: null == customerCategory ? _self.customerCategory : customerCategory // ignore: cast_nullable_to_non_nullable
as String,customerRoute: null == customerRoute ? _self.customerRoute : customerRoute // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,totalSaving: null == totalSaving ? _self.totalSaving : totalSaving // ignore: cast_nullable_to_non_nullable
as double,totalVat: null == totalVat ? _self.totalVat : totalVat // ignore: cast_nullable_to_non_nullable
as double,totalInclusive: null == totalInclusive ? _self.totalInclusive : totalInclusive // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,orderDate: freezed == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime?,invoice: freezed == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as String?,invoiceDate: freezed == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? orderNumber,  String customerCategory,  String customerRoute,  List<OrderLine> lines,  double totalSaving,  double totalVat,  double totalInclusive,  String? status,  DateTime? orderDate,  String? invoice,  DateTime? invoiceDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.customerCategory,_that.customerRoute,_that.lines,_that.totalSaving,_that.totalVat,_that.totalInclusive,_that.status,_that.orderDate,_that.invoice,_that.invoiceDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? orderNumber,  String customerCategory,  String customerRoute,  List<OrderLine> lines,  double totalSaving,  double totalVat,  double totalInclusive,  String? status,  DateTime? orderDate,  String? invoice,  DateTime? invoiceDate)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.orderNumber,_that.customerCategory,_that.customerRoute,_that.lines,_that.totalSaving,_that.totalVat,_that.totalInclusive,_that.status,_that.orderDate,_that.invoice,_that.invoiceDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? orderNumber,  String customerCategory,  String customerRoute,  List<OrderLine> lines,  double totalSaving,  double totalVat,  double totalInclusive,  String? status,  DateTime? orderDate,  String? invoice,  DateTime? invoiceDate)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.customerCategory,_that.customerRoute,_that.lines,_that.totalSaving,_that.totalVat,_that.totalInclusive,_that.status,_that.orderDate,_that.invoice,_that.invoiceDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({this.id, this.orderNumber, required this.customerCategory, required this.customerRoute, required final  List<OrderLine> lines, required this.totalSaving, required this.totalVat, required this.totalInclusive, this.status, this.orderDate, this.invoice, this.invoiceDate}): _lines = lines;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String? id;
@override final  String? orderNumber;
@override final  String customerCategory;
@override final  String customerRoute;
 final  List<OrderLine> _lines;
@override List<OrderLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  double totalSaving;
@override final  double totalVat;
@override final  double totalInclusive;
@override final  String? status;
@override final  DateTime? orderDate;
@override final  String? invoice;
@override final  DateTime? invoiceDate;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.customerCategory, customerCategory) || other.customerCategory == customerCategory)&&(identical(other.customerRoute, customerRoute) || other.customerRoute == customerRoute)&&const DeepCollectionEquality().equals(other._lines, _lines)&&(identical(other.totalSaving, totalSaving) || other.totalSaving == totalSaving)&&(identical(other.totalVat, totalVat) || other.totalVat == totalVat)&&(identical(other.totalInclusive, totalInclusive) || other.totalInclusive == totalInclusive)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.invoice, invoice) || other.invoice == invoice)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,customerCategory,customerRoute,const DeepCollectionEquality().hash(_lines),totalSaving,totalVat,totalInclusive,status,orderDate,invoice,invoiceDate);

@override
String toString() {
  return 'Order(id: $id, orderNumber: $orderNumber, customerCategory: $customerCategory, customerRoute: $customerRoute, lines: $lines, totalSaving: $totalSaving, totalVat: $totalVat, totalInclusive: $totalInclusive, status: $status, orderDate: $orderDate, invoice: $invoice, invoiceDate: $invoiceDate)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? orderNumber, String customerCategory, String customerRoute, List<OrderLine> lines, double totalSaving, double totalVat, double totalInclusive, String? status, DateTime? orderDate, String? invoice, DateTime? invoiceDate
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? orderNumber = freezed,Object? customerCategory = null,Object? customerRoute = null,Object? lines = null,Object? totalSaving = null,Object? totalVat = null,Object? totalInclusive = null,Object? status = freezed,Object? orderDate = freezed,Object? invoice = freezed,Object? invoiceDate = freezed,}) {
  return _then(_Order(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,customerCategory: null == customerCategory ? _self.customerCategory : customerCategory // ignore: cast_nullable_to_non_nullable
as String,customerRoute: null == customerRoute ? _self.customerRoute : customerRoute // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<OrderLine>,totalSaving: null == totalSaving ? _self.totalSaving : totalSaving // ignore: cast_nullable_to_non_nullable
as double,totalVat: null == totalVat ? _self.totalVat : totalVat // ignore: cast_nullable_to_non_nullable
as double,totalInclusive: null == totalInclusive ? _self.totalInclusive : totalInclusive // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,orderDate: freezed == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as DateTime?,invoice: freezed == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as String?,invoiceDate: freezed == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$OrderHistory {

 String get id; String get company; String get account; String get orderNumber; String get orderDate; String get invoice; String get invoiceDate; double get orderTotalIncl; double get invTotalIncl; double get saving; String get status;
/// Create a copy of OrderHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderHistoryCopyWith<OrderHistory> get copyWith => _$OrderHistoryCopyWithImpl<OrderHistory>(this as OrderHistory, _$identity);

  /// Serializes this OrderHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.account, account) || other.account == account)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.invoice, invoice) || other.invoice == invoice)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate)&&(identical(other.orderTotalIncl, orderTotalIncl) || other.orderTotalIncl == orderTotalIncl)&&(identical(other.invTotalIncl, invTotalIncl) || other.invTotalIncl == invTotalIncl)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,company,account,orderNumber,orderDate,invoice,invoiceDate,orderTotalIncl,invTotalIncl,saving,status);

@override
String toString() {
  return 'OrderHistory(id: $id, company: $company, account: $account, orderNumber: $orderNumber, orderDate: $orderDate, invoice: $invoice, invoiceDate: $invoiceDate, orderTotalIncl: $orderTotalIncl, invTotalIncl: $invTotalIncl, saving: $saving, status: $status)';
}


}

/// @nodoc
abstract mixin class $OrderHistoryCopyWith<$Res>  {
  factory $OrderHistoryCopyWith(OrderHistory value, $Res Function(OrderHistory) _then) = _$OrderHistoryCopyWithImpl;
@useResult
$Res call({
 String id, String company, String account, String orderNumber, String orderDate, String invoice, String invoiceDate, double orderTotalIncl, double invTotalIncl, double saving, String status
});




}
/// @nodoc
class _$OrderHistoryCopyWithImpl<$Res>
    implements $OrderHistoryCopyWith<$Res> {
  _$OrderHistoryCopyWithImpl(this._self, this._then);

  final OrderHistory _self;
  final $Res Function(OrderHistory) _then;

/// Create a copy of OrderHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? company = null,Object? account = null,Object? orderNumber = null,Object? orderDate = null,Object? invoice = null,Object? invoiceDate = null,Object? orderTotalIncl = null,Object? invTotalIncl = null,Object? saving = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String,invoice: null == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as String,invoiceDate: null == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as String,orderTotalIncl: null == orderTotalIncl ? _self.orderTotalIncl : orderTotalIncl // ignore: cast_nullable_to_non_nullable
as double,invTotalIncl: null == invTotalIncl ? _self.invTotalIncl : invTotalIncl // ignore: cast_nullable_to_non_nullable
as double,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderHistory].
extension OrderHistoryPatterns on OrderHistory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderHistory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderHistory value)  $default,){
final _that = this;
switch (_that) {
case _OrderHistory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderHistory value)?  $default,){
final _that = this;
switch (_that) {
case _OrderHistory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String company,  String account,  String orderNumber,  String orderDate,  String invoice,  String invoiceDate,  double orderTotalIncl,  double invTotalIncl,  double saving,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderHistory() when $default != null:
return $default(_that.id,_that.company,_that.account,_that.orderNumber,_that.orderDate,_that.invoice,_that.invoiceDate,_that.orderTotalIncl,_that.invTotalIncl,_that.saving,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String company,  String account,  String orderNumber,  String orderDate,  String invoice,  String invoiceDate,  double orderTotalIncl,  double invTotalIncl,  double saving,  String status)  $default,) {final _that = this;
switch (_that) {
case _OrderHistory():
return $default(_that.id,_that.company,_that.account,_that.orderNumber,_that.orderDate,_that.invoice,_that.invoiceDate,_that.orderTotalIncl,_that.invTotalIncl,_that.saving,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String company,  String account,  String orderNumber,  String orderDate,  String invoice,  String invoiceDate,  double orderTotalIncl,  double invTotalIncl,  double saving,  String status)?  $default,) {final _that = this;
switch (_that) {
case _OrderHistory() when $default != null:
return $default(_that.id,_that.company,_that.account,_that.orderNumber,_that.orderDate,_that.invoice,_that.invoiceDate,_that.orderTotalIncl,_that.invTotalIncl,_that.saving,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderHistory implements OrderHistory {
  const _OrderHistory({required this.id, required this.company, required this.account, required this.orderNumber, required this.orderDate, required this.invoice, required this.invoiceDate, required this.orderTotalIncl, required this.invTotalIncl, required this.saving, required this.status});
  factory _OrderHistory.fromJson(Map<String, dynamic> json) => _$OrderHistoryFromJson(json);

@override final  String id;
@override final  String company;
@override final  String account;
@override final  String orderNumber;
@override final  String orderDate;
@override final  String invoice;
@override final  String invoiceDate;
@override final  double orderTotalIncl;
@override final  double invTotalIncl;
@override final  double saving;
@override final  String status;

/// Create a copy of OrderHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderHistoryCopyWith<_OrderHistory> get copyWith => __$OrderHistoryCopyWithImpl<_OrderHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.account, account) || other.account == account)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.invoice, invoice) || other.invoice == invoice)&&(identical(other.invoiceDate, invoiceDate) || other.invoiceDate == invoiceDate)&&(identical(other.orderTotalIncl, orderTotalIncl) || other.orderTotalIncl == orderTotalIncl)&&(identical(other.invTotalIncl, invTotalIncl) || other.invTotalIncl == invTotalIncl)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,company,account,orderNumber,orderDate,invoice,invoiceDate,orderTotalIncl,invTotalIncl,saving,status);

@override
String toString() {
  return 'OrderHistory(id: $id, company: $company, account: $account, orderNumber: $orderNumber, orderDate: $orderDate, invoice: $invoice, invoiceDate: $invoiceDate, orderTotalIncl: $orderTotalIncl, invTotalIncl: $invTotalIncl, saving: $saving, status: $status)';
}


}

/// @nodoc
abstract mixin class _$OrderHistoryCopyWith<$Res> implements $OrderHistoryCopyWith<$Res> {
  factory _$OrderHistoryCopyWith(_OrderHistory value, $Res Function(_OrderHistory) _then) = __$OrderHistoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String company, String account, String orderNumber, String orderDate, String invoice, String invoiceDate, double orderTotalIncl, double invTotalIncl, double saving, String status
});




}
/// @nodoc
class __$OrderHistoryCopyWithImpl<$Res>
    implements _$OrderHistoryCopyWith<$Res> {
  __$OrderHistoryCopyWithImpl(this._self, this._then);

  final _OrderHistory _self;
  final $Res Function(_OrderHistory) _then;

/// Create a copy of OrderHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? company = null,Object? account = null,Object? orderNumber = null,Object? orderDate = null,Object? invoice = null,Object? invoiceDate = null,Object? orderTotalIncl = null,Object? invTotalIncl = null,Object? saving = null,Object? status = null,}) {
  return _then(_OrderHistory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String,invoice: null == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as String,invoiceDate: null == invoiceDate ? _self.invoiceDate : invoiceDate // ignore: cast_nullable_to_non_nullable
as String,orderTotalIncl: null == orderTotalIncl ? _self.orderTotalIncl : orderTotalIncl // ignore: cast_nullable_to_non_nullable
as double,invTotalIncl: null == invTotalIncl ? _self.invTotalIncl : invTotalIncl // ignore: cast_nullable_to_non_nullable
as double,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
