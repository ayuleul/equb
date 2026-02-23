// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_contribution_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubmitContributionRequest {

 GroupPaymentMethodModel get method;@JsonKey(includeIfNull: false) int? get amount;@JsonKey(includeIfNull: false) String? get receiptFileKey;@JsonKey(includeIfNull: false) String? get reference;// legacy compatibility aliases retained by backend
@JsonKey(includeIfNull: false) String? get proofFileKey;@JsonKey(includeIfNull: false) String? get paymentRef;@JsonKey(includeIfNull: false) String? get note;
/// Create a copy of SubmitContributionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitContributionRequestCopyWith<SubmitContributionRequest> get copyWith => _$SubmitContributionRequestCopyWithImpl<SubmitContributionRequest>(this as SubmitContributionRequest, _$identity);

  /// Serializes this SubmitContributionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitContributionRequest&&(identical(other.method, method) || other.method == method)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receiptFileKey, receiptFileKey) || other.receiptFileKey == receiptFileKey)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,amount,receiptFileKey,reference,proofFileKey,paymentRef,note);

@override
String toString() {
  return 'SubmitContributionRequest(method: $method, amount: $amount, receiptFileKey: $receiptFileKey, reference: $reference, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note)';
}


}

/// @nodoc
abstract mixin class $SubmitContributionRequestCopyWith<$Res>  {
  factory $SubmitContributionRequestCopyWith(SubmitContributionRequest value, $Res Function(SubmitContributionRequest) _then) = _$SubmitContributionRequestCopyWithImpl;
@useResult
$Res call({
 GroupPaymentMethodModel method,@JsonKey(includeIfNull: false) int? amount,@JsonKey(includeIfNull: false) String? receiptFileKey,@JsonKey(includeIfNull: false) String? reference,@JsonKey(includeIfNull: false) String? proofFileKey,@JsonKey(includeIfNull: false) String? paymentRef,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class _$SubmitContributionRequestCopyWithImpl<$Res>
    implements $SubmitContributionRequestCopyWith<$Res> {
  _$SubmitContributionRequestCopyWithImpl(this._self, this._then);

  final SubmitContributionRequest _self;
  final $Res Function(SubmitContributionRequest) _then;

/// Create a copy of SubmitContributionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? amount = freezed,Object? receiptFileKey = freezed,Object? reference = freezed,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as GroupPaymentMethodModel,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,receiptFileKey: freezed == receiptFileKey ? _self.receiptFileKey : receiptFileKey // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmitContributionRequest].
extension SubmitContributionRequestPatterns on SubmitContributionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitContributionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitContributionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitContributionRequest value)  $default,){
final _that = this;
switch (_that) {
case _SubmitContributionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitContributionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitContributionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GroupPaymentMethodModel method, @JsonKey(includeIfNull: false)  int? amount, @JsonKey(includeIfNull: false)  String? receiptFileKey, @JsonKey(includeIfNull: false)  String? reference, @JsonKey(includeIfNull: false)  String? proofFileKey, @JsonKey(includeIfNull: false)  String? paymentRef, @JsonKey(includeIfNull: false)  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitContributionRequest() when $default != null:
return $default(_that.method,_that.amount,_that.receiptFileKey,_that.reference,_that.proofFileKey,_that.paymentRef,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GroupPaymentMethodModel method, @JsonKey(includeIfNull: false)  int? amount, @JsonKey(includeIfNull: false)  String? receiptFileKey, @JsonKey(includeIfNull: false)  String? reference, @JsonKey(includeIfNull: false)  String? proofFileKey, @JsonKey(includeIfNull: false)  String? paymentRef, @JsonKey(includeIfNull: false)  String? note)  $default,) {final _that = this;
switch (_that) {
case _SubmitContributionRequest():
return $default(_that.method,_that.amount,_that.receiptFileKey,_that.reference,_that.proofFileKey,_that.paymentRef,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GroupPaymentMethodModel method, @JsonKey(includeIfNull: false)  int? amount, @JsonKey(includeIfNull: false)  String? receiptFileKey, @JsonKey(includeIfNull: false)  String? reference, @JsonKey(includeIfNull: false)  String? proofFileKey, @JsonKey(includeIfNull: false)  String? paymentRef, @JsonKey(includeIfNull: false)  String? note)?  $default,) {final _that = this;
switch (_that) {
case _SubmitContributionRequest() when $default != null:
return $default(_that.method,_that.amount,_that.receiptFileKey,_that.reference,_that.proofFileKey,_that.paymentRef,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubmitContributionRequest implements SubmitContributionRequest {
  const _SubmitContributionRequest({required this.method, @JsonKey(includeIfNull: false) this.amount, @JsonKey(includeIfNull: false) this.receiptFileKey, @JsonKey(includeIfNull: false) this.reference, @JsonKey(includeIfNull: false) this.proofFileKey, @JsonKey(includeIfNull: false) this.paymentRef, @JsonKey(includeIfNull: false) this.note});
  factory _SubmitContributionRequest.fromJson(Map<String, dynamic> json) => _$SubmitContributionRequestFromJson(json);

@override final  GroupPaymentMethodModel method;
@override@JsonKey(includeIfNull: false) final  int? amount;
@override@JsonKey(includeIfNull: false) final  String? receiptFileKey;
@override@JsonKey(includeIfNull: false) final  String? reference;
// legacy compatibility aliases retained by backend
@override@JsonKey(includeIfNull: false) final  String? proofFileKey;
@override@JsonKey(includeIfNull: false) final  String? paymentRef;
@override@JsonKey(includeIfNull: false) final  String? note;

/// Create a copy of SubmitContributionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitContributionRequestCopyWith<_SubmitContributionRequest> get copyWith => __$SubmitContributionRequestCopyWithImpl<_SubmitContributionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubmitContributionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitContributionRequest&&(identical(other.method, method) || other.method == method)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receiptFileKey, receiptFileKey) || other.receiptFileKey == receiptFileKey)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,amount,receiptFileKey,reference,proofFileKey,paymentRef,note);

@override
String toString() {
  return 'SubmitContributionRequest(method: $method, amount: $amount, receiptFileKey: $receiptFileKey, reference: $reference, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note)';
}


}

/// @nodoc
abstract mixin class _$SubmitContributionRequestCopyWith<$Res> implements $SubmitContributionRequestCopyWith<$Res> {
  factory _$SubmitContributionRequestCopyWith(_SubmitContributionRequest value, $Res Function(_SubmitContributionRequest) _then) = __$SubmitContributionRequestCopyWithImpl;
@override @useResult
$Res call({
 GroupPaymentMethodModel method,@JsonKey(includeIfNull: false) int? amount,@JsonKey(includeIfNull: false) String? receiptFileKey,@JsonKey(includeIfNull: false) String? reference,@JsonKey(includeIfNull: false) String? proofFileKey,@JsonKey(includeIfNull: false) String? paymentRef,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class __$SubmitContributionRequestCopyWithImpl<$Res>
    implements _$SubmitContributionRequestCopyWith<$Res> {
  __$SubmitContributionRequestCopyWithImpl(this._self, this._then);

  final _SubmitContributionRequest _self;
  final $Res Function(_SubmitContributionRequest) _then;

/// Create a copy of SubmitContributionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? amount = freezed,Object? receiptFileKey = freezed,Object? reference = freezed,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,}) {
  return _then(_SubmitContributionRequest(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as GroupPaymentMethodModel,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,receiptFileKey: freezed == receiptFileKey ? _self.receiptFileKey : receiptFileKey // ignore: cast_nullable_to_non_nullable
as String?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
