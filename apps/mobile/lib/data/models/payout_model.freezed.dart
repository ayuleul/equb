// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayoutUserModel {

 String get id; String? get fullName; String? get phone;
/// Create a copy of PayoutUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutUserModelCopyWith<PayoutUserModel> get copyWith => _$PayoutUserModelCopyWithImpl<PayoutUserModel>(this as PayoutUserModel, _$identity);

  /// Serializes this PayoutUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone);

@override
String toString() {
  return 'PayoutUserModel(id: $id, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $PayoutUserModelCopyWith<$Res>  {
  factory $PayoutUserModelCopyWith(PayoutUserModel value, $Res Function(PayoutUserModel) _then) = _$PayoutUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String? fullName, String? phone
});




}
/// @nodoc
class _$PayoutUserModelCopyWithImpl<$Res>
    implements $PayoutUserModelCopyWith<$Res> {
  _$PayoutUserModelCopyWithImpl(this._self, this._then);

  final PayoutUserModel _self;
  final $Res Function(PayoutUserModel) _then;

/// Create a copy of PayoutUserModel
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


/// Adds pattern-matching-related methods to [PayoutUserModel].
extension PayoutUserModelPatterns on PayoutUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutUserModel value)  $default,){
final _that = this;
switch (_that) {
case _PayoutUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutUserModel() when $default != null:
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
case _PayoutUserModel() when $default != null:
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
case _PayoutUserModel():
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
case _PayoutUserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayoutUserModel implements PayoutUserModel {
  const _PayoutUserModel({required this.id, this.fullName, this.phone});
  factory _PayoutUserModel.fromJson(Map<String, dynamic> json) => _$PayoutUserModelFromJson(json);

@override final  String id;
@override final  String? fullName;
@override final  String? phone;

/// Create a copy of PayoutUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutUserModelCopyWith<_PayoutUserModel> get copyWith => __$PayoutUserModelCopyWithImpl<_PayoutUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone);

@override
String toString() {
  return 'PayoutUserModel(id: $id, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$PayoutUserModelCopyWith<$Res> implements $PayoutUserModelCopyWith<$Res> {
  factory _$PayoutUserModelCopyWith(_PayoutUserModel value, $Res Function(_PayoutUserModel) _then) = __$PayoutUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? fullName, String? phone
});




}
/// @nodoc
class __$PayoutUserModelCopyWithImpl<$Res>
    implements _$PayoutUserModelCopyWith<$Res> {
  __$PayoutUserModelCopyWithImpl(this._self, this._then);

  final _PayoutUserModel _self;
  final $Res Function(_PayoutUserModel) _then;

/// Create a copy of PayoutUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = freezed,Object? phone = freezed,}) {
  return _then(_PayoutUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PayoutModel {

 String get id; String get groupId; String get cycleId; String get toUserId;@JsonKey(fromJson: _toInt) int get amount;@JsonKey(unknownEnumValue: PayoutStatusModel.unknown) PayoutStatusModel get status; String? get proofFileKey; String? get paymentRef; String? get note; String? get createdByUserId; DateTime? get createdAt; String? get confirmedByUserId; DateTime? get confirmedAt; PayoutUserModel get toUser;
/// Create a copy of PayoutModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutModelCopyWith<PayoutModel> get copyWith => _$PayoutModelCopyWithImpl<PayoutModel>(this as PayoutModel, _$identity);

  /// Serializes this PayoutModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.confirmedByUserId, confirmedByUserId) || other.confirmedByUserId == confirmedByUserId)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.toUser, toUser) || other.toUser == toUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,cycleId,toUserId,amount,status,proofFileKey,paymentRef,note,createdByUserId,createdAt,confirmedByUserId,confirmedAt,toUser);

@override
String toString() {
  return 'PayoutModel(id: $id, groupId: $groupId, cycleId: $cycleId, toUserId: $toUserId, amount: $amount, status: $status, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note, createdByUserId: $createdByUserId, createdAt: $createdAt, confirmedByUserId: $confirmedByUserId, confirmedAt: $confirmedAt, toUser: $toUser)';
}


}

/// @nodoc
abstract mixin class $PayoutModelCopyWith<$Res>  {
  factory $PayoutModelCopyWith(PayoutModel value, $Res Function(PayoutModel) _then) = _$PayoutModelCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String cycleId, String toUserId,@JsonKey(fromJson: _toInt) int amount,@JsonKey(unknownEnumValue: PayoutStatusModel.unknown) PayoutStatusModel status, String? proofFileKey, String? paymentRef, String? note, String? createdByUserId, DateTime? createdAt, String? confirmedByUserId, DateTime? confirmedAt, PayoutUserModel toUser
});


$PayoutUserModelCopyWith<$Res> get toUser;

}
/// @nodoc
class _$PayoutModelCopyWithImpl<$Res>
    implements $PayoutModelCopyWith<$Res> {
  _$PayoutModelCopyWithImpl(this._self, this._then);

  final PayoutModel _self;
  final $Res Function(PayoutModel) _then;

/// Create a copy of PayoutModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? cycleId = null,Object? toUserId = null,Object? amount = null,Object? status = null,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,Object? createdByUserId = freezed,Object? createdAt = freezed,Object? confirmedByUserId = freezed,Object? confirmedAt = freezed,Object? toUser = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatusModel,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedByUserId: freezed == confirmedByUserId ? _self.confirmedByUserId : confirmedByUserId // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,toUser: null == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as PayoutUserModel,
  ));
}
/// Create a copy of PayoutModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PayoutUserModelCopyWith<$Res> get toUser {
  
  return $PayoutUserModelCopyWith<$Res>(_self.toUser, (value) {
    return _then(_self.copyWith(toUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [PayoutModel].
extension PayoutModelPatterns on PayoutModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutModel value)  $default,){
final _that = this;
switch (_that) {
case _PayoutModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutModel value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String cycleId,  String toUserId, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(unknownEnumValue: PayoutStatusModel.unknown)  PayoutStatusModel status,  String? proofFileKey,  String? paymentRef,  String? note,  String? createdByUserId,  DateTime? createdAt,  String? confirmedByUserId,  DateTime? confirmedAt,  PayoutUserModel toUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutModel() when $default != null:
return $default(_that.id,_that.groupId,_that.cycleId,_that.toUserId,_that.amount,_that.status,_that.proofFileKey,_that.paymentRef,_that.note,_that.createdByUserId,_that.createdAt,_that.confirmedByUserId,_that.confirmedAt,_that.toUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String cycleId,  String toUserId, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(unknownEnumValue: PayoutStatusModel.unknown)  PayoutStatusModel status,  String? proofFileKey,  String? paymentRef,  String? note,  String? createdByUserId,  DateTime? createdAt,  String? confirmedByUserId,  DateTime? confirmedAt,  PayoutUserModel toUser)  $default,) {final _that = this;
switch (_that) {
case _PayoutModel():
return $default(_that.id,_that.groupId,_that.cycleId,_that.toUserId,_that.amount,_that.status,_that.proofFileKey,_that.paymentRef,_that.note,_that.createdByUserId,_that.createdAt,_that.confirmedByUserId,_that.confirmedAt,_that.toUser);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String cycleId,  String toUserId, @JsonKey(fromJson: _toInt)  int amount, @JsonKey(unknownEnumValue: PayoutStatusModel.unknown)  PayoutStatusModel status,  String? proofFileKey,  String? paymentRef,  String? note,  String? createdByUserId,  DateTime? createdAt,  String? confirmedByUserId,  DateTime? confirmedAt,  PayoutUserModel toUser)?  $default,) {final _that = this;
switch (_that) {
case _PayoutModel() when $default != null:
return $default(_that.id,_that.groupId,_that.cycleId,_that.toUserId,_that.amount,_that.status,_that.proofFileKey,_that.paymentRef,_that.note,_that.createdByUserId,_that.createdAt,_that.confirmedByUserId,_that.confirmedAt,_that.toUser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayoutModel extends PayoutModel {
  const _PayoutModel({required this.id, required this.groupId, required this.cycleId, required this.toUserId, @JsonKey(fromJson: _toInt) required this.amount, @JsonKey(unknownEnumValue: PayoutStatusModel.unknown) required this.status, this.proofFileKey, this.paymentRef, this.note, this.createdByUserId, this.createdAt, this.confirmedByUserId, this.confirmedAt, required this.toUser}): super._();
  factory _PayoutModel.fromJson(Map<String, dynamic> json) => _$PayoutModelFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String cycleId;
@override final  String toUserId;
@override@JsonKey(fromJson: _toInt) final  int amount;
@override@JsonKey(unknownEnumValue: PayoutStatusModel.unknown) final  PayoutStatusModel status;
@override final  String? proofFileKey;
@override final  String? paymentRef;
@override final  String? note;
@override final  String? createdByUserId;
@override final  DateTime? createdAt;
@override final  String? confirmedByUserId;
@override final  DateTime? confirmedAt;
@override final  PayoutUserModel toUser;

/// Create a copy of PayoutModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutModelCopyWith<_PayoutModel> get copyWith => __$PayoutModelCopyWithImpl<_PayoutModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayoutModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.proofFileKey, proofFileKey) || other.proofFileKey == proofFileKey)&&(identical(other.paymentRef, paymentRef) || other.paymentRef == paymentRef)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.confirmedByUserId, confirmedByUserId) || other.confirmedByUserId == confirmedByUserId)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.toUser, toUser) || other.toUser == toUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,cycleId,toUserId,amount,status,proofFileKey,paymentRef,note,createdByUserId,createdAt,confirmedByUserId,confirmedAt,toUser);

@override
String toString() {
  return 'PayoutModel(id: $id, groupId: $groupId, cycleId: $cycleId, toUserId: $toUserId, amount: $amount, status: $status, proofFileKey: $proofFileKey, paymentRef: $paymentRef, note: $note, createdByUserId: $createdByUserId, createdAt: $createdAt, confirmedByUserId: $confirmedByUserId, confirmedAt: $confirmedAt, toUser: $toUser)';
}


}

/// @nodoc
abstract mixin class _$PayoutModelCopyWith<$Res> implements $PayoutModelCopyWith<$Res> {
  factory _$PayoutModelCopyWith(_PayoutModel value, $Res Function(_PayoutModel) _then) = __$PayoutModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String cycleId, String toUserId,@JsonKey(fromJson: _toInt) int amount,@JsonKey(unknownEnumValue: PayoutStatusModel.unknown) PayoutStatusModel status, String? proofFileKey, String? paymentRef, String? note, String? createdByUserId, DateTime? createdAt, String? confirmedByUserId, DateTime? confirmedAt, PayoutUserModel toUser
});


@override $PayoutUserModelCopyWith<$Res> get toUser;

}
/// @nodoc
class __$PayoutModelCopyWithImpl<$Res>
    implements _$PayoutModelCopyWith<$Res> {
  __$PayoutModelCopyWithImpl(this._self, this._then);

  final _PayoutModel _self;
  final $Res Function(_PayoutModel) _then;

/// Create a copy of PayoutModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? cycleId = null,Object? toUserId = null,Object? amount = null,Object? status = null,Object? proofFileKey = freezed,Object? paymentRef = freezed,Object? note = freezed,Object? createdByUserId = freezed,Object? createdAt = freezed,Object? confirmedByUserId = freezed,Object? confirmedAt = freezed,Object? toUser = null,}) {
  return _then(_PayoutModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatusModel,proofFileKey: freezed == proofFileKey ? _self.proofFileKey : proofFileKey // ignore: cast_nullable_to_non_nullable
as String?,paymentRef: freezed == paymentRef ? _self.paymentRef : paymentRef // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedByUserId: freezed == confirmedByUserId ? _self.confirmedByUserId : confirmedByUserId // ignore: cast_nullable_to_non_nullable
as String?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,toUser: null == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as PayoutUserModel,
  ));
}

/// Create a copy of PayoutModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PayoutUserModelCopyWith<$Res> get toUser {
  
  return $PayoutUserModelCopyWith<$Res>(_self.toUser, (value) {
    return _then(_self.copyWith(toUser: value));
  });
}
}

// dart format on
