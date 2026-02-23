// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CyclePayoutUserModel {

 String get id; String? get phone; String? get fullName;
/// Create a copy of CyclePayoutUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<CyclePayoutUserModel> get copyWith => _$CyclePayoutUserModelCopyWithImpl<CyclePayoutUserModel>(this as CyclePayoutUserModel, _$identity);

  /// Serializes this CyclePayoutUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CyclePayoutUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,phone,fullName);

@override
String toString() {
  return 'CyclePayoutUserModel(id: $id, phone: $phone, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class $CyclePayoutUserModelCopyWith<$Res>  {
  factory $CyclePayoutUserModelCopyWith(CyclePayoutUserModel value, $Res Function(CyclePayoutUserModel) _then) = _$CyclePayoutUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String? phone, String? fullName
});




}
/// @nodoc
class _$CyclePayoutUserModelCopyWithImpl<$Res>
    implements $CyclePayoutUserModelCopyWith<$Res> {
  _$CyclePayoutUserModelCopyWithImpl(this._self, this._then);

  final CyclePayoutUserModel _self;
  final $Res Function(CyclePayoutUserModel) _then;

/// Create a copy of CyclePayoutUserModel
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


/// Adds pattern-matching-related methods to [CyclePayoutUserModel].
extension CyclePayoutUserModelPatterns on CyclePayoutUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CyclePayoutUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CyclePayoutUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CyclePayoutUserModel value)  $default,){
final _that = this;
switch (_that) {
case _CyclePayoutUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CyclePayoutUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _CyclePayoutUserModel() when $default != null:
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
case _CyclePayoutUserModel() when $default != null:
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
case _CyclePayoutUserModel():
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
case _CyclePayoutUserModel() when $default != null:
return $default(_that.id,_that.phone,_that.fullName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CyclePayoutUserModel implements CyclePayoutUserModel {
  const _CyclePayoutUserModel({required this.id, this.phone, this.fullName});
  factory _CyclePayoutUserModel.fromJson(Map<String, dynamic> json) => _$CyclePayoutUserModelFromJson(json);

@override final  String id;
@override final  String? phone;
@override final  String? fullName;

/// Create a copy of CyclePayoutUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CyclePayoutUserModelCopyWith<_CyclePayoutUserModel> get copyWith => __$CyclePayoutUserModelCopyWithImpl<_CyclePayoutUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CyclePayoutUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CyclePayoutUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,phone,fullName);

@override
String toString() {
  return 'CyclePayoutUserModel(id: $id, phone: $phone, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class _$CyclePayoutUserModelCopyWith<$Res> implements $CyclePayoutUserModelCopyWith<$Res> {
  factory _$CyclePayoutUserModelCopyWith(_CyclePayoutUserModel value, $Res Function(_CyclePayoutUserModel) _then) = __$CyclePayoutUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? phone, String? fullName
});




}
/// @nodoc
class __$CyclePayoutUserModelCopyWithImpl<$Res>
    implements _$CyclePayoutUserModelCopyWith<$Res> {
  __$CyclePayoutUserModelCopyWithImpl(this._self, this._then);

  final _CyclePayoutUserModel _self;
  final $Res Function(_CyclePayoutUserModel) _then;

/// Create a copy of CyclePayoutUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = freezed,Object? fullName = freezed,}) {
  return _then(_CyclePayoutUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CycleModel {

 String get id; String get groupId; String? get roundId;@JsonKey(fromJson: _toInt) int get cycleNo; DateTime get dueDate; DateTime? get dueAt;@JsonKey(unknownEnumValue: CycleStateModel.unknown) CycleStateModel? get state; String? get scheduledPayoutUserId; String? get finalPayoutUserId; String get payoutUserId;@JsonKey(unknownEnumValue: AuctionStatusModel.unknown) AuctionStatusModel? get auctionStatus;@JsonKey(fromJson: _toNullableInt) int? get winningBidAmount; String? get winningBidUserId;@JsonKey(unknownEnumValue: CycleStatusModel.unknown) CycleStatusModel get status; String? get createdByUserId; DateTime? get createdAt; CyclePayoutUserModel? get scheduledPayoutUser; CyclePayoutUserModel? get finalPayoutUser; CyclePayoutUserModel? get winningBidUser; CyclePayoutUserModel? get payoutUser;
/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleModelCopyWith<CycleModel> get copyWith => _$CycleModelCopyWithImpl<CycleModel>(this as CycleModel, _$identity);

  /// Serializes this CycleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.roundId, roundId) || other.roundId == roundId)&&(identical(other.cycleNo, cycleNo) || other.cycleNo == cycleNo)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.scheduledPayoutUserId, scheduledPayoutUserId) || other.scheduledPayoutUserId == scheduledPayoutUserId)&&(identical(other.finalPayoutUserId, finalPayoutUserId) || other.finalPayoutUserId == finalPayoutUserId)&&(identical(other.payoutUserId, payoutUserId) || other.payoutUserId == payoutUserId)&&(identical(other.auctionStatus, auctionStatus) || other.auctionStatus == auctionStatus)&&(identical(other.winningBidAmount, winningBidAmount) || other.winningBidAmount == winningBidAmount)&&(identical(other.winningBidUserId, winningBidUserId) || other.winningBidUserId == winningBidUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scheduledPayoutUser, scheduledPayoutUser) || other.scheduledPayoutUser == scheduledPayoutUser)&&(identical(other.finalPayoutUser, finalPayoutUser) || other.finalPayoutUser == finalPayoutUser)&&(identical(other.winningBidUser, winningBidUser) || other.winningBidUser == winningBidUser)&&(identical(other.payoutUser, payoutUser) || other.payoutUser == payoutUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,groupId,roundId,cycleNo,dueDate,dueAt,state,scheduledPayoutUserId,finalPayoutUserId,payoutUserId,auctionStatus,winningBidAmount,winningBidUserId,status,createdByUserId,createdAt,scheduledPayoutUser,finalPayoutUser,winningBidUser,payoutUser]);

@override
String toString() {
  return 'CycleModel(id: $id, groupId: $groupId, roundId: $roundId, cycleNo: $cycleNo, dueDate: $dueDate, dueAt: $dueAt, state: $state, scheduledPayoutUserId: $scheduledPayoutUserId, finalPayoutUserId: $finalPayoutUserId, payoutUserId: $payoutUserId, auctionStatus: $auctionStatus, winningBidAmount: $winningBidAmount, winningBidUserId: $winningBidUserId, status: $status, createdByUserId: $createdByUserId, createdAt: $createdAt, scheduledPayoutUser: $scheduledPayoutUser, finalPayoutUser: $finalPayoutUser, winningBidUser: $winningBidUser, payoutUser: $payoutUser)';
}


}

/// @nodoc
abstract mixin class $CycleModelCopyWith<$Res>  {
  factory $CycleModelCopyWith(CycleModel value, $Res Function(CycleModel) _then) = _$CycleModelCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String? roundId,@JsonKey(fromJson: _toInt) int cycleNo, DateTime dueDate, DateTime? dueAt,@JsonKey(unknownEnumValue: CycleStateModel.unknown) CycleStateModel? state, String? scheduledPayoutUserId, String? finalPayoutUserId, String payoutUserId,@JsonKey(unknownEnumValue: AuctionStatusModel.unknown) AuctionStatusModel? auctionStatus,@JsonKey(fromJson: _toNullableInt) int? winningBidAmount, String? winningBidUserId,@JsonKey(unknownEnumValue: CycleStatusModel.unknown) CycleStatusModel status, String? createdByUserId, DateTime? createdAt, CyclePayoutUserModel? scheduledPayoutUser, CyclePayoutUserModel? finalPayoutUser, CyclePayoutUserModel? winningBidUser, CyclePayoutUserModel? payoutUser
});


$CyclePayoutUserModelCopyWith<$Res>? get scheduledPayoutUser;$CyclePayoutUserModelCopyWith<$Res>? get finalPayoutUser;$CyclePayoutUserModelCopyWith<$Res>? get winningBidUser;$CyclePayoutUserModelCopyWith<$Res>? get payoutUser;

}
/// @nodoc
class _$CycleModelCopyWithImpl<$Res>
    implements $CycleModelCopyWith<$Res> {
  _$CycleModelCopyWithImpl(this._self, this._then);

  final CycleModel _self;
  final $Res Function(CycleModel) _then;

/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? roundId = freezed,Object? cycleNo = null,Object? dueDate = null,Object? dueAt = freezed,Object? state = freezed,Object? scheduledPayoutUserId = freezed,Object? finalPayoutUserId = freezed,Object? payoutUserId = null,Object? auctionStatus = freezed,Object? winningBidAmount = freezed,Object? winningBidUserId = freezed,Object? status = null,Object? createdByUserId = freezed,Object? createdAt = freezed,Object? scheduledPayoutUser = freezed,Object? finalPayoutUser = freezed,Object? winningBidUser = freezed,Object? payoutUser = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,roundId: freezed == roundId ? _self.roundId : roundId // ignore: cast_nullable_to_non_nullable
as String?,cycleNo: null == cycleNo ? _self.cycleNo : cycleNo // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CycleStateModel?,scheduledPayoutUserId: freezed == scheduledPayoutUserId ? _self.scheduledPayoutUserId : scheduledPayoutUserId // ignore: cast_nullable_to_non_nullable
as String?,finalPayoutUserId: freezed == finalPayoutUserId ? _self.finalPayoutUserId : finalPayoutUserId // ignore: cast_nullable_to_non_nullable
as String?,payoutUserId: null == payoutUserId ? _self.payoutUserId : payoutUserId // ignore: cast_nullable_to_non_nullable
as String,auctionStatus: freezed == auctionStatus ? _self.auctionStatus : auctionStatus // ignore: cast_nullable_to_non_nullable
as AuctionStatusModel?,winningBidAmount: freezed == winningBidAmount ? _self.winningBidAmount : winningBidAmount // ignore: cast_nullable_to_non_nullable
as int?,winningBidUserId: freezed == winningBidUserId ? _self.winningBidUserId : winningBidUserId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CycleStatusModel,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledPayoutUser: freezed == scheduledPayoutUser ? _self.scheduledPayoutUser : scheduledPayoutUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,finalPayoutUser: freezed == finalPayoutUser ? _self.finalPayoutUser : finalPayoutUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,winningBidUser: freezed == winningBidUser ? _self.winningBidUser : winningBidUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,payoutUser: freezed == payoutUser ? _self.payoutUser : payoutUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,
  ));
}
/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get scheduledPayoutUser {
    if (_self.scheduledPayoutUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.scheduledPayoutUser!, (value) {
    return _then(_self.copyWith(scheduledPayoutUser: value));
  });
}/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get finalPayoutUser {
    if (_self.finalPayoutUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.finalPayoutUser!, (value) {
    return _then(_self.copyWith(finalPayoutUser: value));
  });
}/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get winningBidUser {
    if (_self.winningBidUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.winningBidUser!, (value) {
    return _then(_self.copyWith(winningBidUser: value));
  });
}/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get payoutUser {
    if (_self.payoutUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.payoutUser!, (value) {
    return _then(_self.copyWith(payoutUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [CycleModel].
extension CycleModelPatterns on CycleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleModel value)  $default,){
final _that = this;
switch (_that) {
case _CycleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleModel value)?  $default,){
final _that = this;
switch (_that) {
case _CycleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String? roundId, @JsonKey(fromJson: _toInt)  int cycleNo,  DateTime dueDate,  DateTime? dueAt, @JsonKey(unknownEnumValue: CycleStateModel.unknown)  CycleStateModel? state,  String? scheduledPayoutUserId,  String? finalPayoutUserId,  String payoutUserId, @JsonKey(unknownEnumValue: AuctionStatusModel.unknown)  AuctionStatusModel? auctionStatus, @JsonKey(fromJson: _toNullableInt)  int? winningBidAmount,  String? winningBidUserId, @JsonKey(unknownEnumValue: CycleStatusModel.unknown)  CycleStatusModel status,  String? createdByUserId,  DateTime? createdAt,  CyclePayoutUserModel? scheduledPayoutUser,  CyclePayoutUserModel? finalPayoutUser,  CyclePayoutUserModel? winningBidUser,  CyclePayoutUserModel? payoutUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleModel() when $default != null:
return $default(_that.id,_that.groupId,_that.roundId,_that.cycleNo,_that.dueDate,_that.dueAt,_that.state,_that.scheduledPayoutUserId,_that.finalPayoutUserId,_that.payoutUserId,_that.auctionStatus,_that.winningBidAmount,_that.winningBidUserId,_that.status,_that.createdByUserId,_that.createdAt,_that.scheduledPayoutUser,_that.finalPayoutUser,_that.winningBidUser,_that.payoutUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String? roundId, @JsonKey(fromJson: _toInt)  int cycleNo,  DateTime dueDate,  DateTime? dueAt, @JsonKey(unknownEnumValue: CycleStateModel.unknown)  CycleStateModel? state,  String? scheduledPayoutUserId,  String? finalPayoutUserId,  String payoutUserId, @JsonKey(unknownEnumValue: AuctionStatusModel.unknown)  AuctionStatusModel? auctionStatus, @JsonKey(fromJson: _toNullableInt)  int? winningBidAmount,  String? winningBidUserId, @JsonKey(unknownEnumValue: CycleStatusModel.unknown)  CycleStatusModel status,  String? createdByUserId,  DateTime? createdAt,  CyclePayoutUserModel? scheduledPayoutUser,  CyclePayoutUserModel? finalPayoutUser,  CyclePayoutUserModel? winningBidUser,  CyclePayoutUserModel? payoutUser)  $default,) {final _that = this;
switch (_that) {
case _CycleModel():
return $default(_that.id,_that.groupId,_that.roundId,_that.cycleNo,_that.dueDate,_that.dueAt,_that.state,_that.scheduledPayoutUserId,_that.finalPayoutUserId,_that.payoutUserId,_that.auctionStatus,_that.winningBidAmount,_that.winningBidUserId,_that.status,_that.createdByUserId,_that.createdAt,_that.scheduledPayoutUser,_that.finalPayoutUser,_that.winningBidUser,_that.payoutUser);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String? roundId, @JsonKey(fromJson: _toInt)  int cycleNo,  DateTime dueDate,  DateTime? dueAt, @JsonKey(unknownEnumValue: CycleStateModel.unknown)  CycleStateModel? state,  String? scheduledPayoutUserId,  String? finalPayoutUserId,  String payoutUserId, @JsonKey(unknownEnumValue: AuctionStatusModel.unknown)  AuctionStatusModel? auctionStatus, @JsonKey(fromJson: _toNullableInt)  int? winningBidAmount,  String? winningBidUserId, @JsonKey(unknownEnumValue: CycleStatusModel.unknown)  CycleStatusModel status,  String? createdByUserId,  DateTime? createdAt,  CyclePayoutUserModel? scheduledPayoutUser,  CyclePayoutUserModel? finalPayoutUser,  CyclePayoutUserModel? winningBidUser,  CyclePayoutUserModel? payoutUser)?  $default,) {final _that = this;
switch (_that) {
case _CycleModel() when $default != null:
return $default(_that.id,_that.groupId,_that.roundId,_that.cycleNo,_that.dueDate,_that.dueAt,_that.state,_that.scheduledPayoutUserId,_that.finalPayoutUserId,_that.payoutUserId,_that.auctionStatus,_that.winningBidAmount,_that.winningBidUserId,_that.status,_that.createdByUserId,_that.createdAt,_that.scheduledPayoutUser,_that.finalPayoutUser,_that.winningBidUser,_that.payoutUser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CycleModel implements CycleModel {
  const _CycleModel({required this.id, required this.groupId, this.roundId, @JsonKey(fromJson: _toInt) required this.cycleNo, required this.dueDate, this.dueAt, @JsonKey(unknownEnumValue: CycleStateModel.unknown) this.state, this.scheduledPayoutUserId, this.finalPayoutUserId, required this.payoutUserId, @JsonKey(unknownEnumValue: AuctionStatusModel.unknown) this.auctionStatus, @JsonKey(fromJson: _toNullableInt) this.winningBidAmount, this.winningBidUserId, @JsonKey(unknownEnumValue: CycleStatusModel.unknown) required this.status, this.createdByUserId, this.createdAt, this.scheduledPayoutUser, this.finalPayoutUser, this.winningBidUser, this.payoutUser});
  factory _CycleModel.fromJson(Map<String, dynamic> json) => _$CycleModelFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String? roundId;
@override@JsonKey(fromJson: _toInt) final  int cycleNo;
@override final  DateTime dueDate;
@override final  DateTime? dueAt;
@override@JsonKey(unknownEnumValue: CycleStateModel.unknown) final  CycleStateModel? state;
@override final  String? scheduledPayoutUserId;
@override final  String? finalPayoutUserId;
@override final  String payoutUserId;
@override@JsonKey(unknownEnumValue: AuctionStatusModel.unknown) final  AuctionStatusModel? auctionStatus;
@override@JsonKey(fromJson: _toNullableInt) final  int? winningBidAmount;
@override final  String? winningBidUserId;
@override@JsonKey(unknownEnumValue: CycleStatusModel.unknown) final  CycleStatusModel status;
@override final  String? createdByUserId;
@override final  DateTime? createdAt;
@override final  CyclePayoutUserModel? scheduledPayoutUser;
@override final  CyclePayoutUserModel? finalPayoutUser;
@override final  CyclePayoutUserModel? winningBidUser;
@override final  CyclePayoutUserModel? payoutUser;

/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleModelCopyWith<_CycleModel> get copyWith => __$CycleModelCopyWithImpl<_CycleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CycleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.roundId, roundId) || other.roundId == roundId)&&(identical(other.cycleNo, cycleNo) || other.cycleNo == cycleNo)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.scheduledPayoutUserId, scheduledPayoutUserId) || other.scheduledPayoutUserId == scheduledPayoutUserId)&&(identical(other.finalPayoutUserId, finalPayoutUserId) || other.finalPayoutUserId == finalPayoutUserId)&&(identical(other.payoutUserId, payoutUserId) || other.payoutUserId == payoutUserId)&&(identical(other.auctionStatus, auctionStatus) || other.auctionStatus == auctionStatus)&&(identical(other.winningBidAmount, winningBidAmount) || other.winningBidAmount == winningBidAmount)&&(identical(other.winningBidUserId, winningBidUserId) || other.winningBidUserId == winningBidUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scheduledPayoutUser, scheduledPayoutUser) || other.scheduledPayoutUser == scheduledPayoutUser)&&(identical(other.finalPayoutUser, finalPayoutUser) || other.finalPayoutUser == finalPayoutUser)&&(identical(other.winningBidUser, winningBidUser) || other.winningBidUser == winningBidUser)&&(identical(other.payoutUser, payoutUser) || other.payoutUser == payoutUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,groupId,roundId,cycleNo,dueDate,dueAt,state,scheduledPayoutUserId,finalPayoutUserId,payoutUserId,auctionStatus,winningBidAmount,winningBidUserId,status,createdByUserId,createdAt,scheduledPayoutUser,finalPayoutUser,winningBidUser,payoutUser]);

@override
String toString() {
  return 'CycleModel(id: $id, groupId: $groupId, roundId: $roundId, cycleNo: $cycleNo, dueDate: $dueDate, dueAt: $dueAt, state: $state, scheduledPayoutUserId: $scheduledPayoutUserId, finalPayoutUserId: $finalPayoutUserId, payoutUserId: $payoutUserId, auctionStatus: $auctionStatus, winningBidAmount: $winningBidAmount, winningBidUserId: $winningBidUserId, status: $status, createdByUserId: $createdByUserId, createdAt: $createdAt, scheduledPayoutUser: $scheduledPayoutUser, finalPayoutUser: $finalPayoutUser, winningBidUser: $winningBidUser, payoutUser: $payoutUser)';
}


}

/// @nodoc
abstract mixin class _$CycleModelCopyWith<$Res> implements $CycleModelCopyWith<$Res> {
  factory _$CycleModelCopyWith(_CycleModel value, $Res Function(_CycleModel) _then) = __$CycleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String? roundId,@JsonKey(fromJson: _toInt) int cycleNo, DateTime dueDate, DateTime? dueAt,@JsonKey(unknownEnumValue: CycleStateModel.unknown) CycleStateModel? state, String? scheduledPayoutUserId, String? finalPayoutUserId, String payoutUserId,@JsonKey(unknownEnumValue: AuctionStatusModel.unknown) AuctionStatusModel? auctionStatus,@JsonKey(fromJson: _toNullableInt) int? winningBidAmount, String? winningBidUserId,@JsonKey(unknownEnumValue: CycleStatusModel.unknown) CycleStatusModel status, String? createdByUserId, DateTime? createdAt, CyclePayoutUserModel? scheduledPayoutUser, CyclePayoutUserModel? finalPayoutUser, CyclePayoutUserModel? winningBidUser, CyclePayoutUserModel? payoutUser
});


@override $CyclePayoutUserModelCopyWith<$Res>? get scheduledPayoutUser;@override $CyclePayoutUserModelCopyWith<$Res>? get finalPayoutUser;@override $CyclePayoutUserModelCopyWith<$Res>? get winningBidUser;@override $CyclePayoutUserModelCopyWith<$Res>? get payoutUser;

}
/// @nodoc
class __$CycleModelCopyWithImpl<$Res>
    implements _$CycleModelCopyWith<$Res> {
  __$CycleModelCopyWithImpl(this._self, this._then);

  final _CycleModel _self;
  final $Res Function(_CycleModel) _then;

/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? roundId = freezed,Object? cycleNo = null,Object? dueDate = null,Object? dueAt = freezed,Object? state = freezed,Object? scheduledPayoutUserId = freezed,Object? finalPayoutUserId = freezed,Object? payoutUserId = null,Object? auctionStatus = freezed,Object? winningBidAmount = freezed,Object? winningBidUserId = freezed,Object? status = null,Object? createdByUserId = freezed,Object? createdAt = freezed,Object? scheduledPayoutUser = freezed,Object? finalPayoutUser = freezed,Object? winningBidUser = freezed,Object? payoutUser = freezed,}) {
  return _then(_CycleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,roundId: freezed == roundId ? _self.roundId : roundId // ignore: cast_nullable_to_non_nullable
as String?,cycleNo: null == cycleNo ? _self.cycleNo : cycleNo // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CycleStateModel?,scheduledPayoutUserId: freezed == scheduledPayoutUserId ? _self.scheduledPayoutUserId : scheduledPayoutUserId // ignore: cast_nullable_to_non_nullable
as String?,finalPayoutUserId: freezed == finalPayoutUserId ? _self.finalPayoutUserId : finalPayoutUserId // ignore: cast_nullable_to_non_nullable
as String?,payoutUserId: null == payoutUserId ? _self.payoutUserId : payoutUserId // ignore: cast_nullable_to_non_nullable
as String,auctionStatus: freezed == auctionStatus ? _self.auctionStatus : auctionStatus // ignore: cast_nullable_to_non_nullable
as AuctionStatusModel?,winningBidAmount: freezed == winningBidAmount ? _self.winningBidAmount : winningBidAmount // ignore: cast_nullable_to_non_nullable
as int?,winningBidUserId: freezed == winningBidUserId ? _self.winningBidUserId : winningBidUserId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CycleStatusModel,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledPayoutUser: freezed == scheduledPayoutUser ? _self.scheduledPayoutUser : scheduledPayoutUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,finalPayoutUser: freezed == finalPayoutUser ? _self.finalPayoutUser : finalPayoutUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,winningBidUser: freezed == winningBidUser ? _self.winningBidUser : winningBidUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,payoutUser: freezed == payoutUser ? _self.payoutUser : payoutUser // ignore: cast_nullable_to_non_nullable
as CyclePayoutUserModel?,
  ));
}

/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get scheduledPayoutUser {
    if (_self.scheduledPayoutUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.scheduledPayoutUser!, (value) {
    return _then(_self.copyWith(scheduledPayoutUser: value));
  });
}/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get finalPayoutUser {
    if (_self.finalPayoutUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.finalPayoutUser!, (value) {
    return _then(_self.copyWith(finalPayoutUser: value));
  });
}/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get winningBidUser {
    if (_self.winningBidUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.winningBidUser!, (value) {
    return _then(_self.copyWith(winningBidUser: value));
  });
}/// Create a copy of CycleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CyclePayoutUserModelCopyWith<$Res>? get payoutUser {
    if (_self.payoutUser == null) {
    return null;
  }

  return $CyclePayoutUserModelCopyWith<$Res>(_self.payoutUser!, (value) {
    return _then(_self.copyWith(payoutUser: value));
  });
}
}

// dart format on
