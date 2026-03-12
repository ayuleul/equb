// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JoinRequestUserModel {

 String get id; String? get phone; String? get fullName; MemberReputationSummaryModel? get reputation;
/// Create a copy of JoinRequestUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinRequestUserModelCopyWith<JoinRequestUserModel> get copyWith => _$JoinRequestUserModelCopyWithImpl<JoinRequestUserModel>(this as JoinRequestUserModel, _$identity);

  /// Serializes this JoinRequestUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinRequestUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.reputation, reputation) || other.reputation == reputation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,phone,fullName,reputation);

@override
String toString() {
  return 'JoinRequestUserModel(id: $id, phone: $phone, fullName: $fullName, reputation: $reputation)';
}


}

/// @nodoc
abstract mixin class $JoinRequestUserModelCopyWith<$Res>  {
  factory $JoinRequestUserModelCopyWith(JoinRequestUserModel value, $Res Function(JoinRequestUserModel) _then) = _$JoinRequestUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String? phone, String? fullName, MemberReputationSummaryModel? reputation
});


$MemberReputationSummaryModelCopyWith<$Res>? get reputation;

}
/// @nodoc
class _$JoinRequestUserModelCopyWithImpl<$Res>
    implements $JoinRequestUserModelCopyWith<$Res> {
  _$JoinRequestUserModelCopyWithImpl(this._self, this._then);

  final JoinRequestUserModel _self;
  final $Res Function(JoinRequestUserModel) _then;

/// Create a copy of JoinRequestUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? phone = freezed,Object? fullName = freezed,Object? reputation = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,reputation: freezed == reputation ? _self.reputation : reputation // ignore: cast_nullable_to_non_nullable
as MemberReputationSummaryModel?,
  ));
}
/// Create a copy of JoinRequestUserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberReputationSummaryModelCopyWith<$Res>? get reputation {
    if (_self.reputation == null) {
    return null;
  }

  return $MemberReputationSummaryModelCopyWith<$Res>(_self.reputation!, (value) {
    return _then(_self.copyWith(reputation: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinRequestUserModel].
extension JoinRequestUserModelPatterns on JoinRequestUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinRequestUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinRequestUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinRequestUserModel value)  $default,){
final _that = this;
switch (_that) {
case _JoinRequestUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinRequestUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _JoinRequestUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? phone,  String? fullName,  MemberReputationSummaryModel? reputation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinRequestUserModel() when $default != null:
return $default(_that.id,_that.phone,_that.fullName,_that.reputation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? phone,  String? fullName,  MemberReputationSummaryModel? reputation)  $default,) {final _that = this;
switch (_that) {
case _JoinRequestUserModel():
return $default(_that.id,_that.phone,_that.fullName,_that.reputation);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? phone,  String? fullName,  MemberReputationSummaryModel? reputation)?  $default,) {final _that = this;
switch (_that) {
case _JoinRequestUserModel() when $default != null:
return $default(_that.id,_that.phone,_that.fullName,_that.reputation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinRequestUserModel implements JoinRequestUserModel {
  const _JoinRequestUserModel({required this.id, this.phone, this.fullName, this.reputation});
  factory _JoinRequestUserModel.fromJson(Map<String, dynamic> json) => _$JoinRequestUserModelFromJson(json);

@override final  String id;
@override final  String? phone;
@override final  String? fullName;
@override final  MemberReputationSummaryModel? reputation;

/// Create a copy of JoinRequestUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinRequestUserModelCopyWith<_JoinRequestUserModel> get copyWith => __$JoinRequestUserModelCopyWithImpl<_JoinRequestUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinRequestUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinRequestUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.reputation, reputation) || other.reputation == reputation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,phone,fullName,reputation);

@override
String toString() {
  return 'JoinRequestUserModel(id: $id, phone: $phone, fullName: $fullName, reputation: $reputation)';
}


}

/// @nodoc
abstract mixin class _$JoinRequestUserModelCopyWith<$Res> implements $JoinRequestUserModelCopyWith<$Res> {
  factory _$JoinRequestUserModelCopyWith(_JoinRequestUserModel value, $Res Function(_JoinRequestUserModel) _then) = __$JoinRequestUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? phone, String? fullName, MemberReputationSummaryModel? reputation
});


@override $MemberReputationSummaryModelCopyWith<$Res>? get reputation;

}
/// @nodoc
class __$JoinRequestUserModelCopyWithImpl<$Res>
    implements _$JoinRequestUserModelCopyWith<$Res> {
  __$JoinRequestUserModelCopyWithImpl(this._self, this._then);

  final _JoinRequestUserModel _self;
  final $Res Function(_JoinRequestUserModel) _then;

/// Create a copy of JoinRequestUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = freezed,Object? fullName = freezed,Object? reputation = freezed,}) {
  return _then(_JoinRequestUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,reputation: freezed == reputation ? _self.reputation : reputation // ignore: cast_nullable_to_non_nullable
as MemberReputationSummaryModel?,
  ));
}

/// Create a copy of JoinRequestUserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberReputationSummaryModelCopyWith<$Res>? get reputation {
    if (_self.reputation == null) {
    return null;
  }

  return $MemberReputationSummaryModelCopyWith<$Res>(_self.reputation!, (value) {
    return _then(_self.copyWith(reputation: value));
  });
}
}


/// @nodoc
mixin _$JoinRequestModel {

 String get id; String get groupId; String get userId;@JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown) JoinRequestStatusModel get status; String? get message; DateTime get createdAt; DateTime? get reviewedAt; String? get reviewedByUserId; DateTime? get retryAvailableAt; JoinRequestUserModel? get user;
/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinRequestModelCopyWith<JoinRequestModel> get copyWith => _$JoinRequestModelCopyWithImpl<JoinRequestModel>(this as JoinRequestModel, _$identity);

  /// Serializes this JoinRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByUserId, reviewedByUserId) || other.reviewedByUserId == reviewedByUserId)&&(identical(other.retryAvailableAt, retryAvailableAt) || other.retryAvailableAt == retryAvailableAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,userId,status,message,createdAt,reviewedAt,reviewedByUserId,retryAvailableAt,user);

@override
String toString() {
  return 'JoinRequestModel(id: $id, groupId: $groupId, userId: $userId, status: $status, message: $message, createdAt: $createdAt, reviewedAt: $reviewedAt, reviewedByUserId: $reviewedByUserId, retryAvailableAt: $retryAvailableAt, user: $user)';
}


}

/// @nodoc
abstract mixin class $JoinRequestModelCopyWith<$Res>  {
  factory $JoinRequestModelCopyWith(JoinRequestModel value, $Res Function(JoinRequestModel) _then) = _$JoinRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String userId,@JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown) JoinRequestStatusModel status, String? message, DateTime createdAt, DateTime? reviewedAt, String? reviewedByUserId, DateTime? retryAvailableAt, JoinRequestUserModel? user
});


$JoinRequestUserModelCopyWith<$Res>? get user;

}
/// @nodoc
class _$JoinRequestModelCopyWithImpl<$Res>
    implements $JoinRequestModelCopyWith<$Res> {
  _$JoinRequestModelCopyWithImpl(this._self, this._then);

  final JoinRequestModel _self;
  final $Res Function(JoinRequestModel) _then;

/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? userId = null,Object? status = null,Object? message = freezed,Object? createdAt = null,Object? reviewedAt = freezed,Object? reviewedByUserId = freezed,Object? retryAvailableAt = freezed,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JoinRequestStatusModel,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByUserId: freezed == reviewedByUserId ? _self.reviewedByUserId : reviewedByUserId // ignore: cast_nullable_to_non_nullable
as String?,retryAvailableAt: freezed == retryAvailableAt ? _self.retryAvailableAt : retryAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as JoinRequestUserModel?,
  ));
}
/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JoinRequestUserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $JoinRequestUserModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinRequestModel].
extension JoinRequestModelPatterns on JoinRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _JoinRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String userId, @JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown)  JoinRequestStatusModel status,  String? message,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByUserId,  DateTime? retryAvailableAt,  JoinRequestUserModel? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
return $default(_that.id,_that.groupId,_that.userId,_that.status,_that.message,_that.createdAt,_that.reviewedAt,_that.reviewedByUserId,_that.retryAvailableAt,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String userId, @JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown)  JoinRequestStatusModel status,  String? message,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByUserId,  DateTime? retryAvailableAt,  JoinRequestUserModel? user)  $default,) {final _that = this;
switch (_that) {
case _JoinRequestModel():
return $default(_that.id,_that.groupId,_that.userId,_that.status,_that.message,_that.createdAt,_that.reviewedAt,_that.reviewedByUserId,_that.retryAvailableAt,_that.user);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String userId, @JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown)  JoinRequestStatusModel status,  String? message,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByUserId,  DateTime? retryAvailableAt,  JoinRequestUserModel? user)?  $default,) {final _that = this;
switch (_that) {
case _JoinRequestModel() when $default != null:
return $default(_that.id,_that.groupId,_that.userId,_that.status,_that.message,_that.createdAt,_that.reviewedAt,_that.reviewedByUserId,_that.retryAvailableAt,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinRequestModel extends JoinRequestModel {
  const _JoinRequestModel({required this.id, required this.groupId, required this.userId, @JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown) required this.status, this.message, required this.createdAt, this.reviewedAt, this.reviewedByUserId, this.retryAvailableAt, this.user}): super._();
  factory _JoinRequestModel.fromJson(Map<String, dynamic> json) => _$JoinRequestModelFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String userId;
@override@JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown) final  JoinRequestStatusModel status;
@override final  String? message;
@override final  DateTime createdAt;
@override final  DateTime? reviewedAt;
@override final  String? reviewedByUserId;
@override final  DateTime? retryAvailableAt;
@override final  JoinRequestUserModel? user;

/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinRequestModelCopyWith<_JoinRequestModel> get copyWith => __$JoinRequestModelCopyWithImpl<_JoinRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByUserId, reviewedByUserId) || other.reviewedByUserId == reviewedByUserId)&&(identical(other.retryAvailableAt, retryAvailableAt) || other.retryAvailableAt == retryAvailableAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,userId,status,message,createdAt,reviewedAt,reviewedByUserId,retryAvailableAt,user);

@override
String toString() {
  return 'JoinRequestModel(id: $id, groupId: $groupId, userId: $userId, status: $status, message: $message, createdAt: $createdAt, reviewedAt: $reviewedAt, reviewedByUserId: $reviewedByUserId, retryAvailableAt: $retryAvailableAt, user: $user)';
}


}

/// @nodoc
abstract mixin class _$JoinRequestModelCopyWith<$Res> implements $JoinRequestModelCopyWith<$Res> {
  factory _$JoinRequestModelCopyWith(_JoinRequestModel value, $Res Function(_JoinRequestModel) _then) = __$JoinRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String userId,@JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown) JoinRequestStatusModel status, String? message, DateTime createdAt, DateTime? reviewedAt, String? reviewedByUserId, DateTime? retryAvailableAt, JoinRequestUserModel? user
});


@override $JoinRequestUserModelCopyWith<$Res>? get user;

}
/// @nodoc
class __$JoinRequestModelCopyWithImpl<$Res>
    implements _$JoinRequestModelCopyWith<$Res> {
  __$JoinRequestModelCopyWithImpl(this._self, this._then);

  final _JoinRequestModel _self;
  final $Res Function(_JoinRequestModel) _then;

/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? userId = null,Object? status = null,Object? message = freezed,Object? createdAt = null,Object? reviewedAt = freezed,Object? reviewedByUserId = freezed,Object? retryAvailableAt = freezed,Object? user = freezed,}) {
  return _then(_JoinRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JoinRequestStatusModel,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByUserId: freezed == reviewedByUserId ? _self.reviewedByUserId : reviewedByUserId // ignore: cast_nullable_to_non_nullable
as String?,retryAvailableAt: freezed == retryAvailableAt ? _self.retryAvailableAt : retryAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as JoinRequestUserModel?,
  ));
}

/// Create a copy of JoinRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JoinRequestUserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $JoinRequestUserModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
