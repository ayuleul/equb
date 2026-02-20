// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InviteModel {

 String get code; String? get joinUrl; DateTime? get expiresAt;@JsonKey(fromJson: _toNullableInt) int? get maxUses;@JsonKey(fromJson: _toNullableInt) int? get usedCount;
/// Create a copy of InviteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteModelCopyWith<InviteModel> get copyWith => _$InviteModelCopyWithImpl<InviteModel>(this as InviteModel, _$identity);

  /// Serializes this InviteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteModel&&(identical(other.code, code) || other.code == code)&&(identical(other.joinUrl, joinUrl) || other.joinUrl == joinUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,joinUrl,expiresAt,maxUses,usedCount);

@override
String toString() {
  return 'InviteModel(code: $code, joinUrl: $joinUrl, expiresAt: $expiresAt, maxUses: $maxUses, usedCount: $usedCount)';
}


}

/// @nodoc
abstract mixin class $InviteModelCopyWith<$Res>  {
  factory $InviteModelCopyWith(InviteModel value, $Res Function(InviteModel) _then) = _$InviteModelCopyWithImpl;
@useResult
$Res call({
 String code, String? joinUrl, DateTime? expiresAt,@JsonKey(fromJson: _toNullableInt) int? maxUses,@JsonKey(fromJson: _toNullableInt) int? usedCount
});




}
/// @nodoc
class _$InviteModelCopyWithImpl<$Res>
    implements $InviteModelCopyWith<$Res> {
  _$InviteModelCopyWithImpl(this._self, this._then);

  final InviteModel _self;
  final $Res Function(InviteModel) _then;

/// Create a copy of InviteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? joinUrl = freezed,Object? expiresAt = freezed,Object? maxUses = freezed,Object? usedCount = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,joinUrl: freezed == joinUrl ? _self.joinUrl : joinUrl // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,usedCount: freezed == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteModel].
extension InviteModelPatterns on InviteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteModel value)  $default,){
final _that = this;
switch (_that) {
case _InviteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteModel value)?  $default,){
final _that = this;
switch (_that) {
case _InviteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String? joinUrl,  DateTime? expiresAt, @JsonKey(fromJson: _toNullableInt)  int? maxUses, @JsonKey(fromJson: _toNullableInt)  int? usedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteModel() when $default != null:
return $default(_that.code,_that.joinUrl,_that.expiresAt,_that.maxUses,_that.usedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String? joinUrl,  DateTime? expiresAt, @JsonKey(fromJson: _toNullableInt)  int? maxUses, @JsonKey(fromJson: _toNullableInt)  int? usedCount)  $default,) {final _that = this;
switch (_that) {
case _InviteModel():
return $default(_that.code,_that.joinUrl,_that.expiresAt,_that.maxUses,_that.usedCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String? joinUrl,  DateTime? expiresAt, @JsonKey(fromJson: _toNullableInt)  int? maxUses, @JsonKey(fromJson: _toNullableInt)  int? usedCount)?  $default,) {final _that = this;
switch (_that) {
case _InviteModel() when $default != null:
return $default(_that.code,_that.joinUrl,_that.expiresAt,_that.maxUses,_that.usedCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteModel implements InviteModel {
  const _InviteModel({required this.code, this.joinUrl, this.expiresAt, @JsonKey(fromJson: _toNullableInt) this.maxUses, @JsonKey(fromJson: _toNullableInt) this.usedCount});
  factory _InviteModel.fromJson(Map<String, dynamic> json) => _$InviteModelFromJson(json);

@override final  String code;
@override final  String? joinUrl;
@override final  DateTime? expiresAt;
@override@JsonKey(fromJson: _toNullableInt) final  int? maxUses;
@override@JsonKey(fromJson: _toNullableInt) final  int? usedCount;

/// Create a copy of InviteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteModelCopyWith<_InviteModel> get copyWith => __$InviteModelCopyWithImpl<_InviteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteModel&&(identical(other.code, code) || other.code == code)&&(identical(other.joinUrl, joinUrl) || other.joinUrl == joinUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,joinUrl,expiresAt,maxUses,usedCount);

@override
String toString() {
  return 'InviteModel(code: $code, joinUrl: $joinUrl, expiresAt: $expiresAt, maxUses: $maxUses, usedCount: $usedCount)';
}


}

/// @nodoc
abstract mixin class _$InviteModelCopyWith<$Res> implements $InviteModelCopyWith<$Res> {
  factory _$InviteModelCopyWith(_InviteModel value, $Res Function(_InviteModel) _then) = __$InviteModelCopyWithImpl;
@override @useResult
$Res call({
 String code, String? joinUrl, DateTime? expiresAt,@JsonKey(fromJson: _toNullableInt) int? maxUses,@JsonKey(fromJson: _toNullableInt) int? usedCount
});




}
/// @nodoc
class __$InviteModelCopyWithImpl<$Res>
    implements _$InviteModelCopyWith<$Res> {
  __$InviteModelCopyWithImpl(this._self, this._then);

  final _InviteModel _self;
  final $Res Function(_InviteModel) _then;

/// Create a copy of InviteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? joinUrl = freezed,Object? expiresAt = freezed,Object? maxUses = freezed,Object? usedCount = freezed,}) {
  return _then(_InviteModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,joinUrl: freezed == joinUrl ? _self.joinUrl : joinUrl // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,usedCount: freezed == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
