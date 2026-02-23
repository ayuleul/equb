// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resolve_dispute_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResolveDisputeRequest {

 String get outcome; String? get note;
/// Create a copy of ResolveDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolveDisputeRequestCopyWith<ResolveDisputeRequest> get copyWith => _$ResolveDisputeRequestCopyWithImpl<ResolveDisputeRequest>(this as ResolveDisputeRequest, _$identity);

  /// Serializes this ResolveDisputeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolveDisputeRequest&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outcome,note);

@override
String toString() {
  return 'ResolveDisputeRequest(outcome: $outcome, note: $note)';
}


}

/// @nodoc
abstract mixin class $ResolveDisputeRequestCopyWith<$Res>  {
  factory $ResolveDisputeRequestCopyWith(ResolveDisputeRequest value, $Res Function(ResolveDisputeRequest) _then) = _$ResolveDisputeRequestCopyWithImpl;
@useResult
$Res call({
 String outcome, String? note
});




}
/// @nodoc
class _$ResolveDisputeRequestCopyWithImpl<$Res>
    implements $ResolveDisputeRequestCopyWith<$Res> {
  _$ResolveDisputeRequestCopyWithImpl(this._self, this._then);

  final ResolveDisputeRequest _self;
  final $Res Function(ResolveDisputeRequest) _then;

/// Create a copy of ResolveDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outcome = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolveDisputeRequest].
extension ResolveDisputeRequestPatterns on ResolveDisputeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolveDisputeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolveDisputeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolveDisputeRequest value)  $default,){
final _that = this;
switch (_that) {
case _ResolveDisputeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolveDisputeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ResolveDisputeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String outcome,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolveDisputeRequest() when $default != null:
return $default(_that.outcome,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String outcome,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ResolveDisputeRequest():
return $default(_that.outcome,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String outcome,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ResolveDisputeRequest() when $default != null:
return $default(_that.outcome,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResolveDisputeRequest implements ResolveDisputeRequest {
  const _ResolveDisputeRequest({required this.outcome, this.note});
  factory _ResolveDisputeRequest.fromJson(Map<String, dynamic> json) => _$ResolveDisputeRequestFromJson(json);

@override final  String outcome;
@override final  String? note;

/// Create a copy of ResolveDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolveDisputeRequestCopyWith<_ResolveDisputeRequest> get copyWith => __$ResolveDisputeRequestCopyWithImpl<_ResolveDisputeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResolveDisputeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolveDisputeRequest&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outcome,note);

@override
String toString() {
  return 'ResolveDisputeRequest(outcome: $outcome, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ResolveDisputeRequestCopyWith<$Res> implements $ResolveDisputeRequestCopyWith<$Res> {
  factory _$ResolveDisputeRequestCopyWith(_ResolveDisputeRequest value, $Res Function(_ResolveDisputeRequest) _then) = __$ResolveDisputeRequestCopyWithImpl;
@override @useResult
$Res call({
 String outcome, String? note
});




}
/// @nodoc
class __$ResolveDisputeRequestCopyWithImpl<$Res>
    implements _$ResolveDisputeRequestCopyWith<$Res> {
  __$ResolveDisputeRequestCopyWithImpl(this._self, this._then);

  final _ResolveDisputeRequest _self;
  final $Res Function(_ResolveDisputeRequest) _then;

/// Create a copy of ResolveDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outcome = null,Object? note = freezed,}) {
  return _then(_ResolveDisputeRequest(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
