// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get name; double get price; String get sku; String get supplier; bool get hasPromo; bool get inStock; String? get description; String? get category;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.hasPromo, hasPromo) || other.hasPromo == hasPromo)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,sku,supplier,hasPromo,inStock,description,category);

@override
String toString() {
  return 'Product(id: $id, name: $name, price: $price, sku: $sku, supplier: $supplier, hasPromo: $hasPromo, inStock: $inStock, description: $description, category: $category)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price, String sku, String supplier, bool hasPromo, bool inStock, String? description, String? category
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? sku = null,Object? supplier = null,Object? hasPromo = null,Object? inStock = null,Object? description = freezed,Object? category = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String,hasPromo: null == hasPromo ? _self.hasPromo : hasPromo // ignore: cast_nullable_to_non_nullable
as bool,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price,  String sku,  String supplier,  bool hasPromo,  bool inStock,  String? description,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.sku,_that.supplier,_that.hasPromo,_that.inStock,_that.description,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price,  String sku,  String supplier,  bool hasPromo,  bool inStock,  String? description,  String? category)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.price,_that.sku,_that.supplier,_that.hasPromo,_that.inStock,_that.description,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price,  String sku,  String supplier,  bool hasPromo,  bool inStock,  String? description,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.sku,_that.supplier,_that.hasPromo,_that.inStock,_that.description,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.name, required this.price, required this.sku, required this.supplier, this.hasPromo = false, this.inStock = true, this.description, this.category});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  double price;
@override final  String sku;
@override final  String supplier;
@override@JsonKey() final  bool hasPromo;
@override@JsonKey() final  bool inStock;
@override final  String? description;
@override final  String? category;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.hasPromo, hasPromo) || other.hasPromo == hasPromo)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,sku,supplier,hasPromo,inStock,description,category);

@override
String toString() {
  return 'Product(id: $id, name: $name, price: $price, sku: $sku, supplier: $supplier, hasPromo: $hasPromo, inStock: $inStock, description: $description, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price, String sku, String supplier, bool hasPromo, bool inStock, String? description, String? category
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? sku = null,Object? supplier = null,Object? hasPromo = null,Object? inStock = null,Object? description = freezed,Object? category = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,supplier: null == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String,hasPromo: null == hasPromo ? _self.hasPromo : hasPromo // ignore: cast_nullable_to_non_nullable
as bool,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductPurchaseHistory {

 String get month; String get year; int get quantity;
/// Create a copy of ProductPurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductPurchaseHistoryCopyWith<ProductPurchaseHistory> get copyWith => _$ProductPurchaseHistoryCopyWithImpl<ProductPurchaseHistory>(this as ProductPurchaseHistory, _$identity);

  /// Serializes this ProductPurchaseHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductPurchaseHistory&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,quantity);

@override
String toString() {
  return 'ProductPurchaseHistory(month: $month, year: $year, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $ProductPurchaseHistoryCopyWith<$Res>  {
  factory $ProductPurchaseHistoryCopyWith(ProductPurchaseHistory value, $Res Function(ProductPurchaseHistory) _then) = _$ProductPurchaseHistoryCopyWithImpl;
@useResult
$Res call({
 String month, String year, int quantity
});




}
/// @nodoc
class _$ProductPurchaseHistoryCopyWithImpl<$Res>
    implements $ProductPurchaseHistoryCopyWith<$Res> {
  _$ProductPurchaseHistoryCopyWithImpl(this._self, this._then);

  final ProductPurchaseHistory _self;
  final $Res Function(ProductPurchaseHistory) _then;

/// Create a copy of ProductPurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductPurchaseHistory].
extension ProductPurchaseHistoryPatterns on ProductPurchaseHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductPurchaseHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductPurchaseHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductPurchaseHistory value)  $default,){
final _that = this;
switch (_that) {
case _ProductPurchaseHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductPurchaseHistory value)?  $default,){
final _that = this;
switch (_that) {
case _ProductPurchaseHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  String year,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductPurchaseHistory() when $default != null:
return $default(_that.month,_that.year,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  String year,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _ProductPurchaseHistory():
return $default(_that.month,_that.year,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  String year,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _ProductPurchaseHistory() when $default != null:
return $default(_that.month,_that.year,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductPurchaseHistory implements ProductPurchaseHistory {
  const _ProductPurchaseHistory({required this.month, required this.year, required this.quantity});
  factory _ProductPurchaseHistory.fromJson(Map<String, dynamic> json) => _$ProductPurchaseHistoryFromJson(json);

@override final  String month;
@override final  String year;
@override final  int quantity;

/// Create a copy of ProductPurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductPurchaseHistoryCopyWith<_ProductPurchaseHistory> get copyWith => __$ProductPurchaseHistoryCopyWithImpl<_ProductPurchaseHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductPurchaseHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductPurchaseHistory&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,quantity);

@override
String toString() {
  return 'ProductPurchaseHistory(month: $month, year: $year, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$ProductPurchaseHistoryCopyWith<$Res> implements $ProductPurchaseHistoryCopyWith<$Res> {
  factory _$ProductPurchaseHistoryCopyWith(_ProductPurchaseHistory value, $Res Function(_ProductPurchaseHistory) _then) = __$ProductPurchaseHistoryCopyWithImpl;
@override @useResult
$Res call({
 String month, String year, int quantity
});




}
/// @nodoc
class __$ProductPurchaseHistoryCopyWithImpl<$Res>
    implements _$ProductPurchaseHistoryCopyWith<$Res> {
  __$ProductPurchaseHistoryCopyWithImpl(this._self, this._then);

  final _ProductPurchaseHistory _self;
  final $Res Function(_ProductPurchaseHistory) _then;

/// Create a copy of ProductPurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? quantity = null,}) {
  return _then(_ProductPurchaseHistory(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
