// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_rules_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupRulesModel {

 String get groupId;@JsonKey(fromJson: _toInt) int get contributionAmount;@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel get frequency;@JsonKey(fromJson: _toNullableInt) int? get customIntervalDays;@JsonKey(fromJson: _toInt) int get graceDays;@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel get fineType;@JsonKey(fromJson: _toInt) int get fineAmount;@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel get payoutMode;@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> get paymentMethods; bool get requiresMemberVerification; bool get strictCollection; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupRulesModelCopyWith<GroupRulesModel> get copyWith => _$GroupRulesModelCopyWithImpl<GroupRulesModel>(this as GroupRulesModel, _$identity);

  /// Serializes this GroupRulesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupRulesModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.fineType, fineType) || other.fineType == fineType)&&(identical(other.fineAmount, fineAmount) || other.fineAmount == fineAmount)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&const DeepCollectionEquality().equals(other.paymentMethods, paymentMethods)&&(identical(other.requiresMemberVerification, requiresMemberVerification) || other.requiresMemberVerification == requiresMemberVerification)&&(identical(other.strictCollection, strictCollection) || other.strictCollection == strictCollection)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,contributionAmount,frequency,customIntervalDays,graceDays,fineType,fineAmount,payoutMode,const DeepCollectionEquality().hash(paymentMethods),requiresMemberVerification,strictCollection,createdAt,updatedAt);

@override
String toString() {
  return 'GroupRulesModel(groupId: $groupId, contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, graceDays: $graceDays, fineType: $fineType, fineAmount: $fineAmount, payoutMode: $payoutMode, paymentMethods: $paymentMethods, requiresMemberVerification: $requiresMemberVerification, strictCollection: $strictCollection, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GroupRulesModelCopyWith<$Res>  {
  factory $GroupRulesModelCopyWith(GroupRulesModel value, $Res Function(GroupRulesModel) _then) = _$GroupRulesModelCopyWithImpl;
@useResult
$Res call({
 String groupId,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel frequency,@JsonKey(fromJson: _toNullableInt) int? customIntervalDays,@JsonKey(fromJson: _toInt) int graceDays,@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel fineType,@JsonKey(fromJson: _toInt) int fineAmount,@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel payoutMode,@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> paymentMethods, bool requiresMemberVerification, bool strictCollection, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$GroupRulesModelCopyWithImpl<$Res>
    implements $GroupRulesModelCopyWith<$Res> {
  _$GroupRulesModelCopyWithImpl(this._self, this._then);

  final GroupRulesModel _self;
  final $Res Function(GroupRulesModel) _then;

/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? graceDays = null,Object? fineType = null,Object? fineAmount = null,Object? payoutMode = null,Object? paymentMethods = null,Object? requiresMemberVerification = null,Object? strictCollection = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupRuleFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,fineType: null == fineType ? _self.fineType : fineType // ignore: cast_nullable_to_non_nullable
as GroupRuleFineTypeModel,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as int,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as GroupRulePayoutModeModel,paymentMethods: null == paymentMethods ? _self.paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<GroupPaymentMethodModel>,requiresMemberVerification: null == requiresMemberVerification ? _self.requiresMemberVerification : requiresMemberVerification // ignore: cast_nullable_to_non_nullable
as bool,strictCollection: null == strictCollection ? _self.strictCollection : strictCollection // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupRulesModel].
extension GroupRulesModelPatterns on GroupRulesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupRulesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupRulesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupRulesModel value)  $default,){
final _that = this;
switch (_that) {
case _GroupRulesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupRulesModel value)?  $default,){
final _that = this;
switch (_that) {
case _GroupRulesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency, @JsonKey(fromJson: _toNullableInt)  int? customIntervalDays, @JsonKey(fromJson: _toInt)  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType, @JsonKey(fromJson: _toInt)  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods,  bool requiresMemberVerification,  bool strictCollection,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupRulesModel() when $default != null:
return $default(_that.groupId,_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.paymentMethods,_that.requiresMemberVerification,_that.strictCollection,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency, @JsonKey(fromJson: _toNullableInt)  int? customIntervalDays, @JsonKey(fromJson: _toInt)  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType, @JsonKey(fromJson: _toInt)  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods,  bool requiresMemberVerification,  bool strictCollection,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GroupRulesModel():
return $default(_that.groupId,_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.paymentMethods,_that.requiresMemberVerification,_that.strictCollection,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency, @JsonKey(fromJson: _toNullableInt)  int? customIntervalDays, @JsonKey(fromJson: _toInt)  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType, @JsonKey(fromJson: _toInt)  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods,  bool requiresMemberVerification,  bool strictCollection,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GroupRulesModel() when $default != null:
return $default(_that.groupId,_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.paymentMethods,_that.requiresMemberVerification,_that.strictCollection,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupRulesModel implements GroupRulesModel {
  const _GroupRulesModel({required this.groupId, @JsonKey(fromJson: _toInt) required this.contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) required this.frequency, @JsonKey(fromJson: _toNullableInt) this.customIntervalDays, @JsonKey(fromJson: _toInt) required this.graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) required this.fineType, @JsonKey(fromJson: _toInt) required this.fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) required this.payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) required final  List<GroupPaymentMethodModel> paymentMethods, required this.requiresMemberVerification, required this.strictCollection, required this.createdAt, required this.updatedAt}): _paymentMethods = paymentMethods;
  factory _GroupRulesModel.fromJson(Map<String, dynamic> json) => _$GroupRulesModelFromJson(json);

@override final  String groupId;
@override@JsonKey(fromJson: _toInt) final  int contributionAmount;
@override@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) final  GroupRuleFrequencyModel frequency;
@override@JsonKey(fromJson: _toNullableInt) final  int? customIntervalDays;
@override@JsonKey(fromJson: _toInt) final  int graceDays;
@override@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) final  GroupRuleFineTypeModel fineType;
@override@JsonKey(fromJson: _toInt) final  int fineAmount;
@override@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) final  GroupRulePayoutModeModel payoutMode;
 final  List<GroupPaymentMethodModel> _paymentMethods;
@override@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> get paymentMethods {
  if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentMethods);
}

@override final  bool requiresMemberVerification;
@override final  bool strictCollection;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupRulesModelCopyWith<_GroupRulesModel> get copyWith => __$GroupRulesModelCopyWithImpl<_GroupRulesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupRulesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupRulesModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.fineType, fineType) || other.fineType == fineType)&&(identical(other.fineAmount, fineAmount) || other.fineAmount == fineAmount)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&const DeepCollectionEquality().equals(other._paymentMethods, _paymentMethods)&&(identical(other.requiresMemberVerification, requiresMemberVerification) || other.requiresMemberVerification == requiresMemberVerification)&&(identical(other.strictCollection, strictCollection) || other.strictCollection == strictCollection)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,contributionAmount,frequency,customIntervalDays,graceDays,fineType,fineAmount,payoutMode,const DeepCollectionEquality().hash(_paymentMethods),requiresMemberVerification,strictCollection,createdAt,updatedAt);

@override
String toString() {
  return 'GroupRulesModel(groupId: $groupId, contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, graceDays: $graceDays, fineType: $fineType, fineAmount: $fineAmount, payoutMode: $payoutMode, paymentMethods: $paymentMethods, requiresMemberVerification: $requiresMemberVerification, strictCollection: $strictCollection, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GroupRulesModelCopyWith<$Res> implements $GroupRulesModelCopyWith<$Res> {
  factory _$GroupRulesModelCopyWith(_GroupRulesModel value, $Res Function(_GroupRulesModel) _then) = __$GroupRulesModelCopyWithImpl;
@override @useResult
$Res call({
 String groupId,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel frequency,@JsonKey(fromJson: _toNullableInt) int? customIntervalDays,@JsonKey(fromJson: _toInt) int graceDays,@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel fineType,@JsonKey(fromJson: _toInt) int fineAmount,@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel payoutMode,@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> paymentMethods, bool requiresMemberVerification, bool strictCollection, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$GroupRulesModelCopyWithImpl<$Res>
    implements _$GroupRulesModelCopyWith<$Res> {
  __$GroupRulesModelCopyWithImpl(this._self, this._then);

  final _GroupRulesModel _self;
  final $Res Function(_GroupRulesModel) _then;

/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? graceDays = null,Object? fineType = null,Object? fineAmount = null,Object? payoutMode = null,Object? paymentMethods = null,Object? requiresMemberVerification = null,Object? strictCollection = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_GroupRulesModel(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupRuleFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,fineType: null == fineType ? _self.fineType : fineType // ignore: cast_nullable_to_non_nullable
as GroupRuleFineTypeModel,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as int,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as GroupRulePayoutModeModel,paymentMethods: null == paymentMethods ? _self._paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<GroupPaymentMethodModel>,requiresMemberVerification: null == requiresMemberVerification ? _self.requiresMemberVerification : requiresMemberVerification // ignore: cast_nullable_to_non_nullable
as bool,strictCollection: null == strictCollection ? _self.strictCollection : strictCollection // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
