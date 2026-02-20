// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signed_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignedUploadRequest {

 UploadPurposeModel get purpose; String get groupId; String get cycleId; String get contentType; String get fileName;
/// Create a copy of SignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignedUploadRequestCopyWith<SignedUploadRequest> get copyWith => _$SignedUploadRequestCopyWithImpl<SignedUploadRequest>(this as SignedUploadRequest, _$identity);

  /// Serializes this SignedUploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignedUploadRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,groupId,cycleId,contentType,fileName);

@override
String toString() {
  return 'SignedUploadRequest(purpose: $purpose, groupId: $groupId, cycleId: $cycleId, contentType: $contentType, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $SignedUploadRequestCopyWith<$Res>  {
  factory $SignedUploadRequestCopyWith(SignedUploadRequest value, $Res Function(SignedUploadRequest) _then) = _$SignedUploadRequestCopyWithImpl;
@useResult
$Res call({
 UploadPurposeModel purpose, String groupId, String cycleId, String contentType, String fileName
});




}
/// @nodoc
class _$SignedUploadRequestCopyWithImpl<$Res>
    implements $SignedUploadRequestCopyWith<$Res> {
  _$SignedUploadRequestCopyWithImpl(this._self, this._then);

  final SignedUploadRequest _self;
  final $Res Function(SignedUploadRequest) _then;

/// Create a copy of SignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purpose = null,Object? groupId = null,Object? cycleId = null,Object? contentType = null,Object? fileName = null,}) {
  return _then(_self.copyWith(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as UploadPurposeModel,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SignedUploadRequest].
extension SignedUploadRequestPatterns on SignedUploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignedUploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignedUploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignedUploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _SignedUploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignedUploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SignedUploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UploadPurposeModel purpose,  String groupId,  String cycleId,  String contentType,  String fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignedUploadRequest() when $default != null:
return $default(_that.purpose,_that.groupId,_that.cycleId,_that.contentType,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UploadPurposeModel purpose,  String groupId,  String cycleId,  String contentType,  String fileName)  $default,) {final _that = this;
switch (_that) {
case _SignedUploadRequest():
return $default(_that.purpose,_that.groupId,_that.cycleId,_that.contentType,_that.fileName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UploadPurposeModel purpose,  String groupId,  String cycleId,  String contentType,  String fileName)?  $default,) {final _that = this;
switch (_that) {
case _SignedUploadRequest() when $default != null:
return $default(_that.purpose,_that.groupId,_that.cycleId,_that.contentType,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignedUploadRequest implements SignedUploadRequest {
  const _SignedUploadRequest({required this.purpose, required this.groupId, required this.cycleId, required this.contentType, required this.fileName});
  factory _SignedUploadRequest.fromJson(Map<String, dynamic> json) => _$SignedUploadRequestFromJson(json);

@override final  UploadPurposeModel purpose;
@override final  String groupId;
@override final  String cycleId;
@override final  String contentType;
@override final  String fileName;

/// Create a copy of SignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignedUploadRequestCopyWith<_SignedUploadRequest> get copyWith => __$SignedUploadRequestCopyWithImpl<_SignedUploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignedUploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignedUploadRequest&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purpose,groupId,cycleId,contentType,fileName);

@override
String toString() {
  return 'SignedUploadRequest(purpose: $purpose, groupId: $groupId, cycleId: $cycleId, contentType: $contentType, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$SignedUploadRequestCopyWith<$Res> implements $SignedUploadRequestCopyWith<$Res> {
  factory _$SignedUploadRequestCopyWith(_SignedUploadRequest value, $Res Function(_SignedUploadRequest) _then) = __$SignedUploadRequestCopyWithImpl;
@override @useResult
$Res call({
 UploadPurposeModel purpose, String groupId, String cycleId, String contentType, String fileName
});




}
/// @nodoc
class __$SignedUploadRequestCopyWithImpl<$Res>
    implements _$SignedUploadRequestCopyWith<$Res> {
  __$SignedUploadRequestCopyWithImpl(this._self, this._then);

  final _SignedUploadRequest _self;
  final $Res Function(_SignedUploadRequest) _then;

/// Create a copy of SignedUploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purpose = null,Object? groupId = null,Object? cycleId = null,Object? contentType = null,Object? fileName = null,}) {
  return _then(_SignedUploadRequest(
purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as UploadPurposeModel,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
