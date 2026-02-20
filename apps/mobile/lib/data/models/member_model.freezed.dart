// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberUserModel {

 String get id; String? get phone; String? get fullName;
/// Create a copy of MemberUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberUserModelCopyWith<MemberUserModel> get copyWith => _$MemberUserModelCopyWithImpl<MemberUserModel>(this as MemberUserModel, _$identity);

  /// Serializes this MemberUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,phone,fullName);

@override
String toString() {
  return 'MemberUserModel(id: $id, phone: $phone, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class $MemberUserModelCopyWith<$Res>  {
  factory $MemberUserModelCopyWith(MemberUserModel value, $Res Function(MemberUserModel) _then) = _$MemberUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String? phone, String? fullName
});




}
/// @nodoc
class _$MemberUserModelCopyWithImpl<$Res>
    implements $MemberUserModelCopyWith<$Res> {
  _$MemberUserModelCopyWithImpl(this._self, this._then);

  final MemberUserModel _self;
  final $Res Function(MemberUserModel) _then;

/// Create a copy of MemberUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? phone = freezed,Object? fullName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberUserModel].
extension MemberUserModelPatterns on MemberUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberUserModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? phone,  String? fullName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberUserModel() when $default != null:
return $default(_that.id,_that.phone,_that.fullName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? phone,  String? fullName)  $default,) {final _that = this;
switch (_that) {
case _MemberUserModel():
return $default(_that.id,_that.phone,_that.fullName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? phone,  String? fullName)?  $default,) {final _that = this;
switch (_that) {
case _MemberUserModel() when $default != null:
return $default(_that.id,_that.phone,_that.fullName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberUserModel implements MemberUserModel {
  const _MemberUserModel({required this.id, this.phone, this.fullName});
  factory _MemberUserModel.fromJson(Map<String, dynamic> json) => _$MemberUserModelFromJson(json);

@override final  String id;
@override final  String? phone;
@override final  String? fullName;

/// Create a copy of MemberUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberUserModelCopyWith<_MemberUserModel> get copyWith => __$MemberUserModelCopyWithImpl<_MemberUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,phone,fullName);

@override
String toString() {
  return 'MemberUserModel(id: $id, phone: $phone, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class _$MemberUserModelCopyWith<$Res> implements $MemberUserModelCopyWith<$Res> {
  factory _$MemberUserModelCopyWith(_MemberUserModel value, $Res Function(_MemberUserModel) _then) = __$MemberUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? phone, String? fullName
});




}
/// @nodoc
class __$MemberUserModelCopyWithImpl<$Res>
    implements _$MemberUserModelCopyWith<$Res> {
  __$MemberUserModelCopyWithImpl(this._self, this._then);

  final _MemberUserModel _self;
  final $Res Function(_MemberUserModel) _then;

/// Create a copy of MemberUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = freezed,Object? fullName = freezed,}) {
  return _then(_MemberUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MemberModel {

@JsonKey(readValue: _readUserId) String get userId; String? get groupId; MemberUserModel get user;@JsonKey(unknownEnumValue: MemberRoleModel.unknown) MemberRoleModel get role;@JsonKey(unknownEnumValue: MemberStatusModel.unknown) MemberStatusModel get status;@JsonKey(fromJson: _toNullableInt) int? get payoutPosition; DateTime? get joinedAt;
/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberModelCopyWith<MemberModel> get copyWith => _$MemberModelCopyWithImpl<MemberModel>(this as MemberModel, _$identity);

  /// Serializes this MemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.payoutPosition, payoutPosition) || other.payoutPosition == payoutPosition)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,groupId,user,role,status,payoutPosition,joinedAt);

@override
String toString() {
  return 'MemberModel(userId: $userId, groupId: $groupId, user: $user, role: $role, status: $status, payoutPosition: $payoutPosition, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $MemberModelCopyWith<$Res>  {
  factory $MemberModelCopyWith(MemberModel value, $Res Function(MemberModel) _then) = _$MemberModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readUserId) String userId, String? groupId, MemberUserModel user,@JsonKey(unknownEnumValue: MemberRoleModel.unknown) MemberRoleModel role,@JsonKey(unknownEnumValue: MemberStatusModel.unknown) MemberStatusModel status,@JsonKey(fromJson: _toNullableInt) int? payoutPosition, DateTime? joinedAt
});


$MemberUserModelCopyWith<$Res> get user;

}
/// @nodoc
class _$MemberModelCopyWithImpl<$Res>
    implements $MemberModelCopyWith<$Res> {
  _$MemberModelCopyWithImpl(this._self, this._then);

  final MemberModel _self;
  final $Res Function(MemberModel) _then;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? groupId = freezed,Object? user = null,Object? role = null,Object? status = null,Object? payoutPosition = freezed,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MemberUserModel,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRoleModel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatusModel,payoutPosition: freezed == payoutPosition ? _self.payoutPosition : payoutPosition // ignore: cast_nullable_to_non_nullable
as int?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberUserModelCopyWith<$Res> get user {
  
  return $MemberUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [MemberModel].
extension MemberModelPatterns on MemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUserId)  String userId,  String? groupId,  MemberUserModel user, @JsonKey(unknownEnumValue: MemberRoleModel.unknown)  MemberRoleModel role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown)  MemberStatusModel status, @JsonKey(fromJson: _toNullableInt)  int? payoutPosition,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
return $default(_that.userId,_that.groupId,_that.user,_that.role,_that.status,_that.payoutPosition,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readUserId)  String userId,  String? groupId,  MemberUserModel user, @JsonKey(unknownEnumValue: MemberRoleModel.unknown)  MemberRoleModel role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown)  MemberStatusModel status, @JsonKey(fromJson: _toNullableInt)  int? payoutPosition,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _MemberModel():
return $default(_that.userId,_that.groupId,_that.user,_that.role,_that.status,_that.payoutPosition,_that.joinedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readUserId)  String userId,  String? groupId,  MemberUserModel user, @JsonKey(unknownEnumValue: MemberRoleModel.unknown)  MemberRoleModel role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown)  MemberStatusModel status, @JsonKey(fromJson: _toNullableInt)  int? payoutPosition,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
return $default(_that.userId,_that.groupId,_that.user,_that.role,_that.status,_that.payoutPosition,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberModel extends MemberModel {
  const _MemberModel({@JsonKey(readValue: _readUserId) required this.userId, this.groupId, required this.user, @JsonKey(unknownEnumValue: MemberRoleModel.unknown) required this.role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown) required this.status, @JsonKey(fromJson: _toNullableInt) this.payoutPosition, this.joinedAt}): super._();
  factory _MemberModel.fromJson(Map<String, dynamic> json) => _$MemberModelFromJson(json);

@override@JsonKey(readValue: _readUserId) final  String userId;
@override final  String? groupId;
@override final  MemberUserModel user;
@override@JsonKey(unknownEnumValue: MemberRoleModel.unknown) final  MemberRoleModel role;
@override@JsonKey(unknownEnumValue: MemberStatusModel.unknown) final  MemberStatusModel status;
@override@JsonKey(fromJson: _toNullableInt) final  int? payoutPosition;
@override final  DateTime? joinedAt;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberModelCopyWith<_MemberModel> get copyWith => __$MemberModelCopyWithImpl<_MemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.payoutPosition, payoutPosition) || other.payoutPosition == payoutPosition)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,groupId,user,role,status,payoutPosition,joinedAt);

@override
String toString() {
  return 'MemberModel(userId: $userId, groupId: $groupId, user: $user, role: $role, status: $status, payoutPosition: $payoutPosition, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$MemberModelCopyWith<$Res> implements $MemberModelCopyWith<$Res> {
  factory _$MemberModelCopyWith(_MemberModel value, $Res Function(_MemberModel) _then) = __$MemberModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readUserId) String userId, String? groupId, MemberUserModel user,@JsonKey(unknownEnumValue: MemberRoleModel.unknown) MemberRoleModel role,@JsonKey(unknownEnumValue: MemberStatusModel.unknown) MemberStatusModel status,@JsonKey(fromJson: _toNullableInt) int? payoutPosition, DateTime? joinedAt
});


@override $MemberUserModelCopyWith<$Res> get user;

}
/// @nodoc
class __$MemberModelCopyWithImpl<$Res>
    implements _$MemberModelCopyWith<$Res> {
  __$MemberModelCopyWithImpl(this._self, this._then);

  final _MemberModel _self;
  final $Res Function(_MemberModel) _then;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? groupId = freezed,Object? user = null,Object? role = null,Object? status = null,Object? payoutPosition = freezed,Object? joinedAt = freezed,}) {
  return _then(_MemberModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MemberUserModel,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRoleModel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatusModel,payoutPosition: freezed == payoutPosition ? _self.payoutPosition : payoutPosition // ignore: cast_nullable_to_non_nullable
as int?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberUserModelCopyWith<$Res> get user {
  
  return $MemberUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
