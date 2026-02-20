// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_payout_order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetPayoutOrderRequest {

 List<PayoutOrderItem> get items;
/// Create a copy of SetPayoutOrderRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetPayoutOrderRequestCopyWith<SetPayoutOrderRequest> get copyWith => _$SetPayoutOrderRequestCopyWithImpl<SetPayoutOrderRequest>(this as SetPayoutOrderRequest, _$identity);

  /// Serializes this SetPayoutOrderRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetPayoutOrderRequest&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'SetPayoutOrderRequest(items: $items)';
}


}

/// @nodoc
abstract mixin class $SetPayoutOrderRequestCopyWith<$Res>  {
  factory $SetPayoutOrderRequestCopyWith(SetPayoutOrderRequest value, $Res Function(SetPayoutOrderRequest) _then) = _$SetPayoutOrderRequestCopyWithImpl;
@useResult
$Res call({
 List<PayoutOrderItem> items
});




}
/// @nodoc
class _$SetPayoutOrderRequestCopyWithImpl<$Res>
    implements $SetPayoutOrderRequestCopyWith<$Res> {
  _$SetPayoutOrderRequestCopyWithImpl(this._self, this._then);

  final SetPayoutOrderRequest _self;
  final $Res Function(SetPayoutOrderRequest) _then;

/// Create a copy of SetPayoutOrderRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PayoutOrderItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [SetPayoutOrderRequest].
extension SetPayoutOrderRequestPatterns on SetPayoutOrderRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetPayoutOrderRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetPayoutOrderRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetPayoutOrderRequest value)  $default,){
final _that = this;
switch (_that) {
case _SetPayoutOrderRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetPayoutOrderRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SetPayoutOrderRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PayoutOrderItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetPayoutOrderRequest() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PayoutOrderItem> items)  $default,) {final _that = this;
switch (_that) {
case _SetPayoutOrderRequest():
return $default(_that.items);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PayoutOrderItem> items)?  $default,) {final _that = this;
switch (_that) {
case _SetPayoutOrderRequest() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetPayoutOrderRequest extends SetPayoutOrderRequest {
  const _SetPayoutOrderRequest({required final  List<PayoutOrderItem> items}): _items = items,super._();
  factory _SetPayoutOrderRequest.fromJson(Map<String, dynamic> json) => _$SetPayoutOrderRequestFromJson(json);

 final  List<PayoutOrderItem> _items;
@override List<PayoutOrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of SetPayoutOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetPayoutOrderRequestCopyWith<_SetPayoutOrderRequest> get copyWith => __$SetPayoutOrderRequestCopyWithImpl<_SetPayoutOrderRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetPayoutOrderRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetPayoutOrderRequest&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'SetPayoutOrderRequest(items: $items)';
}


}

/// @nodoc
abstract mixin class _$SetPayoutOrderRequestCopyWith<$Res> implements $SetPayoutOrderRequestCopyWith<$Res> {
  factory _$SetPayoutOrderRequestCopyWith(_SetPayoutOrderRequest value, $Res Function(_SetPayoutOrderRequest) _then) = __$SetPayoutOrderRequestCopyWithImpl;
@override @useResult
$Res call({
 List<PayoutOrderItem> items
});




}
/// @nodoc
class __$SetPayoutOrderRequestCopyWithImpl<$Res>
    implements _$SetPayoutOrderRequestCopyWith<$Res> {
  __$SetPayoutOrderRequestCopyWithImpl(this._self, this._then);

  final _SetPayoutOrderRequest _self;
  final $Res Function(_SetPayoutOrderRequest) _then;

/// Create a copy of SetPayoutOrderRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_SetPayoutOrderRequest(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PayoutOrderItem>,
  ));
}


}

// dart format on
