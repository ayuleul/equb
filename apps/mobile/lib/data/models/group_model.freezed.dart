// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupMembershipModel {

@JsonKey(unknownEnumValue: MemberRoleModel.unknown) MemberRoleModel get role;@JsonKey(unknownEnumValue: MemberStatusModel.unknown) MemberStatusModel get status;
/// Create a copy of GroupMembershipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMembershipModelCopyWith<GroupMembershipModel> get copyWith => _$GroupMembershipModelCopyWithImpl<GroupMembershipModel>(this as GroupMembershipModel, _$identity);

  /// Serializes this GroupMembershipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMembershipModel&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,status);

@override
String toString() {
  return 'GroupMembershipModel(role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class $GroupMembershipModelCopyWith<$Res>  {
  factory $GroupMembershipModelCopyWith(GroupMembershipModel value, $Res Function(GroupMembershipModel) _then) = _$GroupMembershipModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: MemberRoleModel.unknown) MemberRoleModel role,@JsonKey(unknownEnumValue: MemberStatusModel.unknown) MemberStatusModel status
});




}
/// @nodoc
class _$GroupMembershipModelCopyWithImpl<$Res>
    implements $GroupMembershipModelCopyWith<$Res> {
  _$GroupMembershipModelCopyWithImpl(this._self, this._then);

  final GroupMembershipModel _self;
  final $Res Function(GroupMembershipModel) _then;

/// Create a copy of GroupMembershipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? status = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRoleModel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatusModel,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupMembershipModel].
extension GroupMembershipModelPatterns on GroupMembershipModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMembershipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMembershipModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMembershipModel value)  $default,){
final _that = this;
switch (_that) {
case _GroupMembershipModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMembershipModel value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMembershipModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: MemberRoleModel.unknown)  MemberRoleModel role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown)  MemberStatusModel status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMembershipModel() when $default != null:
return $default(_that.role,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: MemberRoleModel.unknown)  MemberRoleModel role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown)  MemberStatusModel status)  $default,) {final _that = this;
switch (_that) {
case _GroupMembershipModel():
return $default(_that.role,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: MemberRoleModel.unknown)  MemberRoleModel role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown)  MemberStatusModel status)?  $default,) {final _that = this;
switch (_that) {
case _GroupMembershipModel() when $default != null:
return $default(_that.role,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupMembershipModel implements GroupMembershipModel {
  const _GroupMembershipModel({@JsonKey(unknownEnumValue: MemberRoleModel.unknown) required this.role, @JsonKey(unknownEnumValue: MemberStatusModel.unknown) required this.status});
  factory _GroupMembershipModel.fromJson(Map<String, dynamic> json) => _$GroupMembershipModelFromJson(json);

@override@JsonKey(unknownEnumValue: MemberRoleModel.unknown) final  MemberRoleModel role;
@override@JsonKey(unknownEnumValue: MemberStatusModel.unknown) final  MemberStatusModel status;

/// Create a copy of GroupMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMembershipModelCopyWith<_GroupMembershipModel> get copyWith => __$GroupMembershipModelCopyWithImpl<_GroupMembershipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupMembershipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMembershipModel&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,status);

@override
String toString() {
  return 'GroupMembershipModel(role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class _$GroupMembershipModelCopyWith<$Res> implements $GroupMembershipModelCopyWith<$Res> {
  factory _$GroupMembershipModelCopyWith(_GroupMembershipModel value, $Res Function(_GroupMembershipModel) _then) = __$GroupMembershipModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: MemberRoleModel.unknown) MemberRoleModel role,@JsonKey(unknownEnumValue: MemberStatusModel.unknown) MemberStatusModel status
});




}
/// @nodoc
class __$GroupMembershipModelCopyWithImpl<$Res>
    implements _$GroupMembershipModelCopyWith<$Res> {
  __$GroupMembershipModelCopyWithImpl(this._self, this._then);

  final _GroupMembershipModel _self;
  final $Res Function(_GroupMembershipModel) _then;

/// Create a copy of GroupMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? status = null,}) {
  return _then(_GroupMembershipModel(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRoleModel,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatusModel,
  ));
}


}


/// @nodoc
mixin _$GroupModel {

 String get id; String get name; String get currency;@JsonKey(fromJson: _toInt) int get contributionAmount;@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) GroupFrequencyModel get frequency; DateTime get startDate;@JsonKey(unknownEnumValue: GroupStatusModel.unknown) GroupStatusModel get status; String? get createdByUserId; DateTime? get createdAt; bool? get strictPayout; String? get timezone; GroupMembershipModel? get membership; bool get rulesetConfigured; bool get canInviteMembers; bool get canStartCycle;
/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupModelCopyWith<GroupModel> get copyWith => _$GroupModelCopyWithImpl<GroupModel>(this as GroupModel, _$identity);

  /// Serializes this GroupModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.strictPayout, strictPayout) || other.strictPayout == strictPayout)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.membership, membership) || other.membership == membership)&&(identical(other.rulesetConfigured, rulesetConfigured) || other.rulesetConfigured == rulesetConfigured)&&(identical(other.canInviteMembers, canInviteMembers) || other.canInviteMembers == canInviteMembers)&&(identical(other.canStartCycle, canStartCycle) || other.canStartCycle == canStartCycle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,currency,contributionAmount,frequency,startDate,status,createdByUserId,createdAt,strictPayout,timezone,membership,rulesetConfigured,canInviteMembers,canStartCycle);

@override
String toString() {
  return 'GroupModel(id: $id, name: $name, currency: $currency, contributionAmount: $contributionAmount, frequency: $frequency, startDate: $startDate, status: $status, createdByUserId: $createdByUserId, createdAt: $createdAt, strictPayout: $strictPayout, timezone: $timezone, membership: $membership, rulesetConfigured: $rulesetConfigured, canInviteMembers: $canInviteMembers, canStartCycle: $canStartCycle)';
}


}

/// @nodoc
abstract mixin class $GroupModelCopyWith<$Res>  {
  factory $GroupModelCopyWith(GroupModel value, $Res Function(GroupModel) _then) = _$GroupModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String currency,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) GroupFrequencyModel frequency, DateTime startDate,@JsonKey(unknownEnumValue: GroupStatusModel.unknown) GroupStatusModel status, String? createdByUserId, DateTime? createdAt, bool? strictPayout, String? timezone, GroupMembershipModel? membership, bool rulesetConfigured, bool canInviteMembers, bool canStartCycle
});


$GroupMembershipModelCopyWith<$Res>? get membership;

}
/// @nodoc
class _$GroupModelCopyWithImpl<$Res>
    implements $GroupModelCopyWith<$Res> {
  _$GroupModelCopyWithImpl(this._self, this._then);

  final GroupModel _self;
  final $Res Function(GroupModel) _then;

/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? currency = null,Object? contributionAmount = null,Object? frequency = null,Object? startDate = null,Object? status = null,Object? createdByUserId = freezed,Object? createdAt = freezed,Object? strictPayout = freezed,Object? timezone = freezed,Object? membership = freezed,Object? rulesetConfigured = null,Object? canInviteMembers = null,Object? canStartCycle = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupFrequencyModel,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GroupStatusModel,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,strictPayout: freezed == strictPayout ? _self.strictPayout : strictPayout // ignore: cast_nullable_to_non_nullable
as bool?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,membership: freezed == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as GroupMembershipModel?,rulesetConfigured: null == rulesetConfigured ? _self.rulesetConfigured : rulesetConfigured // ignore: cast_nullable_to_non_nullable
as bool,canInviteMembers: null == canInviteMembers ? _self.canInviteMembers : canInviteMembers // ignore: cast_nullable_to_non_nullable
as bool,canStartCycle: null == canStartCycle ? _self.canStartCycle : canStartCycle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupMembershipModelCopyWith<$Res>? get membership {
    if (_self.membership == null) {
    return null;
  }

  return $GroupMembershipModelCopyWith<$Res>(_self.membership!, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupModel].
extension GroupModelPatterns on GroupModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupModel value)  $default,){
final _that = this;
switch (_that) {
case _GroupModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupModel value)?  $default,){
final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String currency, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)  GroupFrequencyModel frequency,  DateTime startDate, @JsonKey(unknownEnumValue: GroupStatusModel.unknown)  GroupStatusModel status,  String? createdByUserId,  DateTime? createdAt,  bool? strictPayout,  String? timezone,  GroupMembershipModel? membership,  bool rulesetConfigured,  bool canInviteMembers,  bool canStartCycle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
return $default(_that.id,_that.name,_that.currency,_that.contributionAmount,_that.frequency,_that.startDate,_that.status,_that.createdByUserId,_that.createdAt,_that.strictPayout,_that.timezone,_that.membership,_that.rulesetConfigured,_that.canInviteMembers,_that.canStartCycle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String currency, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)  GroupFrequencyModel frequency,  DateTime startDate, @JsonKey(unknownEnumValue: GroupStatusModel.unknown)  GroupStatusModel status,  String? createdByUserId,  DateTime? createdAt,  bool? strictPayout,  String? timezone,  GroupMembershipModel? membership,  bool rulesetConfigured,  bool canInviteMembers,  bool canStartCycle)  $default,) {final _that = this;
switch (_that) {
case _GroupModel():
return $default(_that.id,_that.name,_that.currency,_that.contributionAmount,_that.frequency,_that.startDate,_that.status,_that.createdByUserId,_that.createdAt,_that.strictPayout,_that.timezone,_that.membership,_that.rulesetConfigured,_that.canInviteMembers,_that.canStartCycle);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String currency, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)  GroupFrequencyModel frequency,  DateTime startDate, @JsonKey(unknownEnumValue: GroupStatusModel.unknown)  GroupStatusModel status,  String? createdByUserId,  DateTime? createdAt,  bool? strictPayout,  String? timezone,  GroupMembershipModel? membership,  bool rulesetConfigured,  bool canInviteMembers,  bool canStartCycle)?  $default,) {final _that = this;
switch (_that) {
case _GroupModel() when $default != null:
return $default(_that.id,_that.name,_that.currency,_that.contributionAmount,_that.frequency,_that.startDate,_that.status,_that.createdByUserId,_that.createdAt,_that.strictPayout,_that.timezone,_that.membership,_that.rulesetConfigured,_that.canInviteMembers,_that.canStartCycle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupModel implements GroupModel {
  const _GroupModel({required this.id, required this.name, required this.currency, @JsonKey(fromJson: _toInt) required this.contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) required this.frequency, required this.startDate, @JsonKey(unknownEnumValue: GroupStatusModel.unknown) required this.status, this.createdByUserId, this.createdAt, this.strictPayout, this.timezone, this.membership, this.rulesetConfigured = false, this.canInviteMembers = false, this.canStartCycle = false});
  factory _GroupModel.fromJson(Map<String, dynamic> json) => _$GroupModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String currency;
@override@JsonKey(fromJson: _toInt) final  int contributionAmount;
@override@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) final  GroupFrequencyModel frequency;
@override final  DateTime startDate;
@override@JsonKey(unknownEnumValue: GroupStatusModel.unknown) final  GroupStatusModel status;
@override final  String? createdByUserId;
@override final  DateTime? createdAt;
@override final  bool? strictPayout;
@override final  String? timezone;
@override final  GroupMembershipModel? membership;
@override@JsonKey() final  bool rulesetConfigured;
@override@JsonKey() final  bool canInviteMembers;
@override@JsonKey() final  bool canStartCycle;

/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupModelCopyWith<_GroupModel> get copyWith => __$GroupModelCopyWithImpl<_GroupModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.strictPayout, strictPayout) || other.strictPayout == strictPayout)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.membership, membership) || other.membership == membership)&&(identical(other.rulesetConfigured, rulesetConfigured) || other.rulesetConfigured == rulesetConfigured)&&(identical(other.canInviteMembers, canInviteMembers) || other.canInviteMembers == canInviteMembers)&&(identical(other.canStartCycle, canStartCycle) || other.canStartCycle == canStartCycle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,currency,contributionAmount,frequency,startDate,status,createdByUserId,createdAt,strictPayout,timezone,membership,rulesetConfigured,canInviteMembers,canStartCycle);

@override
String toString() {
  return 'GroupModel(id: $id, name: $name, currency: $currency, contributionAmount: $contributionAmount, frequency: $frequency, startDate: $startDate, status: $status, createdByUserId: $createdByUserId, createdAt: $createdAt, strictPayout: $strictPayout, timezone: $timezone, membership: $membership, rulesetConfigured: $rulesetConfigured, canInviteMembers: $canInviteMembers, canStartCycle: $canStartCycle)';
}


}

/// @nodoc
abstract mixin class _$GroupModelCopyWith<$Res> implements $GroupModelCopyWith<$Res> {
  factory _$GroupModelCopyWith(_GroupModel value, $Res Function(_GroupModel) _then) = __$GroupModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String currency,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) GroupFrequencyModel frequency, DateTime startDate,@JsonKey(unknownEnumValue: GroupStatusModel.unknown) GroupStatusModel status, String? createdByUserId, DateTime? createdAt, bool? strictPayout, String? timezone, GroupMembershipModel? membership, bool rulesetConfigured, bool canInviteMembers, bool canStartCycle
});


@override $GroupMembershipModelCopyWith<$Res>? get membership;

}
/// @nodoc
class __$GroupModelCopyWithImpl<$Res>
    implements _$GroupModelCopyWith<$Res> {
  __$GroupModelCopyWithImpl(this._self, this._then);

  final _GroupModel _self;
  final $Res Function(_GroupModel) _then;

/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? currency = null,Object? contributionAmount = null,Object? frequency = null,Object? startDate = null,Object? status = null,Object? createdByUserId = freezed,Object? createdAt = freezed,Object? strictPayout = freezed,Object? timezone = freezed,Object? membership = freezed,Object? rulesetConfigured = null,Object? canInviteMembers = null,Object? canStartCycle = null,}) {
  return _then(_GroupModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupFrequencyModel,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GroupStatusModel,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,strictPayout: freezed == strictPayout ? _self.strictPayout : strictPayout // ignore: cast_nullable_to_non_nullable
as bool?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,membership: freezed == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as GroupMembershipModel?,rulesetConfigured: null == rulesetConfigured ? _self.rulesetConfigured : rulesetConfigured // ignore: cast_nullable_to_non_nullable
as bool,canInviteMembers: null == canInviteMembers ? _self.canInviteMembers : canInviteMembers // ignore: cast_nullable_to_non_nullable
as bool,canStartCycle: null == canStartCycle ? _self.canStartCycle : canStartCycle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of GroupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupMembershipModelCopyWith<$Res>? get membership {
    if (_self.membership == null) {
    return null;
  }

  return $GroupMembershipModelCopyWith<$Res>(_self.membership!, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}

// dart format on
