// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_group_rules_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateGroupRulesRequest {

 int get contributionAmount;@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel get frequency; int? get customIntervalDays; int get graceDays;@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel get fineType; int get fineAmount;@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel get payoutMode;@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> get paymentMethods; bool get requiresMemberVerification; bool get strictCollection;
/// Create a copy of UpdateGroupRulesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateGroupRulesRequestCopyWith<UpdateGroupRulesRequest> get copyWith => _$UpdateGroupRulesRequestCopyWithImpl<UpdateGroupRulesRequest>(this as UpdateGroupRulesRequest, _$identity);

  /// Serializes this UpdateGroupRulesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGroupRulesRequest&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.fineType, fineType) || other.fineType == fineType)&&(identical(other.fineAmount, fineAmount) || other.fineAmount == fineAmount)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&const DeepCollectionEquality().equals(other.paymentMethods, paymentMethods)&&(identical(other.requiresMemberVerification, requiresMemberVerification) || other.requiresMemberVerification == requiresMemberVerification)&&(identical(other.strictCollection, strictCollection) || other.strictCollection == strictCollection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionAmount,frequency,customIntervalDays,graceDays,fineType,fineAmount,payoutMode,const DeepCollectionEquality().hash(paymentMethods),requiresMemberVerification,strictCollection);

@override
String toString() {
  return 'UpdateGroupRulesRequest(contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, graceDays: $graceDays, fineType: $fineType, fineAmount: $fineAmount, payoutMode: $payoutMode, paymentMethods: $paymentMethods, requiresMemberVerification: $requiresMemberVerification, strictCollection: $strictCollection)';
}


}

/// @nodoc
abstract mixin class $UpdateGroupRulesRequestCopyWith<$Res>  {
  factory $UpdateGroupRulesRequestCopyWith(UpdateGroupRulesRequest value, $Res Function(UpdateGroupRulesRequest) _then) = _$UpdateGroupRulesRequestCopyWithImpl;
@useResult
$Res call({
 int contributionAmount,@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel frequency, int? customIntervalDays, int graceDays,@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel fineType, int fineAmount,@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel payoutMode,@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> paymentMethods, bool requiresMemberVerification, bool strictCollection
});




}
/// @nodoc
class _$UpdateGroupRulesRequestCopyWithImpl<$Res>
    implements $UpdateGroupRulesRequestCopyWith<$Res> {
  _$UpdateGroupRulesRequestCopyWithImpl(this._self, this._then);

  final UpdateGroupRulesRequest _self;
  final $Res Function(UpdateGroupRulesRequest) _then;

/// Create a copy of UpdateGroupRulesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? graceDays = null,Object? fineType = null,Object? fineAmount = null,Object? payoutMode = null,Object? paymentMethods = null,Object? requiresMemberVerification = null,Object? strictCollection = null,}) {
  return _then(_self.copyWith(
contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupRuleFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,fineType: null == fineType ? _self.fineType : fineType // ignore: cast_nullable_to_non_nullable
as GroupRuleFineTypeModel,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as int,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as GroupRulePayoutModeModel,paymentMethods: null == paymentMethods ? _self.paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<GroupPaymentMethodModel>,requiresMemberVerification: null == requiresMemberVerification ? _self.requiresMemberVerification : requiresMemberVerification // ignore: cast_nullable_to_non_nullable
as bool,strictCollection: null == strictCollection ? _self.strictCollection : strictCollection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateGroupRulesRequest].
extension UpdateGroupRulesRequestPatterns on UpdateGroupRulesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateGroupRulesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateGroupRulesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateGroupRulesRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateGroupRulesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateGroupRulesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateGroupRulesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency,  int? customIntervalDays,  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType,  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods,  bool requiresMemberVerification,  bool strictCollection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateGroupRulesRequest() when $default != null:
return $default(_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.paymentMethods,_that.requiresMemberVerification,_that.strictCollection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency,  int? customIntervalDays,  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType,  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods,  bool requiresMemberVerification,  bool strictCollection)  $default,) {final _that = this;
switch (_that) {
case _UpdateGroupRulesRequest():
return $default(_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.paymentMethods,_that.requiresMemberVerification,_that.strictCollection);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown)  GroupRuleFrequencyModel frequency,  int? customIntervalDays,  int graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown)  GroupRuleFineTypeModel fineType,  int fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown)  GroupRulePayoutModeModel payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson)  List<GroupPaymentMethodModel> paymentMethods,  bool requiresMemberVerification,  bool strictCollection)?  $default,) {final _that = this;
switch (_that) {
case _UpdateGroupRulesRequest() when $default != null:
return $default(_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.graceDays,_that.fineType,_that.fineAmount,_that.payoutMode,_that.paymentMethods,_that.requiresMemberVerification,_that.strictCollection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateGroupRulesRequest implements UpdateGroupRulesRequest {
  const _UpdateGroupRulesRequest({required this.contributionAmount, @JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) required this.frequency, this.customIntervalDays, required this.graceDays, @JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) required this.fineType, required this.fineAmount, @JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) required this.payoutMode, @JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) required final  List<GroupPaymentMethodModel> paymentMethods, required this.requiresMemberVerification, required this.strictCollection}): _paymentMethods = paymentMethods;
  factory _UpdateGroupRulesRequest.fromJson(Map<String, dynamic> json) => _$UpdateGroupRulesRequestFromJson(json);

@override final  int contributionAmount;
@override@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) final  GroupRuleFrequencyModel frequency;
@override final  int? customIntervalDays;
@override final  int graceDays;
@override@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) final  GroupRuleFineTypeModel fineType;
@override final  int fineAmount;
@override@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) final  GroupRulePayoutModeModel payoutMode;
 final  List<GroupPaymentMethodModel> _paymentMethods;
@override@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> get paymentMethods {
  if (_paymentMethods is EqualUnmodifiableListView) return _paymentMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentMethods);
}

@override final  bool requiresMemberVerification;
@override final  bool strictCollection;

/// Create a copy of UpdateGroupRulesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateGroupRulesRequestCopyWith<_UpdateGroupRulesRequest> get copyWith => __$UpdateGroupRulesRequestCopyWithImpl<_UpdateGroupRulesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateGroupRulesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateGroupRulesRequest&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.fineType, fineType) || other.fineType == fineType)&&(identical(other.fineAmount, fineAmount) || other.fineAmount == fineAmount)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&const DeepCollectionEquality().equals(other._paymentMethods, _paymentMethods)&&(identical(other.requiresMemberVerification, requiresMemberVerification) || other.requiresMemberVerification == requiresMemberVerification)&&(identical(other.strictCollection, strictCollection) || other.strictCollection == strictCollection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionAmount,frequency,customIntervalDays,graceDays,fineType,fineAmount,payoutMode,const DeepCollectionEquality().hash(_paymentMethods),requiresMemberVerification,strictCollection);

@override
String toString() {
  return 'UpdateGroupRulesRequest(contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, graceDays: $graceDays, fineType: $fineType, fineAmount: $fineAmount, payoutMode: $payoutMode, paymentMethods: $paymentMethods, requiresMemberVerification: $requiresMemberVerification, strictCollection: $strictCollection)';
}


}

/// @nodoc
abstract mixin class _$UpdateGroupRulesRequestCopyWith<$Res> implements $UpdateGroupRulesRequestCopyWith<$Res> {
  factory _$UpdateGroupRulesRequestCopyWith(_UpdateGroupRulesRequest value, $Res Function(_UpdateGroupRulesRequest) _then) = __$UpdateGroupRulesRequestCopyWithImpl;
@override @useResult
$Res call({
 int contributionAmount,@JsonKey(unknownEnumValue: GroupRuleFrequencyModel.unknown) GroupRuleFrequencyModel frequency, int? customIntervalDays, int graceDays,@JsonKey(unknownEnumValue: GroupRuleFineTypeModel.unknown) GroupRuleFineTypeModel fineType, int fineAmount,@JsonKey(unknownEnumValue: GroupRulePayoutModeModel.unknown) GroupRulePayoutModeModel payoutMode,@JsonKey(fromJson: _paymentMethodsFromJson, toJson: _paymentMethodsToJson) List<GroupPaymentMethodModel> paymentMethods, bool requiresMemberVerification, bool strictCollection
});




}
/// @nodoc
class __$UpdateGroupRulesRequestCopyWithImpl<$Res>
    implements _$UpdateGroupRulesRequestCopyWith<$Res> {
  __$UpdateGroupRulesRequestCopyWithImpl(this._self, this._then);

  final _UpdateGroupRulesRequest _self;
  final $Res Function(_UpdateGroupRulesRequest) _then;

/// Create a copy of UpdateGroupRulesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? graceDays = null,Object? fineType = null,Object? fineAmount = null,Object? payoutMode = null,Object? paymentMethods = null,Object? requiresMemberVerification = null,Object? strictCollection = null,}) {
  return _then(_UpdateGroupRulesRequest(
contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupRuleFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,fineType: null == fineType ? _self.fineType : fineType // ignore: cast_nullable_to_non_nullable
as GroupRuleFineTypeModel,fineAmount: null == fineAmount ? _self.fineAmount : fineAmount // ignore: cast_nullable_to_non_nullable
as int,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as GroupRulePayoutModeModel,paymentMethods: null == paymentMethods ? _self._paymentMethods : paymentMethods // ignore: cast_nullable_to_non_nullable
as List<GroupPaymentMethodModel>,requiresMemberVerification: null == requiresMemberVerification ? _self.requiresMemberVerification : requiresMemberVerification // ignore: cast_nullable_to_non_nullable
as bool,strictCollection: null == strictCollection ? _self.strictCollection : strictCollection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
