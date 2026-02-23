// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_contribution_dispute_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateContributionDisputeRequest {

 String get reason; String? get note;
/// Create a copy of CreateContributionDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateContributionDisputeRequestCopyWith<CreateContributionDisputeRequest> get copyWith => _$CreateContributionDisputeRequestCopyWithImpl<CreateContributionDisputeRequest>(this as CreateContributionDisputeRequest, _$identity);

  /// Serializes this CreateContributionDisputeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateContributionDisputeRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CreateContributionDisputeRequest(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class $CreateContributionDisputeRequestCopyWith<$Res>  {
  factory $CreateContributionDisputeRequestCopyWith(CreateContributionDisputeRequest value, $Res Function(CreateContributionDisputeRequest) _then) = _$CreateContributionDisputeRequestCopyWithImpl;
@useResult
$Res call({
 String reason, String? note
});




}
/// @nodoc
class _$CreateContributionDisputeRequestCopyWithImpl<$Res>
    implements $CreateContributionDisputeRequestCopyWith<$Res> {
  _$CreateContributionDisputeRequestCopyWithImpl(this._self, this._then);

  final CreateContributionDisputeRequest _self;
  final $Res Function(CreateContributionDisputeRequest) _then;

/// Create a copy of CreateContributionDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateContributionDisputeRequest].
extension CreateContributionDisputeRequestPatterns on CreateContributionDisputeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateContributionDisputeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateContributionDisputeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateContributionDisputeRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateContributionDisputeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateContributionDisputeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateContributionDisputeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reason,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateContributionDisputeRequest() when $default != null:
return $default(_that.reason,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reason,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CreateContributionDisputeRequest():
return $default(_that.reason,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reason,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CreateContributionDisputeRequest() when $default != null:
return $default(_that.reason,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateContributionDisputeRequest implements CreateContributionDisputeRequest {
  const _CreateContributionDisputeRequest({required this.reason, this.note});
  factory _CreateContributionDisputeRequest.fromJson(Map<String, dynamic> json) => _$CreateContributionDisputeRequestFromJson(json);

@override final  String reason;
@override final  String? note;

/// Create a copy of CreateContributionDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateContributionDisputeRequestCopyWith<_CreateContributionDisputeRequest> get copyWith => __$CreateContributionDisputeRequestCopyWithImpl<_CreateContributionDisputeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateContributionDisputeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateContributionDisputeRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CreateContributionDisputeRequest(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CreateContributionDisputeRequestCopyWith<$Res> implements $CreateContributionDisputeRequestCopyWith<$Res> {
  factory _$CreateContributionDisputeRequestCopyWith(_CreateContributionDisputeRequest value, $Res Function(_CreateContributionDisputeRequest) _then) = __$CreateContributionDisputeRequestCopyWithImpl;
@override @useResult
$Res call({
 String reason, String? note
});




}
/// @nodoc
class __$CreateContributionDisputeRequestCopyWithImpl<$Res>
    implements _$CreateContributionDisputeRequestCopyWith<$Res> {
  __$CreateContributionDisputeRequestCopyWithImpl(this._self, this._then);

  final _CreateContributionDisputeRequest _self;
  final $Res Function(_CreateContributionDisputeRequest) _then;

/// Create a copy of CreateContributionDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_CreateContributionDisputeRequest(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
