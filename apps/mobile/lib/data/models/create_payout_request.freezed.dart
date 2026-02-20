// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_payout_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatePayoutRequest {

@JsonKey(includeIfNull: false) int? get amount;@JsonKey(includeIfNull: false) String? get proofFileKey;@JsonKey(includeIfNull: false) String? get paymentRef;@JsonKey(includeIfNull: false) String? get note;
/// Create a copy of CreatePayoutRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePayoutRequestCopyWith<CreatePayoutRequest> get copyWith => _$CreatePayoutRequestCopyWithImpl<CreatePayoutRequest>(this as CreatePayoutRequest, _$identity);

  /// Serializes this CreatePayoutRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePayoutRequest&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,proofFileKey,paymentRef,note);

@override
String toString() {
  return 'CreatePayoutRequest(amount: $amount, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note)';
}


}

/// @nodoc
abstract mixin class $CreatePayoutRequestCopyWith<$Res>  {
  factory $CreatePayoutRequestCopyWith(CreatePayoutRequest value, $Res Function(CreatePayoutRequest) _then) = _$CreatePayoutRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) int? amount,@JsonKey(includeIfNull: false) String? proofFileKey,@JsonKey(includeIfNull: false) String? paymentRef,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class _$CreatePayoutRequestCopyWithImpl<$Res>
    implements $CreatePayoutRequestCopyWith<$Res> {
  _$CreatePayoutRequestCopyWithImpl(this._self, this._then);

  final CreatePayoutRequest _self;
  final $Res Function(CreatePayoutRequest) _then;

/// Create a copy of CreatePayoutRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = freezed,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePayoutRequest].
extension CreatePayoutRequestPatterns on CreatePayoutRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePayoutRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePayoutRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePayoutRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreatePayoutRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePayoutRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePayoutRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? amount, @JsonKey(includeIfNull: false)  String? proofFileKey, @JsonKey(includeIfNull: false)  String? paymentRef, @JsonKey(includeIfNull: false)  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePayoutRequest() when $default != null:
return $default(_that.amount,_that.proofFileKey,_that.paymentRef,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? amount, @JsonKey(includeIfNull: false)  String? proofFileKey, @JsonKey(includeIfNull: false)  String? paymentRef, @JsonKey(includeIfNull: false)  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreatePayoutRequest():
return $default(_that.amount,_that.proofFileKey,_that.paymentRef,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  int? amount, @JsonKey(includeIfNull: false)  String? proofFileKey, @JsonKey(includeIfNull: false)  String? paymentRef, @JsonKey(includeIfNull: false)  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreatePayoutRequest() when $default != null:
return $default(_that.amount,_that.proofFileKey,_that.paymentRef,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePayoutRequest implements CreatePayoutRequest {
  const _CreatePayoutRequest({@JsonKey(includeIfNull: false) this.amount, @JsonKey(includeIfNull: false) this.proofFileKey, @JsonKey(includeIfNull: false) this.paymentRef, @JsonKey(includeIfNull: false) this.note});
  factory _CreatePayoutRequest.fromJson(Map<String, dynamic> json) => _$CreatePayoutRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  int? amount;
@override@JsonKey(includeIfNull: false) final  String? proofFileKey;
@override@JsonKey(includeIfNull: false) final  String? paymentRef;
@override@JsonKey(includeIfNull: false) final  String? note;

/// Create a copy of CreatePayoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePayoutRequestCopyWith<_CreatePayoutRequest> get copyWith => __$CreatePayoutRequestCopyWithImpl<_CreatePayoutRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePayoutRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePayoutRequest&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,proofFileKey,paymentRef,note);

@override
String toString() {
  return 'CreatePayoutRequest(amount: $amount, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreatePayoutRequestCopyWith<$Res> implements $CreatePayoutRequestCopyWith<$Res> {
  factory _$CreatePayoutRequestCopyWith(_CreatePayoutRequest value, $Res Function(_CreatePayoutRequest) _then) = __$CreatePayoutRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) int? amount,@JsonKey(includeIfNull: false) String? proofFileKey,@JsonKey(includeIfNull: false) String? paymentRef,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class __$CreatePayoutRequestCopyWithImpl<$Res>
    implements _$CreatePayoutRequestCopyWith<$Res> {
  __$CreatePayoutRequestCopyWithImpl(this._self, this._then);

  final _CreatePayoutRequest _self;
  final $Res Function(_CreatePayoutRequest) _then;

/// Create a copy of CreatePayoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = freezed,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,}) {
  return _then(_CreatePayoutRequest(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
