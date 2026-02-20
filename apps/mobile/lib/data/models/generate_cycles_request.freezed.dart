// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_cycles_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GenerateCyclesRequest {

@JsonKey(includeIfNull: false) int? get count;
/// Create a copy of GenerateCyclesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateCyclesRequestCopyWith<GenerateCyclesRequest> get copyWith => _$GenerateCyclesRequestCopyWithImpl<GenerateCyclesRequest>(this as GenerateCyclesRequest, _$identity);

  /// Serializes this GenerateCyclesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateCyclesRequest&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'GenerateCyclesRequest(count: $count)';
}


}

/// @nodoc
abstract mixin class $GenerateCyclesRequestCopyWith<$Res>  {
  factory $GenerateCyclesRequestCopyWith(GenerateCyclesRequest value, $Res Function(GenerateCyclesRequest) _then) = _$GenerateCyclesRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) int? count
});




}
/// @nodoc
class _$GenerateCyclesRequestCopyWithImpl<$Res>
    implements $GenerateCyclesRequestCopyWith<$Res> {
  _$GenerateCyclesRequestCopyWithImpl(this._self, this._then);

  final GenerateCyclesRequest _self;
  final $Res Function(GenerateCyclesRequest) _then;

/// Create a copy of GenerateCyclesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = freezed,}) {
  return _then(_self.copyWith(
count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GenerateCyclesRequest].
extension GenerateCyclesRequestPatterns on GenerateCyclesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerateCyclesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerateCyclesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerateCyclesRequest value)  $default,){
final _that = this;
switch (_that) {
case _GenerateCyclesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerateCyclesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _GenerateCyclesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerateCyclesRequest() when $default != null:
return $default(_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  int? count)  $default,) {final _that = this;
switch (_that) {
case _GenerateCyclesRequest():
return $default(_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  int? count)?  $default,) {final _that = this;
switch (_that) {
case _GenerateCyclesRequest() when $default != null:
return $default(_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenerateCyclesRequest implements GenerateCyclesRequest {
  const _GenerateCyclesRequest({@JsonKey(includeIfNull: false) this.count});
  factory _GenerateCyclesRequest.fromJson(Map<String, dynamic> json) => _$GenerateCyclesRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  int? count;

/// Create a copy of GenerateCyclesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateCyclesRequestCopyWith<_GenerateCyclesRequest> get copyWith => __$GenerateCyclesRequestCopyWithImpl<_GenerateCyclesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenerateCyclesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateCyclesRequest&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'GenerateCyclesRequest(count: $count)';
}


}

/// @nodoc
abstract mixin class _$GenerateCyclesRequestCopyWith<$Res> implements $GenerateCyclesRequestCopyWith<$Res> {
  factory _$GenerateCyclesRequestCopyWith(_GenerateCyclesRequest value, $Res Function(_GenerateCyclesRequest) _then) = __$GenerateCyclesRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) int? count
});




}
/// @nodoc
class __$GenerateCyclesRequestCopyWithImpl<$Res>
    implements _$GenerateCyclesRequestCopyWith<$Res> {
  __$GenerateCyclesRequestCopyWithImpl(this._self, this._then);

  final _GenerateCyclesRequest _self;
  final $Res Function(_GenerateCyclesRequest) _then;

/// Create a copy of GenerateCyclesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = freezed,}) {
  return _then(_GenerateCyclesRequest(
count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
