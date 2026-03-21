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
mixin _$GroupStartReadinessModel {

@JsonKey(fromJson: _toInt) int get eligibleCount; bool get isReadyToStart; bool get isWaitingForMembers; bool get isWaitingForDate;
/// Create a copy of GroupStartReadinessModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupStartReadinessModelCopyWith<GroupStartReadinessModel> get copyWith => _$GroupStartReadinessModelCopyWithImpl<GroupStartReadinessModel>(this as GroupStartReadinessModel, _$identity);

  /// Serializes this GroupStartReadinessModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupStartReadinessModel&&(identical(other.eligibleCount, eligibleCount) || other.eligibleCount == eligibleCount)&&(identical(other.isReadyToStart, isReadyToStart) || other.isReadyToStart == isReadyToStart)&&(identical(other.isWaitingForMembers, isWaitingForMembers) || other.isWaitingForMembers == isWaitingForMembers)&&(identical(other.isWaitingForDate, isWaitingForDate) || other.isWaitingForDate == isWaitingForDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eligibleCount,isReadyToStart,isWaitingForMembers,isWaitingForDate);

@override
String toString() {
  return 'GroupStartReadinessModel(eligibleCount: $eligibleCount, isReadyToStart: $isReadyToStart, isWaitingForMembers: $isWaitingForMembers, isWaitingForDate: $isWaitingForDate)';
}


}

/// @nodoc
abstract mixin class $GroupStartReadinessModelCopyWith<$Res>  {
  factory $GroupStartReadinessModelCopyWith(GroupStartReadinessModel value, $Res Function(GroupStartReadinessModel) _then) = _$GroupStartReadinessModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int eligibleCount, bool isReadyToStart, bool isWaitingForMembers, bool isWaitingForDate
});




}
/// @nodoc
class _$GroupStartReadinessModelCopyWithImpl<$Res>
    implements $GroupStartReadinessModelCopyWith<$Res> {
  _$GroupStartReadinessModelCopyWithImpl(this._self, this._then);

  final GroupStartReadinessModel _self;
  final $Res Function(GroupStartReadinessModel) _then;

/// Create a copy of GroupStartReadinessModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eligibleCount = null,Object? isReadyToStart = null,Object? isWaitingForMembers = null,Object? isWaitingForDate = null,}) {
  return _then(_self.copyWith(
eligibleCount: null == eligibleCount ? _self.eligibleCount : eligibleCount // ignore: cast_nullable_to_non_nullable
as int,isReadyToStart: null == isReadyToStart ? _self.isReadyToStart : isReadyToStart // ignore: cast_nullable_to_non_nullable
as bool,isWaitingForMembers: null == isWaitingForMembers ? _self.isWaitingForMembers : isWaitingForMembers // ignore: cast_nullable_to_non_nullable
as bool,isWaitingForDate: null == isWaitingForDate ? _self.isWaitingForDate : isWaitingForDate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupStartReadinessModel].
extension GroupStartReadinessModelPatterns on GroupStartReadinessModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupStartReadinessModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupStartReadinessModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupStartReadinessModel value)  $default,){
final _that = this;
switch (_that) {
case _GroupStartReadinessModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupStartReadinessModel value)?  $default,){
final _that = this;
switch (_that) {
case _GroupStartReadinessModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int eligibleCount,  bool isReadyToStart,  bool isWaitingForMembers,  bool isWaitingForDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupStartReadinessModel() when $default != null:
return $default(_that.eligibleCount,_that.isReadyToStart,_that.isWaitingForMembers,_that.isWaitingForDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int eligibleCount,  bool isReadyToStart,  bool isWaitingForMembers,  bool isWaitingForDate)  $default,) {final _that = this;
switch (_that) {
case _GroupStartReadinessModel():
return $default(_that.eligibleCount,_that.isReadyToStart,_that.isWaitingForMembers,_that.isWaitingForDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int eligibleCount,  bool isReadyToStart,  bool isWaitingForMembers,  bool isWaitingForDate)?  $default,) {final _that = this;
switch (_that) {
case _GroupStartReadinessModel() when $default != null:
return $default(_that.eligibleCount,_that.isReadyToStart,_that.isWaitingForMembers,_that.isWaitingForDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupStartReadinessModel implements GroupStartReadinessModel {
  const _GroupStartReadinessModel({@JsonKey(fromJson: _toInt) required this.eligibleCount, required this.isReadyToStart, required this.isWaitingForMembers, required this.isWaitingForDate});
  factory _GroupStartReadinessModel.fromJson(Map<String, dynamic> json) => _$GroupStartReadinessModelFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int eligibleCount;
@override final  bool isReadyToStart;
@override final  bool isWaitingForMembers;
@override final  bool isWaitingForDate;

/// Create a copy of GroupStartReadinessModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupStartReadinessModelCopyWith<_GroupStartReadinessModel> get copyWith => __$GroupStartReadinessModelCopyWithImpl<_GroupStartReadinessModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupStartReadinessModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupStartReadinessModel&&(identical(other.eligibleCount, eligibleCount) || other.eligibleCount == eligibleCount)&&(identical(other.isReadyToStart, isReadyToStart) || other.isReadyToStart == isReadyToStart)&&(identical(other.isWaitingForMembers, isWaitingForMembers) || other.isWaitingForMembers == isWaitingForMembers)&&(identical(other.isWaitingForDate, isWaitingForDate) || other.isWaitingForDate == isWaitingForDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eligibleCount,isReadyToStart,isWaitingForMembers,isWaitingForDate);

@override
String toString() {
  return 'GroupStartReadinessModel(eligibleCount: $eligibleCount, isReadyToStart: $isReadyToStart, isWaitingForMembers: $isWaitingForMembers, isWaitingForDate: $isWaitingForDate)';
}


}

/// @nodoc
abstract mixin class _$GroupStartReadinessModelCopyWith<$Res> implements $GroupStartReadinessModelCopyWith<$Res> {
  factory _$GroupStartReadinessModelCopyWith(_GroupStartReadinessModel value, $Res Function(_GroupStartReadinessModel) _then) = __$GroupStartReadinessModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int eligibleCount, bool isReadyToStart, bool isWaitingForMembers, bool isWaitingForDate
});




}
/// @nodoc
class __$GroupStartReadinessModelCopyWithImpl<$Res>
    implements _$GroupStartReadinessModelCopyWith<$Res> {
  __$GroupStartReadinessModelCopyWithImpl(this._self, this._then);

  final _GroupStartReadinessModel _self;
  final $Res Function(_GroupStartReadinessModel) _then;

/// Create a copy of GroupStartReadinessModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eligibleCount = null,Object? isReadyToStart = null,Object? isWaitingForMembers = null,Object? isWaitingForDate = null,}) {
  return _then(_GroupStartReadinessModel(
eligibleCount: null == eligibleCount ? _self.eligibleCount : eligibleCount // ignore: cast_nullable_to_non_nullable
as int,isReadyToStart: null == isReadyToStart ? _self.isReadyToStart : isReadyToStart // ignore: cast_nullable_to_non_nullable
as bool,isWaitingForMembers: null == isWaitingForMembers ? _self.isWaitingForMembers : isWaitingForMembers // ignore: cast_nullable_to_non_nullable
as bool,isWaitingForDate: null == isWaitingForDate ? _self.isWaitingForDate : isWaitingForDate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GroupRulesModel {

 String get groupId;@JsonKey(fromJson: _toInt) int get contributionAmount;@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel get frequency;@JsonKey(fromJson: _toNullableInt) int? get customIntervalDays;@JsonKey(fromJson: _toInt) int get graceDays;@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel get fineType;@JsonKey(fromJson: _toInt) int get fineAmount;@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel get payoutMode;@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) WinnerSelectionTimingModel get winnerSelectionTiming;@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> get paymentMethods;@JsonKey(fromJson: _toInt) int get roundSize;@JsonKey(unknownEnumValue: StartPolicyModel.unknown) StartPolicyModel get startPolicy; DateTime? get startAt;@JsonKey(fromJson: _toNullableInt) int? get minToStart;@JsonKey(fromJson: _toInt) int get requiredToStart; GroupStartReadinessModel get readiness; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupRulesModelCopyWith<GroupRulesModel> get copyWith => _$GroupRulesModelCopyWithImpl<GroupRulesModel>(this as GroupRulesModel, _$identity);

  /// Serializes this GroupRulesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupRulesModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.fineType, fineType) || other.fineType == fineType)&&(identical(other.fineAmount, fineAmount) || other.fineAmount == fineAmount)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&(identical(other.winnerSelectionTiming, winnerSelectionTiming) || other.winnerSelectionTiming == winnerSelectionTiming)&&const DeepCollectionEquality().equals(other.paymentMethods, paymentMethods)&&(identical(other.roundSize, roundSize) || other.roundSize == roundSize)&&(identical(other.startPolicy, startPolicy) || other.startPolicy == startPolicy)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.minToStart, minToStart) || other.minToStart == minToStart)&&(identical(other.requiredToStart, requiredToStart) || other.requiredToStart == requiredToStart)&&(identical(other.readiness, readiness) || other.readiness == readiness)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,contributionAmount,frequency,customIntervalDays,graceDays,fineType,fineAmount,payoutMode,winnerSelectionTiming,const DeepCollectionEquality().hash(paymentMethods),roundSize,startPolicy,startAt,minToStart,requiredToStart,readiness,createdAt,updatedAt);

@override
String toString() {
  return 'GroupRulesModel(groupId: $groupId, contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, graceDays: $graceDays, fineType: $fineType, fineAmount: $fineAmount, payoutMode: $payoutMode, winnerSelectionTiming: $winnerSelectionTiming, paymentMethods: $paymentMethods, roundSize: $roundSize, startPolicy: $startPolicy, startAt: $startAt, minToStart: $minToStart, requiredToStart: $requiredToStart, readiness: $readiness, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GroupRulesModelCopyWith<$Res>  {
  factory $GroupRulesModelCopyWith(GroupRulesModel value, $Res Function(GroupRulesModel) _then) = _$GroupRulesModelCopyWithImpl;
@useResult
$Res call({
 String groupId,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel frequency,@JsonKey(fromJson: _toNullableInt) int? customIntervalDays,@JsonKey(fromJson: _toInt) int graceDays,@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel fineType,@JsonKey(fromJson: _toInt) int fineAmount,@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel payoutMode,@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) WinnerSelectionTimingModel winnerSelectionTiming,@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> paymentMethods,@JsonKey(fromJson: _toInt) int roundSize,@JsonKey(unknownEnumValue: StartPolicyModel.unknown) StartPolicyModel startPolicy, DateTime? startAt,@JsonKey(fromJson: _toNullableInt) int? minToStart,@JsonKey(fromJson: _toInt) int requiredToStart, GroupStartReadinessModel readiness, DateTime createdAt, DateTime updatedAt
});


$GroupStartReadinessModelCopyWith<$Res> get readiness;

}
/// @nodoc
class _$GroupRulesModelCopyWithImpl<$Res>
    implements $GroupRulesModelCopyWith<$Res> {
  _$GroupRulesModelCopyWithImpl(this._self, this._then);

  final GroupRulesModel _self;
  final $Res Function(GroupRulesModel) _then;

/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? graceDays = null,Object? fineType = null,Object? fineAmount = null,Object? payoutMode = null,Object? winnerSelectionTiming = null,Object? paymentMethods = null,Object? roundSize = null,Object? startPolicy = null,Object? startAt = freezed,Object? minToStart = freezed,Object? requiredToStart = null,Object? readiness = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupRuleFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,fineType: null == fineType ? _self.fineType : fineType // ignore: cast_nullable_to_non_nullable
as GroupRuleFineTypeModel,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as int,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as GroupRulePayoutModeModel,winnerSelectionTiming: null == winnerSelectionTiming ? _self.winnerSelectionTiming : winnerSelectionTiming // ignore: cast_nullable_to_non_nullable
as WinnerSelectionTimingModel,paymentMethods: null == paymentMethods ? _self.paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<GroupPaymentMethodModel>,roundSize: null == roundSize ? _self.roundSize : roundSize // ignore: cast_nullable_to_non_nullable
as int,startPolicy: null == startPolicy ? _self.startPolicy : startPolicy // ignore: cast_nullable_to_non_nullable
as StartPolicyModel,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,minToStart: freezed == minToStart ? _self.minToStart : minToStart // ignore: cast_nullable_to_non_nullable
as int?,requiredToStart: null == requiredToStart ? _self.requiredToStart : requiredToStart // ignore: cast_nullable_to_non_nullable
as int,readiness: null == readiness ? _self.readiness : readiness // ignore: cast_nullable_to_non_nullable
as GroupStartReadinessModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupStartReadinessModelCopyWith<$Res> get readiness {
  
  return $GroupStartReadinessModelCopyWith<$Res>(_self.readiness, (value) {
    return _then(_self.copyWith(readiness: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency, @JsonKey(fromJson: _toNullableInt)  int? customIntervalDays, @JsonKey(fromJson: _toInt)  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType, @JsonKey(fromJson: _toInt)  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown)  WinnerSelectionTimingModel winnerSelectionTiming, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods, @JsonKey(fromJson: _toInt)  int roundSize, @JsonKey(unknownEnumValue: StartPolicyModel.unknown)  StartPolicyModel startPolicy,  DateTime? startAt, @JsonKey(fromJson: _toNullableInt)  int? minToStart, @JsonKey(fromJson: _toInt)  int requiredToStart,  GroupStartReadinessModel readiness,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupRulesModel() when $default != null:
return $default(_that.groupId,_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.winnerSelectionTiming,_that.paymentMethods,_that.roundSize,_that.startPolicy,_that.startAt,_that.minToStart,_that.requiredToStart,_that.readiness,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency, @JsonKey(fromJson: _toNullableInt)  int? customIntervalDays, @JsonKey(fromJson: _toInt)  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType, @JsonKey(fromJson: _toInt)  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown)  WinnerSelectionTimingModel winnerSelectionTiming, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods, @JsonKey(fromJson: _toInt)  int roundSize, @JsonKey(unknownEnumValue: StartPolicyModel.unknown)  StartPolicyModel startPolicy,  DateTime? startAt, @JsonKey(fromJson: _toNullableInt)  int? minToStart, @JsonKey(fromJson: _toInt)  int requiredToStart,  GroupStartReadinessModel readiness,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GroupRulesModel():
return $default(_that.groupId,_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.winnerSelectionTiming,_that.paymentMethods,_that.roundSize,_that.startPolicy,_that.startAt,_that.minToStart,_that.requiredToStart,_that.readiness,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency, @JsonKey(fromJson: _toNullableInt)  int? customIntervalDays, @JsonKey(fromJson: _toInt)  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType, @JsonKey(fromJson: _toInt)  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown)  WinnerSelectionTimingModel winnerSelectionTiming, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods, @JsonKey(fromJson: _toInt)  int roundSize, @JsonKey(unknownEnumValue: StartPolicyModel.unknown)  StartPolicyModel startPolicy,  DateTime? startAt, @JsonKey(fromJson: _toNullableInt)  int? minToStart, @JsonKey(fromJson: _toInt)  int requiredToStart,  GroupStartReadinessModel readiness,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GroupRulesModel() when $default != null:
return $default(_that.groupId,_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.winnerSelectionTiming,_that.paymentMethods,_that.roundSize,_that.startPolicy,_that.startAt,_that.minToStart,_that.requiredToStart,_that.readiness,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupRulesModel implements GroupRulesModel {
  const _GroupRulesModel({required this.groupId, @JsonKey(fromJson: _toInt) required this.contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) required this.frequency, @JsonKey(fromJson: _toNullableInt) this.customIntervalDays, @JsonKey(fromJson: _toInt) required this.graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) required this.fineType, @JsonKey(fromJson: _toInt) required this.fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) required this.payoutMode, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) required this.winnerSelectionTiming, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) required final  List<GroupPaymentMethodModel> paymentMethods, @JsonKey(fromJson: _toInt) required this.roundSize, @JsonKey(unknownEnumValue: StartPolicyModel.unknown) required this.startPolicy, this.startAt, @JsonKey(fromJson: _toNullableInt) this.minToStart, @JsonKey(fromJson: _toInt) required this.requiredToStart, required this.readiness, required this.createdAt, required this.updatedAt}): _paymentMethods = paymentMethods;
  factory _GroupRulesModel.fromJson(Map<String, dynamic> json) => _$GroupRulesModelFromJson(json);

@override final  String groupId;
@override@JsonKey(fromJson: _toInt) final  int contributionAmount;
@override@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) final  GroupRuleFrequencyModel frequency;
@override@JsonKey(fromJson: _toNullableInt) final  int? customIntervalDays;
@override@JsonKey(fromJson: _toInt) final  int graceDays;
@override@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) final  GroupRuleFineTypeModel fineType;
@override@JsonKey(fromJson: _toInt) final  int fineAmount;
@override@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) final  GroupRulePayoutModeModel payoutMode;
@override@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) final  WinnerSelectionTimingModel winnerSelectionTiming;
 final  List<GroupPaymentMethodModel> _paymentMethods;
@override@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> get paymentMethods {
  if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentMethods);
}

@override@JsonKey(fromJson: _toInt) final  int roundSize;
@override@JsonKey(unknownEnumValue: StartPolicyModel.unknown) final  StartPolicyModel startPolicy;
@override final  DateTime? startAt;
@override@JsonKey(fromJson: _toNullableInt) final  int? minToStart;
@override@JsonKey(fromJson: _toInt) final  int requiredToStart;
@override final  GroupStartReadinessModel readiness;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupRulesModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.fineType, fineType) || other.fineType == fineType)&&(identical(other.fineAmount, fineAmount) || other.fineAmount == fineAmount)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&(identical(other.winnerSelectionTiming, winnerSelectionTiming) || other.winnerSelectionTiming == winnerSelectionTiming)&&const DeepCollectionEquality().equals(other._paymentMethods, _paymentMethods)&&(identical(other.roundSize, roundSize) || other.roundSize == roundSize)&&(identical(other.startPolicy, startPolicy) || other.startPolicy == startPolicy)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.minToStart, minToStart) || other.minToStart == minToStart)&&(identical(other.requiredToStart, requiredToStart) || other.requiredToStart == requiredToStart)&&(identical(other.readiness, readiness) || other.readiness == readiness)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,contributionAmount,frequency,customIntervalDays,graceDays,fineType,fineAmount,payoutMode,winnerSelectionTiming,const DeepCollectionEquality().hash(_paymentMethods),roundSize,startPolicy,startAt,minToStart,requiredToStart,readiness,createdAt,updatedAt);

@override
String toString() {
  return 'GroupRulesModel(groupId: $groupId, contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, graceDays: $graceDays, fineType: $fineType, fineAmount: $fineAmount, payoutMode: $payoutMode, winnerSelectionTiming: $winnerSelectionTiming, paymentMethods: $paymentMethods, roundSize: $roundSize, startPolicy: $startPolicy, startAt: $startAt, minToStart: $minToStart, requiredToStart: $requiredToStart, readiness: $readiness, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GroupRulesModelCopyWith<$Res> implements $GroupRulesModelCopyWith<$Res> {
  factory _$GroupRulesModelCopyWith(_GroupRulesModel value, $Res Function(_GroupRulesModel) _then) = __$GroupRulesModelCopyWithImpl;
@override @useResult
$Res call({
 String groupId,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel frequency,@JsonKey(fromJson: _toNullableInt) int? customIntervalDays,@JsonKey(fromJson: _toInt) int graceDays,@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel fineType,@JsonKey(fromJson: _toInt) int fineAmount,@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel payoutMode,@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) WinnerSelectionTimingModel winnerSelectionTiming,@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> paymentMethods,@JsonKey(fromJson: _toInt) int roundSize,@JsonKey(unknownEnumValue: StartPolicyModel.unknown) StartPolicyModel startPolicy, DateTime? startAt,@JsonKey(fromJson: _toNullableInt) int? minToStart,@JsonKey(fromJson: _toInt) int requiredToStart, GroupStartReadinessModel readiness, DateTime createdAt, DateTime updatedAt
});


@override $GroupStartReadinessModelCopyWith<$Res> get readiness;

}
/// @nodoc
class __$GroupRulesModelCopyWithImpl<$Res>
    implements _$GroupRulesModelCopyWith<$Res> {
  __$GroupRulesModelCopyWithImpl(this._self, this._then);

  final _GroupRulesModel _self;
  final $Res Function(_GroupRulesModel) _then;

/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? graceDays = null,Object? fineType = null,Object? fineAmount = null,Object? payoutMode = null,Object? winnerSelectionTiming = null,Object? paymentMethods = null,Object? roundSize = null,Object? startPolicy = null,Object? startAt = freezed,Object? minToStart = freezed,Object? requiredToStart = null,Object? readiness = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_GroupRulesModel(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupRuleFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,fineType: null == fineType ? _self.fineType : fineType // ignore: cast_nullable_to_non_nullable
as GroupRuleFineTypeModel,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as int,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as GroupRulePayoutModeModel,winnerSelectionTiming: null == winnerSelectionTiming ? _self.winnerSelectionTiming : winnerSelectionTiming // ignore: cast_nullable_to_non_nullable
as WinnerSelectionTimingModel,paymentMethods: null == paymentMethods ? _self._paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<GroupPaymentMethodModel>,roundSize: null == roundSize ? _self.roundSize : roundSize // ignore: cast_nullable_to_non_nullable
as int,startPolicy: null == startPolicy ? _self.startPolicy : startPolicy // ignore: cast_nullable_to_non_nullable
as StartPolicyModel,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,minToStart: freezed == minToStart ? _self.minToStart : minToStart // ignore: cast_nullable_to_non_nullable
as int?,requiredToStart: null == requiredToStart ? _self.requiredToStart : requiredToStart // ignore: cast_nullable_to_non_nullable
as int,readiness: null == readiness ? _self.readiness : readiness // ignore: cast_nullable_to_non_nullable
as GroupStartReadinessModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of GroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupStartReadinessModelCopyWith<$Res> get readiness {
  
  return $GroupStartReadinessModelCopyWith<$Res>(_self.readiness, (value) {
    return _then(_self.copyWith(readiness: value));
  });
}
}

// dart format on
