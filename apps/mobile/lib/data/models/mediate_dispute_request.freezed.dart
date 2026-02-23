// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mediate_dispute_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediateDisputeRequest {

 String get note;
/// Create a copy of MediateDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediateDisputeRequestCopyWith<MediateDisputeRequest> get copyWith => _$MediateDisputeRequestCopyWithImpl<MediateDisputeRequest>(this as MediateDisputeRequest, _$identity);

  /// Serializes this MediateDisputeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediateDisputeRequest&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'MediateDisputeRequest(note: $note)';
}


}

/// @nodoc
abstract mixin class $MediateDisputeRequestCopyWith<$Res>  {
  factory $MediateDisputeRequestCopyWith(MediateDisputeRequest value, $Res Function(MediateDisputeRequest) _then) = _$MediateDisputeRequestCopyWithImpl;
@useResult
$Res call({
 String note
});




}
/// @nodoc
class _$MediateDisputeRequestCopyWithImpl<$Res>
    implements $MediateDisputeRequestCopyWith<$Res> {
  _$MediateDisputeRequestCopyWithImpl(this._self, this._then);

  final MediateDisputeRequest _self;
  final $Res Function(MediateDisputeRequest) _then;

/// Create a copy of MediateDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = null,}) {
  return _then(_self.copyWith(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MediateDisputeRequest].
extension MediateDisputeRequestPatterns on MediateDisputeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediateDisputeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediateDisputeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediateDisputeRequest value)  $default,){
final _that = this;
switch (_that) {
case _MediateDisputeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediateDisputeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MediateDisputeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediateDisputeRequest() when $default != null:
return $default(_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String note)  $default,) {final _that = this;
switch (_that) {
case _MediateDisputeRequest():
return $default(_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String note)?  $default,) {final _that = this;
switch (_that) {
case _MediateDisputeRequest() when $default != null:
return $default(_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediateDisputeRequest implements MediateDisputeRequest {
  const _MediateDisputeRequest({required this.note});
  factory _MediateDisputeRequest.fromJson(Map<String, dynamic> json) => _$MediateDisputeRequestFromJson(json);

@override final  String note;

/// Create a copy of MediateDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediateDisputeRequestCopyWith<_MediateDisputeRequest> get copyWith => __$MediateDisputeRequestCopyWithImpl<_MediateDisputeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediateDisputeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediateDisputeRequest&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'MediateDisputeRequest(note: $note)';
}


}

/// @nodoc
abstract mixin class _$MediateDisputeRequestCopyWith<$Res> implements $MediateDisputeRequestCopyWith<$Res> {
  factory _$MediateDisputeRequestCopyWith(_MediateDisputeRequest value, $Res Function(_MediateDisputeRequest) _then) = __$MediateDisputeRequestCopyWithImpl;
@override @useResult
$Res call({
 String note
});




}
/// @nodoc
class __$MediateDisputeRequestCopyWithImpl<$Res>
    implements _$MediateDisputeRequestCopyWith<$Res> {
  __$MediateDisputeRequestCopyWithImpl(this._self, this._then);

  final _MediateDisputeRequest _self;
  final $Res Function(_MediateDisputeRequest) _then;

/// Create a copy of MediateDisputeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = null,}) {
  return _then(_MediateDisputeRequest(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
