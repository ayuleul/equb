// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribution_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContributionUserModel {

 String get id; String? get fullName; String? get phone;
/// Create a copy of ContributionUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionUserModelCopyWith<ContributionUserModel> get copyWith => _$ContributionUserModelCopyWithImpl<ContributionUserModel>(this as ContributionUserModel, _$identity);

  /// Serializes this ContributionUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone);

@override
String toString() {
  return 'ContributionUserModel(id: $id, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $ContributionUserModelCopyWith<$Res>  {
  factory $ContributionUserModelCopyWith(ContributionUserModel value, $Res Function(ContributionUserModel) _then) = _$ContributionUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String? fullName, String? phone
});




}
/// @nodoc
class _$ContributionUserModelCopyWithImpl<$Res>
    implements $ContributionUserModelCopyWith<$Res> {
  _$ContributionUserModelCopyWithImpl(this._self, this._then);

  final ContributionUserModel _self;
  final $Res Function(ContributionUserModel) _then;

/// Create a copy of ContributionUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = freezed,Object? phone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributionUserModel].
extension ContributionUserModelPatterns on ContributionUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionUserModel value)  $default,){
final _that = this;
switch (_that) {
case _ContributionUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? fullName,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionUserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? fullName,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _ContributionUserModel():
return $default(_that.id,_that.fullName,_that.phone);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? fullName,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _ContributionUserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionUserModel implements ContributionUserModel {
  const _ContributionUserModel({required this.id, this.fullName, this.phone});
  factory _ContributionUserModel.fromJson(Map<String, dynamic> json) => _$ContributionUserModelFromJson(json);

@override final  String id;
@override final  String? fullName;
@override final  String? phone;

/// Create a copy of ContributionUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionUserModelCopyWith<_ContributionUserModel> get copyWith => __$ContributionUserModelCopyWithImpl<_ContributionUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone);

@override
String toString() {
  return 'ContributionUserModel(id: $id, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$ContributionUserModelCopyWith<$Res> implements $ContributionUserModelCopyWith<$Res> {
  factory _$ContributionUserModelCopyWith(_ContributionUserModel value, $Res Function(_ContributionUserModel) _then) = __$ContributionUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? fullName, String? phone
});




}
/// @nodoc
class __$ContributionUserModelCopyWithImpl<$Res>
    implements _$ContributionUserModelCopyWith<$Res> {
  __$ContributionUserModelCopyWithImpl(this._self, this._then);

  final _ContributionUserModel _self;
  final $Res Function(_ContributionUserModel) _then;

/// Create a copy of ContributionUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = freezed,Object? phone = freezed,}) {
  return _then(_ContributionUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContributionModel {

 String get id; String get groupId; String get cycleId; String get userId;@JsonKey(fromJson: _toInt) int get amount;@JsonKey(unknownEnumValue: ContributionStatusModel.unknown) ContributionStatusModel get status;@JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown) GroupPaymentMethodModel? get paymentMethod; String? get proofFileKey; String? get paymentRef; String? get note; DateTime? get submittedAt; DateTime? get confirmedAt; DateTime? get rejectedAt; String? get rejectReason; DateTime? get lateMarkedAt; DateTime? get createdAt; ContributionUserModel get user;
/// Create a copy of ContributionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionModelCopyWith<ContributionModel> get copyWith => _$ContributionModelCopyWithImpl<ContributionModel>(this as ContributionModel, _$identity);

  /// Serializes this ContributionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.rejectedAt, rejectedAt) || other.rejectedAt == rejectedAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.lateMarkedAt, lateMarkedAt) || other.lateMarkedAt == lateMarkedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,cycleId,userId,amount,status,paymentMethod,proofFileKey,paymentRef,note,submittedAt,confirmedAt,rejectedAt,rejectReason,lateMarkedAt,createdAt,user);

@override
String toString() {
  return 'ContributionModel(id: $id, groupId: $groupId, cycleId: $cycleId, userId: $userId, amount: $amount, status: $status, paymentMethod: $paymentMethod, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note, submittedAt: $submittedAt, confirmedAt: $confirmedAt, rejectedAt: $rejectedAt, rejectReason: $rejectReason, lateMarkedAt: $lateMarkedAt, createdAt: $createdAt, user: $user)';
}


}

/// @nodoc
abstract mixin class $ContributionModelCopyWith<$Res>  {
  factory $ContributionModelCopyWith(ContributionModel value, $Res Function(ContributionModel) _then) = _$ContributionModelCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String cycleId, String userId,@JsonKey(fromJson: _toInt) int amount,@JsonKey(unknownEnumValue: ContributionStatusModel.unknown) ContributionStatusModel status,@JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown) GroupPaymentMethodModel? paymentMethod, String? proofFileKey, String? paymentRef, String? note, DateTime? submittedAt, DateTime? confirmedAt, DateTime? rejectedAt, String? rejectReason, DateTime? lateMarkedAt, DateTime? createdAt, ContributionUserModel user
});


$ContributionUserModelCopyWith<$Res> get user;

}
/// @nodoc
class _$ContributionModelCopyWithImpl<$Res>
    implements $ContributionModelCopyWith<$Res> {
  _$ContributionModelCopyWithImpl(this._self, this._then);

  final ContributionModel _self;
  final $Res Function(ContributionModel) _then;

/// Create a copy of ContributionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? cycleId = null,Object? userId = null,Object? amount = null,Object? status = null,Object? paymentMethod = freezed,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,Object? submittedAt = freezed,Object? confirmedAt = freezed,Object? rejectedAt = freezed,Object? rejectReason = freezed,Object? lateMarkedAt = freezed,Object? createdAt = freezed,Object? user = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionStatusModel,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as GroupPaymentMethodModel?,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,lateMarkedAt: freezed == lateMarkedAt ? _self.lateMarkedAt : lateMarkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ContributionUserModel,
  ));
}
/// Create a copy of ContributionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContributionUserModelCopyWith<$Res> get user {
  
  return $ContributionUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContributionModel].
extension ContributionModelPatterns on ContributionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionModel value)  $default,){
final _that = this;
switch (_that) {
case _ContributionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String cycleId,  String userId, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(unknownEnumValue: ContributionStatusModel.unknown)  ContributionStatusModel status, @JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown)  GroupPaymentMethodModel? paymentMethod,  String? proofFileKey,  String? paymentRef,  String? note,  DateTime? submittedAt,  DateTime? confirmedAt,  DateTime? rejectedAt,  String? rejectReason,  DateTime? lateMarkedAt,  DateTime? createdAt,  ContributionUserModel user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionModel() when $default != null:
return $default(_that.id,_that.groupId,_that.cycleId,_that.userId,_that.amount,_that.status,_that.paymentMethod,_that.proofFileKey,_that.paymentRef,_that.note,_that.submittedAt,_that.confirmedAt,_that.rejectedAt,_that.rejectReason,_that.lateMarkedAt,_that.createdAt,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String cycleId,  String userId, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(unknownEnumValue: ContributionStatusModel.unknown)  ContributionStatusModel status, @JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown)  GroupPaymentMethodModel? paymentMethod,  String? proofFileKey,  String? paymentRef,  String? note,  DateTime? submittedAt,  DateTime? confirmedAt,  DateTime? rejectedAt,  String? rejectReason,  DateTime? lateMarkedAt,  DateTime? createdAt,  ContributionUserModel user)  $default,) {final _that = this;
switch (_that) {
case _ContributionModel():
return $default(_that.id,_that.groupId,_that.cycleId,_that.userId,_that.amount,_that.status,_that.paymentMethod,_that.proofFileKey,_that.paymentRef,_that.note,_that.submittedAt,_that.confirmedAt,_that.rejectedAt,_that.rejectReason,_that.lateMarkedAt,_that.createdAt,_that.user);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String cycleId,  String userId, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(unknownEnumValue: ContributionStatusModel.unknown)  ContributionStatusModel status, @JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown)  GroupPaymentMethodModel? paymentMethod,  String? proofFileKey,  String? paymentRef,  String? note,  DateTime? submittedAt,  DateTime? confirmedAt,  DateTime? rejectedAt,  String? rejectReason,  DateTime? lateMarkedAt,  DateTime? createdAt,  ContributionUserModel user)?  $default,) {final _that = this;
switch (_that) {
case _ContributionModel() when $default != null:
return $default(_that.id,_that.groupId,_that.cycleId,_that.userId,_that.amount,_that.status,_that.paymentMethod,_that.proofFileKey,_that.paymentRef,_that.note,_that.submittedAt,_that.confirmedAt,_that.rejectedAt,_that.rejectReason,_that.lateMarkedAt,_that.createdAt,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionModel extends ContributionModel {
  const _ContributionModel({required this.id, required this.groupId, required this.cycleId, required this.userId, @JsonKey(fromJson: _toInt) required this.amount, @JsonKey(unknownEnumValue: ContributionStatusModel.unknown) required this.status, @JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown) this.paymentMethod, this.proofFileKey, this.paymentRef, this.note, this.submittedAt, this.confirmedAt, this.rejectedAt, this.rejectReason, this.lateMarkedAt, this.createdAt, required this.user}): super._();
  factory _ContributionModel.fromJson(Map<String, dynamic> json) => _$ContributionModelFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String cycleId;
@override final  String userId;
@override@JsonKey(fromJson: _toInt) final  int amount;
@override@JsonKey(unknownEnumValue: ContributionStatusModel.unknown) final  ContributionStatusModel status;
@override@JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown) final  GroupPaymentMethodModel? paymentMethod;
@override final  String? proofFileKey;
@override final  String? paymentRef;
@override final  String? note;
@override final  DateTime? submittedAt;
@override final  DateTime? confirmedAt;
@override final  DateTime? rejectedAt;
@override final  String? rejectReason;
@override final  DateTime? lateMarkedAt;
@override final  DateTime? createdAt;
@override final  ContributionUserModel user;

/// Create a copy of ContributionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionModelCopyWith<_ContributionModel> get copyWith => __$ContributionModelCopyWithImpl<_ContributionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.rejectedAt, rejectedAt) || other.rejectedAt == rejectedAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.lateMarkedAt, lateMarkedAt) || other.lateMarkedAt == lateMarkedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,cycleId,userId,amount,status,paymentMethod,proofFileKey,paymentRef,note,submittedAt,confirmedAt,rejectedAt,rejectReason,lateMarkedAt,createdAt,user);

@override
String toString() {
  return 'ContributionModel(id: $id, groupId: $groupId, cycleId: $cycleId, userId: $userId, amount: $amount, status: $status, paymentMethod: $paymentMethod, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note, submittedAt: $submittedAt, confirmedAt: $confirmedAt, rejectedAt: $rejectedAt, rejectReason: $rejectReason, lateMarkedAt: $lateMarkedAt, createdAt: $createdAt, user: $user)';
}


}

/// @nodoc
abstract mixin class _$ContributionModelCopyWith<$Res> implements $ContributionModelCopyWith<$Res> {
  factory _$ContributionModelCopyWith(_ContributionModel value, $Res Function(_ContributionModel) _then) = __$ContributionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String cycleId, String userId,@JsonKey(fromJson: _toInt) int amount,@JsonKey(unknownEnumValue: ContributionStatusModel.unknown) ContributionStatusModel status,@JsonKey(unknownEnumValue: GroupPaymentMethodModel.unknown) GroupPaymentMethodModel? paymentMethod, String? proofFileKey, String? paymentRef, String? note, DateTime? submittedAt, DateTime? confirmedAt, DateTime? rejectedAt, String? rejectReason, DateTime? lateMarkedAt, DateTime? createdAt, ContributionUserModel user
});


@override $ContributionUserModelCopyWith<$Res> get user;

}
/// @nodoc
class __$ContributionModelCopyWithImpl<$Res>
    implements _$ContributionModelCopyWith<$Res> {
  __$ContributionModelCopyWithImpl(this._self, this._then);

  final _ContributionModel _self;
  final $Res Function(_ContributionModel) _then;

/// Create a copy of ContributionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? cycleId = null,Object? userId = null,Object? amount = null,Object? status = null,Object? paymentMethod = freezed,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,Object? submittedAt = freezed,Object? confirmedAt = freezed,Object? rejectedAt = freezed,Object? rejectReason = freezed,Object? lateMarkedAt = freezed,Object? createdAt = freezed,Object? user = null,}) {
  return _then(_ContributionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionStatusModel,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as GroupPaymentMethodModel?,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,lateMarkedAt: freezed == lateMarkedAt ? _self.lateMarkedAt : lateMarkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ContributionUserModel,
  ));
}

/// Create a copy of ContributionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContributionUserModelCopyWith<$Res> get user {
  
  return $ContributionUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$ContributionSummaryModel {

@JsonKey(fromJson: _toInt) int get total;@JsonKey(fromJson: _toInt) int get pending;@JsonKey(fromJson: _toInt) int get submitted;@JsonKey(fromJson: _toInt) int get confirmed;@JsonKey(fromJson: _toInt) int get rejected;@JsonKey(fromJson: _toInt) int get paidSubmitted;@JsonKey(fromJson: _toInt) int get verified;@JsonKey(fromJson: _toInt) int get late;
/// Create a copy of ContributionSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionSummaryModelCopyWith<ContributionSummaryModel> get copyWith => _$ContributionSummaryModelCopyWithImpl<ContributionSummaryModel>(this as ContributionSummaryModel, _$identity);

  /// Serializes this ContributionSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionSummaryModel&&(identical(other.total, total) || other.total == total)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.submitted, submitted) || other.submitted == submitted)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.paidSubmitted, paidSubmitted) || other.paidSubmitted == paidSubmitted)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.late, late) || other.late == late));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,pending,submitted,confirmed,rejected,paidSubmitted,verified,late);

@override
String toString() {
  return 'ContributionSummaryModel(total: $total, pending: $pending, submitted: $submitted, confirmed: $confirmed, rejected: $rejected, paidSubmitted: $paidSubmitted, verified: $verified, late: $late)';
}


}

/// @nodoc
abstract mixin class $ContributionSummaryModelCopyWith<$Res>  {
  factory $ContributionSummaryModelCopyWith(ContributionSummaryModel value, $Res Function(ContributionSummaryModel) _then) = _$ContributionSummaryModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int total,@JsonKey(fromJson: _toInt) int pending,@JsonKey(fromJson: _toInt) int submitted,@JsonKey(fromJson: _toInt) int confirmed,@JsonKey(fromJson: _toInt) int rejected,@JsonKey(fromJson: _toInt) int paidSubmitted,@JsonKey(fromJson: _toInt) int verified,@JsonKey(fromJson: _toInt) int late
});




}
/// @nodoc
class _$ContributionSummaryModelCopyWithImpl<$Res>
    implements $ContributionSummaryModelCopyWith<$Res> {
  _$ContributionSummaryModelCopyWithImpl(this._self, this._then);

  final ContributionSummaryModel _self;
  final $Res Function(ContributionSummaryModel) _then;

/// Create a copy of ContributionSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? pending = null,Object? submitted = null,Object? confirmed = null,Object? rejected = null,Object? paidSubmitted = null,Object? verified = null,Object? late = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,paidSubmitted: null == paidSubmitted ? _self.paidSubmitted : paidSubmitted // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,late: null == late ? _self.late : late // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributionSummaryModel].
extension ContributionSummaryModelPatterns on ContributionSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _ContributionSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int pending, @JsonKey(fromJson: _toInt)  int submitted, @JsonKey(fromJson: _toInt)  int confirmed, @JsonKey(fromJson: _toInt)  int rejected, @JsonKey(fromJson: _toInt)  int paidSubmitted, @JsonKey(fromJson: _toInt)  int verified, @JsonKey(fromJson: _toInt)  int late)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionSummaryModel() when $default != null:
return $default(_that.total,_that.pending,_that.submitted,_that.confirmed,_that.rejected,_that.paidSubmitted,_that.verified,_that.late);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int pending, @JsonKey(fromJson: _toInt)  int submitted, @JsonKey(fromJson: _toInt)  int confirmed, @JsonKey(fromJson: _toInt)  int rejected, @JsonKey(fromJson: _toInt)  int paidSubmitted, @JsonKey(fromJson: _toInt)  int verified, @JsonKey(fromJson: _toInt)  int late)  $default,) {final _that = this;
switch (_that) {
case _ContributionSummaryModel():
return $default(_that.total,_that.pending,_that.submitted,_that.confirmed,_that.rejected,_that.paidSubmitted,_that.verified,_that.late);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int pending, @JsonKey(fromJson: _toInt)  int submitted, @JsonKey(fromJson: _toInt)  int confirmed, @JsonKey(fromJson: _toInt)  int rejected, @JsonKey(fromJson: _toInt)  int paidSubmitted, @JsonKey(fromJson: _toInt)  int verified, @JsonKey(fromJson: _toInt)  int late)?  $default,) {final _that = this;
switch (_that) {
case _ContributionSummaryModel() when $default != null:
return $default(_that.total,_that.pending,_that.submitted,_that.confirmed,_that.rejected,_that.paidSubmitted,_that.verified,_that.late);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionSummaryModel implements ContributionSummaryModel {
  const _ContributionSummaryModel({@JsonKey(fromJson: _toInt) this.total = 0, @JsonKey(fromJson: _toInt) this.pending = 0, @JsonKey(fromJson: _toInt) this.submitted = 0, @JsonKey(fromJson: _toInt) this.confirmed = 0, @JsonKey(fromJson: _toInt) this.rejected = 0, @JsonKey(fromJson: _toInt) this.paidSubmitted = 0, @JsonKey(fromJson: _toInt) this.verified = 0, @JsonKey(fromJson: _toInt) this.late = 0});
  factory _ContributionSummaryModel.fromJson(Map<String, dynamic> json) => _$ContributionSummaryModelFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int total;
@override@JsonKey(fromJson: _toInt) final  int pending;
@override@JsonKey(fromJson: _toInt) final  int submitted;
@override@JsonKey(fromJson: _toInt) final  int confirmed;
@override@JsonKey(fromJson: _toInt) final  int rejected;
@override@JsonKey(fromJson: _toInt) final  int paidSubmitted;
@override@JsonKey(fromJson: _toInt) final  int verified;
@override@JsonKey(fromJson: _toInt) final  int late;

/// Create a copy of ContributionSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionSummaryModelCopyWith<_ContributionSummaryModel> get copyWith => __$ContributionSummaryModelCopyWithImpl<_ContributionSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionSummaryModel&&(identical(other.total, total) || other.total == total)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.submitted, submitted) || other.submitted == submitted)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.paidSubmitted, paidSubmitted) || other.paidSubmitted == paidSubmitted)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.late, late) || other.late == late));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,pending,submitted,confirmed,rejected,paidSubmitted,verified,late);

@override
String toString() {
  return 'ContributionSummaryModel(total: $total, pending: $pending, submitted: $submitted, confirmed: $confirmed, rejected: $rejected, paidSubmitted: $paidSubmitted, verified: $verified, late: $late)';
}


}

/// @nodoc
abstract mixin class _$ContributionSummaryModelCopyWith<$Res> implements $ContributionSummaryModelCopyWith<$Res> {
  factory _$ContributionSummaryModelCopyWith(_ContributionSummaryModel value, $Res Function(_ContributionSummaryModel) _then) = __$ContributionSummaryModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int total,@JsonKey(fromJson: _toInt) int pending,@JsonKey(fromJson: _toInt) int submitted,@JsonKey(fromJson: _toInt) int confirmed,@JsonKey(fromJson: _toInt) int rejected,@JsonKey(fromJson: _toInt) int paidSubmitted,@JsonKey(fromJson: _toInt) int verified,@JsonKey(fromJson: _toInt) int late
});




}
/// @nodoc
class __$ContributionSummaryModelCopyWithImpl<$Res>
    implements _$ContributionSummaryModelCopyWith<$Res> {
  __$ContributionSummaryModelCopyWithImpl(this._self, this._then);

  final _ContributionSummaryModel _self;
  final $Res Function(_ContributionSummaryModel) _then;

/// Create a copy of ContributionSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? pending = null,Object? submitted = null,Object? confirmed = null,Object? rejected = null,Object? paidSubmitted = null,Object? verified = null,Object? late = null,}) {
  return _then(_ContributionSummaryModel(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,paidSubmitted: null == paidSubmitted ? _self.paidSubmitted : paidSubmitted // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,late: null == late ? _self.late : late // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ContributionListModel {

 List<ContributionModel> get items; ContributionSummaryModel get summary;
/// Create a copy of ContributionListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionListModelCopyWith<ContributionListModel> get copyWith => _$ContributionListModelCopyWithImpl<ContributionListModel>(this as ContributionListModel, _$identity);

  /// Serializes this ContributionListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionListModel&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),summary);

@override
String toString() {
  return 'ContributionListModel(items: $items, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $ContributionListModelCopyWith<$Res>  {
  factory $ContributionListModelCopyWith(ContributionListModel value, $Res Function(ContributionListModel) _then) = _$ContributionListModelCopyWithImpl;
@useResult
$Res call({
 List<ContributionModel> items, ContributionSummaryModel summary
});


$ContributionSummaryModelCopyWith<$Res> get summary;

}
/// @nodoc
class _$ContributionListModelCopyWithImpl<$Res>
    implements $ContributionListModelCopyWith<$Res> {
  _$ContributionListModelCopyWithImpl(this._self, this._then);

  final ContributionListModel _self;
  final $Res Function(ContributionListModel) _then;

/// Create a copy of ContributionListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? summary = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ContributionModel>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ContributionSummaryModel,
  ));
}
/// Create a copy of ContributionListModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContributionSummaryModelCopyWith<$Res> get summary {
  
  return $ContributionSummaryModelCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContributionListModel].
extension ContributionListModelPatterns on ContributionListModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionListModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionListModel value)  $default,){
final _that = this;
switch (_that) {
case _ContributionListModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionListModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionListModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ContributionModel> items,  ContributionSummaryModel summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionListModel() when $default != null:
return $default(_that.items,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ContributionModel> items,  ContributionSummaryModel summary)  $default,) {final _that = this;
switch (_that) {
case _ContributionListModel():
return $default(_that.items,_that.summary);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ContributionModel> items,  ContributionSummaryModel summary)?  $default,) {final _that = this;
switch (_that) {
case _ContributionListModel() when $default != null:
return $default(_that.items,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionListModel implements ContributionListModel {
  const _ContributionListModel({final  List<ContributionModel> items = const <ContributionModel>[], required this.summary}): _items = items;
  factory _ContributionListModel.fromJson(Map<String, dynamic> json) => _$ContributionListModelFromJson(json);

 final  List<ContributionModel> _items;
@override@JsonKey() List<ContributionModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  ContributionSummaryModel summary;

/// Create a copy of ContributionListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionListModelCopyWith<_ContributionListModel> get copyWith => __$ContributionListModelCopyWithImpl<_ContributionListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionListModel&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),summary);

@override
String toString() {
  return 'ContributionListModel(items: $items, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$ContributionListModelCopyWith<$Res> implements $ContributionListModelCopyWith<$Res> {
  factory _$ContributionListModelCopyWith(_ContributionListModel value, $Res Function(_ContributionListModel) _then) = __$ContributionListModelCopyWithImpl;
@override @useResult
$Res call({
 List<ContributionModel> items, ContributionSummaryModel summary
});


@override $ContributionSummaryModelCopyWith<$Res> get summary;

}
/// @nodoc
class __$ContributionListModelCopyWithImpl<$Res>
    implements _$ContributionListModelCopyWith<$Res> {
  __$ContributionListModelCopyWithImpl(this._self, this._then);

  final _ContributionListModel _self;
  final $Res Function(_ContributionListModel) _then;

/// Create a copy of ContributionListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? summary = null,}) {
  return _then(_ContributionListModel(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ContributionModel>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ContributionSummaryModel,
  ));
}

/// Create a copy of ContributionListModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContributionSummaryModelCopyWith<$Res> get summary {
  
  return $ContributionSummaryModelCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
