// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_order_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayoutOrderItem {

 String get userId;@JsonKey(fromJson: _toInt) int get payoutPosition;
/// Create a copy of PayoutOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutOrderItemCopyWith<PayoutOrderItem> get copyWith => _$PayoutOrderItemCopyWithImpl<PayoutOrderItem>(this as PayoutOrderItem, _$identity);

  /// Serializes this PayoutOrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutOrderItem&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.payoutPosition, payoutPosition) || other.payoutPosition == payoutPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,payoutPosition);

@override
String toString() {
  return 'PayoutOrderItem(userId: $userId, payoutPosition: $payoutPosition)';
}


}

/// @nodoc
abstract mixin class $PayoutOrderItemCopyWith<$Res>  {
  factory $PayoutOrderItemCopyWith(PayoutOrderItem value, $Res Function(PayoutOrderItem) _then) = _$PayoutOrderItemCopyWithImpl;
@useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int payoutPosition
});




}
/// @nodoc
class _$PayoutOrderItemCopyWithImpl<$Res>
    implements $PayoutOrderItemCopyWith<$Res> {
  _$PayoutOrderItemCopyWithImpl(this._self, this._then);

  final PayoutOrderItem _self;
  final $Res Function(PayoutOrderItem) _then;

/// Create a copy of PayoutOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? payoutPosition = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,payoutPosition: null == payoutPosition ? _self.payoutPosition : payoutPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutOrderItem].
extension PayoutOrderItemPatterns on PayoutOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _PayoutOrderItem():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int payoutPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutOrderItem() when $default != null:
return $default(_that.userId,_that.payoutPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int payoutPosition)  $default,) {final _that = this;
switch (_that) {
case _PayoutOrderItem():
return $default(_that.userId,_that.payoutPosition);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId, @JsonKey(fromJson: _toInt)  int payoutPosition)?  $default,) {final _that = this;
switch (_that) {
case _PayoutOrderItem() when $default != null:
return $default(_that.userId,_that.payoutPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayoutOrderItem implements PayoutOrderItem {
  const _PayoutOrderItem({required this.userId, @JsonKey(fromJson: _toInt) required this.payoutPosition});
  factory _PayoutOrderItem.fromJson(Map<String, dynamic> json) => _$PayoutOrderItemFromJson(json);

@override final  String userId;
@override@JsonKey(fromJson: _toInt) final  int payoutPosition;

/// Create a copy of PayoutOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutOrderItemCopyWith<_PayoutOrderItem> get copyWith => __$PayoutOrderItemCopyWithImpl<_PayoutOrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutOrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutOrderItem&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.payoutPosition, payoutPosition) || other.payoutPosition == payoutPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,payoutPosition);

@override
String toString() {
  return 'PayoutOrderItem(userId: $userId, payoutPosition: $payoutPosition)';
}


}

/// @nodoc
abstract mixin class _$PayoutOrderItemCopyWith<$Res> implements $PayoutOrderItemCopyWith<$Res> {
  factory _$PayoutOrderItemCopyWith(_PayoutOrderItem value, $Res Function(_PayoutOrderItem) _then) = __$PayoutOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int payoutPosition
});




}
/// @nodoc
class __$PayoutOrderItemCopyWithImpl<$Res>
    implements _$PayoutOrderItemCopyWith<$Res> {
  __$PayoutOrderItemCopyWithImpl(this._self, this._then);

  final _PayoutOrderItem _self;
  final $Res Function(_PayoutOrderItem) _then;

/// Create a copy of PayoutOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? payoutPosition = null,}) {
  return _then(_PayoutOrderItem(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,payoutPosition: null == payoutPosition ? _self.payoutPosition : payoutPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
