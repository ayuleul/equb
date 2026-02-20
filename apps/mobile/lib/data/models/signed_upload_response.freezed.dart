// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signed_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignedUploadResponse {

 String get key; String get uploadUrl;@JsonKey(fromJson: _toInt) int get expiresInSeconds;
/// Create a copy of SignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignedUploadResponseCopyWith<SignedUploadResponse> get copyWith => _$SignedUploadResponseCopyWithImpl<SignedUploadResponse>(this as SignedUploadResponse, _$identity);

  /// Serializes this SignedUploadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignedUploadResponse&&(identical(other.key, key) || other.key == key)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,uploadUrl,expiresInSeconds);

@override
String toString() {
  return 'SignedUploadResponse(key: $key, uploadUrl: $uploadUrl, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class $SignedUploadResponseCopyWith<$Res>  {
  factory $SignedUploadResponseCopyWith(SignedUploadResponse value, $Res Function(SignedUploadResponse) _then) = _$SignedUploadResponseCopyWithImpl;
@useResult
$Res call({
 String key, String uploadUrl,@JsonKey(fromJson: _toInt) int expiresInSeconds
});




}
/// @nodoc
class _$SignedUploadResponseCopyWithImpl<$Res>
    implements $SignedUploadResponseCopyWith<$Res> {
  _$SignedUploadResponseCopyWithImpl(this._self, this._then);

  final SignedUploadResponse _self;
  final $Res Function(SignedUploadResponse) _then;

/// Create a copy of SignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? uploadUrl = null,Object? expiresInSeconds = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SignedUploadResponse].
extension SignedUploadResponsePatterns on SignedUploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignedUploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignedUploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignedUploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _SignedUploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignedUploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SignedUploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String uploadUrl, @JsonKey(fromJson: _toInt)  int expiresInSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignedUploadResponse() when $default != null:
return $default(_that.key,_that.uploadUrl,_that.expiresInSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String uploadUrl, @JsonKey(fromJson: _toInt)  int expiresInSeconds)  $default,) {final _that = this;
switch (_that) {
case _SignedUploadResponse():
return $default(_that.key,_that.uploadUrl,_that.expiresInSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String uploadUrl, @JsonKey(fromJson: _toInt)  int expiresInSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SignedUploadResponse() when $default != null:
return $default(_that.key,_that.uploadUrl,_that.expiresInSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignedUploadResponse implements SignedUploadResponse {
  const _SignedUploadResponse({required this.key, required this.uploadUrl, @JsonKey(fromJson: _toInt) required this.expiresInSeconds});
  factory _SignedUploadResponse.fromJson(Map<String, dynamic> json) => _$SignedUploadResponseFromJson(json);

@override final  String key;
@override final  String uploadUrl;
@override@JsonKey(fromJson: _toInt) final  int expiresInSeconds;

/// Create a copy of SignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignedUploadResponseCopyWith<_SignedUploadResponse> get copyWith => __$SignedUploadResponseCopyWithImpl<_SignedUploadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignedUploadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignedUploadResponse&&(identical(other.key, key) || other.key == key)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,uploadUrl,expiresInSeconds);

@override
String toString() {
  return 'SignedUploadResponse(key: $key, uploadUrl: $uploadUrl, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class _$SignedUploadResponseCopyWith<$Res> implements $SignedUploadResponseCopyWith<$Res> {
  factory _$SignedUploadResponseCopyWith(_SignedUploadResponse value, $Res Function(_SignedUploadResponse) _then) = __$SignedUploadResponseCopyWithImpl;
@override @useResult
$Res call({
 String key, String uploadUrl,@JsonKey(fromJson: _toInt) int expiresInSeconds
});




}
/// @nodoc
class __$SignedUploadResponseCopyWithImpl<$Res>
    implements _$SignedUploadResponseCopyWith<$Res> {
  __$SignedUploadResponseCopyWithImpl(this._self, this._then);

  final _SignedUploadResponse _self;
  final $Res Function(_SignedUploadResponse) _then;

/// Create a copy of SignedUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? uploadUrl = null,Object? expiresInSeconds = null,}) {
  return _then(_SignedUploadResponse(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SignedDownloadResponse {

 String get downloadUrl;@JsonKey(fromJson: _toInt) int get expiresInSeconds;
/// Create a copy of SignedDownloadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignedDownloadResponseCopyWith<SignedDownloadResponse> get copyWith => _$SignedDownloadResponseCopyWithImpl<SignedDownloadResponse>(this as SignedDownloadResponse, _$identity);

  /// Serializes this SignedDownloadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignedDownloadResponse&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadUrl,expiresInSeconds);

@override
String toString() {
  return 'SignedDownloadResponse(downloadUrl: $downloadUrl, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class $SignedDownloadResponseCopyWith<$Res>  {
  factory $SignedDownloadResponseCopyWith(SignedDownloadResponse value, $Res Function(SignedDownloadResponse) _then) = _$SignedDownloadResponseCopyWithImpl;
@useResult
$Res call({
 String downloadUrl,@JsonKey(fromJson: _toInt) int expiresInSeconds
});




}
/// @nodoc
class _$SignedDownloadResponseCopyWithImpl<$Res>
    implements $SignedDownloadResponseCopyWith<$Res> {
  _$SignedDownloadResponseCopyWithImpl(this._self, this._then);

  final SignedDownloadResponse _self;
  final $Res Function(SignedDownloadResponse) _then;

/// Create a copy of SignedDownloadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadUrl = null,Object? expiresInSeconds = null,}) {
  return _then(_self.copyWith(
downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SignedDownloadResponse].
extension SignedDownloadResponsePatterns on SignedDownloadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignedDownloadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignedDownloadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignedDownloadResponse value)  $default,){
final _that = this;
switch (_that) {
case _SignedDownloadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignedDownloadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SignedDownloadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String downloadUrl, @JsonKey(fromJson: _toInt)  int expiresInSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignedDownloadResponse() when $default != null:
return $default(_that.downloadUrl,_that.expiresInSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String downloadUrl, @JsonKey(fromJson: _toInt)  int expiresInSeconds)  $default,) {final _that = this;
switch (_that) {
case _SignedDownloadResponse():
return $default(_that.downloadUrl,_that.expiresInSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String downloadUrl, @JsonKey(fromJson: _toInt)  int expiresInSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SignedDownloadResponse() when $default != null:
return $default(_that.downloadUrl,_that.expiresInSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignedDownloadResponse implements SignedDownloadResponse {
  const _SignedDownloadResponse({required this.downloadUrl, @JsonKey(fromJson: _toInt) required this.expiresInSeconds});
  factory _SignedDownloadResponse.fromJson(Map<String, dynamic> json) => _$SignedDownloadResponseFromJson(json);

@override final  String downloadUrl;
@override@JsonKey(fromJson: _toInt) final  int expiresInSeconds;

/// Create a copy of SignedDownloadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignedDownloadResponseCopyWith<_SignedDownloadResponse> get copyWith => __$SignedDownloadResponseCopyWithImpl<_SignedDownloadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignedDownloadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignedDownloadResponse&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.expiresInSeconds, expiresInSeconds) || other.expiresInSeconds == expiresInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadUrl,expiresInSeconds);

@override
String toString() {
  return 'SignedDownloadResponse(downloadUrl: $downloadUrl, expiresInSeconds: $expiresInSeconds)';
}


}

/// @nodoc
abstract mixin class _$SignedDownloadResponseCopyWith<$Res> implements $SignedDownloadResponseCopyWith<$Res> {
  factory _$SignedDownloadResponseCopyWith(_SignedDownloadResponse value, $Res Function(_SignedDownloadResponse) _then) = __$SignedDownloadResponseCopyWithImpl;
@override @useResult
$Res call({
 String downloadUrl,@JsonKey(fromJson: _toInt) int expiresInSeconds
});




}
/// @nodoc
class __$SignedDownloadResponseCopyWithImpl<$Res>
    implements _$SignedDownloadResponseCopyWith<$Res> {
  __$SignedDownloadResponseCopyWithImpl(this._self, this._then);

  final _SignedDownloadResponse _self;
  final $Res Function(_SignedDownloadResponse) _then;

/// Create a copy of SignedDownloadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadUrl = null,Object? expiresInSeconds = null,}) {
  return _then(_SignedDownloadResponse(
downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresInSeconds: null == expiresInSeconds ? _self.expiresInSeconds : expiresInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
