// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicGroupRulesModel {

@JsonKey(fromJson: _toInt) int get contributionAmount;@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) PublicGroupFrequencyModel get frequency; int? get customIntervalDays;@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) PublicGroupPayoutModeModel get payoutMode;@JsonKey(fromJson: _toInt) int get roundSize;@JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown) PublicGroupStartPolicyModel get startPolicy; DateTime? get startAt; int? get minToStart;@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) WinnerSelectionTimingModel get winnerSelectionTiming;
/// Create a copy of PublicGroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicGroupRulesModelCopyWith<PublicGroupRulesModel> get copyWith => _$PublicGroupRulesModelCopyWithImpl<PublicGroupRulesModel>(this as PublicGroupRulesModel, _$identity);

  /// Serializes this PublicGroupRulesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicGroupRulesModel&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&(identical(other.roundSize, roundSize) || other.roundSize == roundSize)&&(identical(other.startPolicy, startPolicy) || other.startPolicy == startPolicy)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.minToStart, minToStart) || other.minToStart == minToStart)&&(identical(other.winnerSelectionTiming, winnerSelectionTiming) || other.winnerSelectionTiming == winnerSelectionTiming));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionAmount,frequency,customIntervalDays,payoutMode,roundSize,startPolicy,startAt,minToStart,winnerSelectionTiming);

@override
String toString() {
  return 'PublicGroupRulesModel(contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, payoutMode: $payoutMode, roundSize: $roundSize, startPolicy: $startPolicy, startAt: $startAt, minToStart: $minToStart, winnerSelectionTiming: $winnerSelectionTiming)';
}


}

/// @nodoc
abstract mixin class $PublicGroupRulesModelCopyWith<$Res>  {
  factory $PublicGroupRulesModelCopyWith(PublicGroupRulesModel value, $Res Function(PublicGroupRulesModel) _then) = _$PublicGroupRulesModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) PublicGroupFrequencyModel frequency, int? customIntervalDays,@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) PublicGroupPayoutModeModel payoutMode,@JsonKey(fromJson: _toInt) int roundSize,@JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown) PublicGroupStartPolicyModel startPolicy, DateTime? startAt, int? minToStart,@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) WinnerSelectionTimingModel winnerSelectionTiming
});




}
/// @nodoc
class _$PublicGroupRulesModelCopyWithImpl<$Res>
    implements $PublicGroupRulesModelCopyWith<$Res> {
  _$PublicGroupRulesModelCopyWithImpl(this._self, this._then);

  final PublicGroupRulesModel _self;
  final $Res Function(PublicGroupRulesModel) _then;

/// Create a copy of PublicGroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? payoutMode = null,Object? roundSize = null,Object? startPolicy = null,Object? startAt = freezed,Object? minToStart = freezed,Object? winnerSelectionTiming = null,}) {
  return _then(_self.copyWith(
contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PublicGroupFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as PublicGroupPayoutModeModel,roundSize: null == roundSize ? _self.roundSize : roundSize // ignore: cast_nullable_to_non_nullable
as int,startPolicy: null == startPolicy ? _self.startPolicy : startPolicy // ignore: cast_nullable_to_non_nullable
as PublicGroupStartPolicyModel,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,minToStart: freezed == minToStart ? _self.minToStart : minToStart // ignore: cast_nullable_to_non_nullable
as int?,winnerSelectionTiming: null == winnerSelectionTiming ? _self.winnerSelectionTiming : winnerSelectionTiming // ignore: cast_nullable_to_non_nullable
as WinnerSelectionTimingModel,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicGroupRulesModel].
extension PublicGroupRulesModelPatterns on PublicGroupRulesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicGroupRulesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicGroupRulesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicGroupRulesModel value)  $default,){
final _that = this;
switch (_that) {
case _PublicGroupRulesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicGroupRulesModel value)?  $default,){
final _that = this;
switch (_that) {
case _PublicGroupRulesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)  PublicGroupFrequencyModel frequency,  int? customIntervalDays, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)  PublicGroupPayoutModeModel payoutMode, @JsonKey(fromJson: _toInt)  int roundSize, @JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown)  PublicGroupStartPolicyModel startPolicy,  DateTime? startAt,  int? minToStart, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown)  WinnerSelectionTimingModel winnerSelectionTiming)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicGroupRulesModel() when $default != null:
return $default(_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.payoutMode,_that.roundSize,_that.startPolicy,_that.startAt,_that.minToStart,_that.winnerSelectionTiming);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)  PublicGroupFrequencyModel frequency,  int? customIntervalDays, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)  PublicGroupPayoutModeModel payoutMode, @JsonKey(fromJson: _toInt)  int roundSize, @JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown)  PublicGroupStartPolicyModel startPolicy,  DateTime? startAt,  int? minToStart, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown)  WinnerSelectionTimingModel winnerSelectionTiming)  $default,) {final _that = this;
switch (_that) {
case _PublicGroupRulesModel():
return $default(_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.payoutMode,_that.roundSize,_that.startPolicy,_that.startAt,_that.minToStart,_that.winnerSelectionTiming);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)  PublicGroupFrequencyModel frequency,  int? customIntervalDays, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)  PublicGroupPayoutModeModel payoutMode, @JsonKey(fromJson: _toInt)  int roundSize, @JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown)  PublicGroupStartPolicyModel startPolicy,  DateTime? startAt,  int? minToStart, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown)  WinnerSelectionTimingModel winnerSelectionTiming)?  $default,) {final _that = this;
switch (_that) {
case _PublicGroupRulesModel() when $default != null:
return $default(_that.contributionAmount,_that.frequency,_that.customIntervalDays,_that.payoutMode,_that.roundSize,_that.startPolicy,_that.startAt,_that.minToStart,_that.winnerSelectionTiming);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicGroupRulesModel implements PublicGroupRulesModel {
  const _PublicGroupRulesModel({@JsonKey(fromJson: _toInt) required this.contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) required this.frequency, this.customIntervalDays, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) required this.payoutMode, @JsonKey(fromJson: _toInt) required this.roundSize, @JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown) required this.startPolicy, this.startAt, this.minToStart, @JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) required this.winnerSelectionTiming});
  factory _PublicGroupRulesModel.fromJson(Map<String, dynamic> json) => _$PublicGroupRulesModelFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int contributionAmount;
@override@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) final  PublicGroupFrequencyModel frequency;
@override final  int? customIntervalDays;
@override@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) final  PublicGroupPayoutModeModel payoutMode;
@override@JsonKey(fromJson: _toInt) final  int roundSize;
@override@JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown) final  PublicGroupStartPolicyModel startPolicy;
@override final  DateTime? startAt;
@override final  int? minToStart;
@override@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) final  WinnerSelectionTimingModel winnerSelectionTiming;

/// Create a copy of PublicGroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicGroupRulesModelCopyWith<_PublicGroupRulesModel> get copyWith => __$PublicGroupRulesModelCopyWithImpl<_PublicGroupRulesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicGroupRulesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicGroupRulesModel&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&(identical(other.roundSize, roundSize) || other.roundSize == roundSize)&&(identical(other.startPolicy, startPolicy) || other.startPolicy == startPolicy)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.minToStart, minToStart) || other.minToStart == minToStart)&&(identical(other.winnerSelectionTiming, winnerSelectionTiming) || other.winnerSelectionTiming == winnerSelectionTiming));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contributionAmount,frequency,customIntervalDays,payoutMode,roundSize,startPolicy,startAt,minToStart,winnerSelectionTiming);

@override
String toString() {
  return 'PublicGroupRulesModel(contributionAmount: $contributionAmount, frequency: $frequency, customIntervalDays: $customIntervalDays, payoutMode: $payoutMode, roundSize: $roundSize, startPolicy: $startPolicy, startAt: $startAt, minToStart: $minToStart, winnerSelectionTiming: $winnerSelectionTiming)';
}


}

/// @nodoc
abstract mixin class _$PublicGroupRulesModelCopyWith<$Res> implements $PublicGroupRulesModelCopyWith<$Res> {
  factory _$PublicGroupRulesModelCopyWith(_PublicGroupRulesModel value, $Res Function(_PublicGroupRulesModel) _then) = __$PublicGroupRulesModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) PublicGroupFrequencyModel frequency, int? customIntervalDays,@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) PublicGroupPayoutModeModel payoutMode,@JsonKey(fromJson: _toInt) int roundSize,@JsonKey(unknownEnumValue: PublicGroupStartPolicyModel.unknown) PublicGroupStartPolicyModel startPolicy, DateTime? startAt, int? minToStart,@JsonKey(unknownEnumValue: WinnerSelectionTimingModel.unknown) WinnerSelectionTimingModel winnerSelectionTiming
});




}
/// @nodoc
class __$PublicGroupRulesModelCopyWithImpl<$Res>
    implements _$PublicGroupRulesModelCopyWith<$Res> {
  __$PublicGroupRulesModelCopyWithImpl(this._self, this._then);

  final _PublicGroupRulesModel _self;
  final $Res Function(_PublicGroupRulesModel) _then;

/// Create a copy of PublicGroupRulesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contributionAmount = null,Object? frequency = null,Object? customIntervalDays = freezed,Object? payoutMode = null,Object? roundSize = null,Object? startPolicy = null,Object? startAt = freezed,Object? minToStart = freezed,Object? winnerSelectionTiming = null,}) {
  return _then(_PublicGroupRulesModel(
contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PublicGroupFrequencyModel,customIntervalDays: freezed == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int?,payoutMode: null == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as PublicGroupPayoutModeModel,roundSize: null == roundSize ? _self.roundSize : roundSize // ignore: cast_nullable_to_non_nullable
as int,startPolicy: null == startPolicy ? _self.startPolicy : startPolicy // ignore: cast_nullable_to_non_nullable
as PublicGroupStartPolicyModel,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,minToStart: freezed == minToStart ? _self.minToStart : minToStart // ignore: cast_nullable_to_non_nullable
as int?,winnerSelectionTiming: null == winnerSelectionTiming ? _self.winnerSelectionTiming : winnerSelectionTiming // ignore: cast_nullable_to_non_nullable
as WinnerSelectionTimingModel,
  ));
}


}


/// @nodoc
mixin _$PublicGroupModel {

 String get id; String get name; String? get description; String get currency;@JsonKey(fromJson: _toInt) int get contributionAmount;@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) PublicGroupFrequencyModel get frequency;@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) PublicGroupPayoutModeModel? get payoutMode;@JsonKey(fromJson: _toInt) int get memberCount; bool get alreadyStarted; bool? get rulesetConfigured; bool? get isCurrentUserMember; PublicGroupRulesModel? get rules;
/// Create a copy of PublicGroupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicGroupModelCopyWith<PublicGroupModel> get copyWith => _$PublicGroupModelCopyWithImpl<PublicGroupModel>(this as PublicGroupModel, _$identity);

  /// Serializes this PublicGroupModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.alreadyStarted, alreadyStarted) || other.alreadyStarted == alreadyStarted)&&(identical(other.rulesetConfigured, rulesetConfigured) || other.rulesetConfigured == rulesetConfigured)&&(identical(other.isCurrentUserMember, isCurrentUserMember) || other.isCurrentUserMember == isCurrentUserMember)&&(identical(other.rules, rules) || other.rules == rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,currency,contributionAmount,frequency,payoutMode,memberCount,alreadyStarted,rulesetConfigured,isCurrentUserMember,rules);

@override
String toString() {
  return 'PublicGroupModel(id: $id, name: $name, description: $description, currency: $currency, contributionAmount: $contributionAmount, frequency: $frequency, payoutMode: $payoutMode, memberCount: $memberCount, alreadyStarted: $alreadyStarted, rulesetConfigured: $rulesetConfigured, isCurrentUserMember: $isCurrentUserMember, rules: $rules)';
}


}

/// @nodoc
abstract mixin class $PublicGroupModelCopyWith<$Res>  {
  factory $PublicGroupModelCopyWith(PublicGroupModel value, $Res Function(PublicGroupModel) _then) = _$PublicGroupModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String currency,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) PublicGroupFrequencyModel frequency,@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) PublicGroupPayoutModeModel? payoutMode,@JsonKey(fromJson: _toInt) int memberCount, bool alreadyStarted, bool? rulesetConfigured, bool? isCurrentUserMember, PublicGroupRulesModel? rules
});


$PublicGroupRulesModelCopyWith<$Res>? get rules;

}
/// @nodoc
class _$PublicGroupModelCopyWithImpl<$Res>
    implements $PublicGroupModelCopyWith<$Res> {
  _$PublicGroupModelCopyWithImpl(this._self, this._then);

  final PublicGroupModel _self;
  final $Res Function(PublicGroupModel) _then;

/// Create a copy of PublicGroupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? currency = null,Object? contributionAmount = null,Object? frequency = null,Object? payoutMode = freezed,Object? memberCount = null,Object? alreadyStarted = null,Object? rulesetConfigured = freezed,Object? isCurrentUserMember = freezed,Object? rules = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PublicGroupFrequencyModel,payoutMode: freezed == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as PublicGroupPayoutModeModel?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,alreadyStarted: null == alreadyStarted ? _self.alreadyStarted : alreadyStarted // ignore: cast_nullable_to_non_nullable
as bool,rulesetConfigured: freezed == rulesetConfigured ? _self.rulesetConfigured : rulesetConfigured // ignore: cast_nullable_to_non_nullable
as bool?,isCurrentUserMember: freezed == isCurrentUserMember ? _self.isCurrentUserMember : isCurrentUserMember // ignore: cast_nullable_to_non_nullable
as bool?,rules: freezed == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as PublicGroupRulesModel?,
  ));
}
/// Create a copy of PublicGroupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicGroupRulesModelCopyWith<$Res>? get rules {
    if (_self.rules == null) {
    return null;
  }

  return $PublicGroupRulesModelCopyWith<$Res>(_self.rules!, (value) {
    return _then(_self.copyWith(rules: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicGroupModel].
extension PublicGroupModelPatterns on PublicGroupModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicGroupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicGroupModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicGroupModel value)  $default,){
final _that = this;
switch (_that) {
case _PublicGroupModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicGroupModel value)?  $default,){
final _that = this;
switch (_that) {
case _PublicGroupModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String currency, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)  PublicGroupFrequencyModel frequency, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)  PublicGroupPayoutModeModel? payoutMode, @JsonKey(fromJson: _toInt)  int memberCount,  bool alreadyStarted,  bool? rulesetConfigured,  bool? isCurrentUserMember,  PublicGroupRulesModel? rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicGroupModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.currency,_that.contributionAmount,_that.frequency,_that.payoutMode,_that.memberCount,_that.alreadyStarted,_that.rulesetConfigured,_that.isCurrentUserMember,_that.rules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String currency, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)  PublicGroupFrequencyModel frequency, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)  PublicGroupPayoutModeModel? payoutMode, @JsonKey(fromJson: _toInt)  int memberCount,  bool alreadyStarted,  bool? rulesetConfigured,  bool? isCurrentUserMember,  PublicGroupRulesModel? rules)  $default,) {final _that = this;
switch (_that) {
case _PublicGroupModel():
return $default(_that.id,_that.name,_that.description,_that.currency,_that.contributionAmount,_that.frequency,_that.payoutMode,_that.memberCount,_that.alreadyStarted,_that.rulesetConfigured,_that.isCurrentUserMember,_that.rules);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String currency, @JsonKey(fromJson: _toInt)  int contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown)  PublicGroupFrequencyModel frequency, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown)  PublicGroupPayoutModeModel? payoutMode, @JsonKey(fromJson: _toInt)  int memberCount,  bool alreadyStarted,  bool? rulesetConfigured,  bool? isCurrentUserMember,  PublicGroupRulesModel? rules)?  $default,) {final _that = this;
switch (_that) {
case _PublicGroupModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.currency,_that.contributionAmount,_that.frequency,_that.payoutMode,_that.memberCount,_that.alreadyStarted,_that.rulesetConfigured,_that.isCurrentUserMember,_that.rules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicGroupModel implements PublicGroupModel {
  const _PublicGroupModel({required this.id, required this.name, this.description, required this.currency, @JsonKey(fromJson: _toInt) required this.contributionAmount, @JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) required this.frequency, @JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) this.payoutMode, @JsonKey(fromJson: _toInt) required this.memberCount, required this.alreadyStarted, this.rulesetConfigured, this.isCurrentUserMember, this.rules});
  factory _PublicGroupModel.fromJson(Map<String, dynamic> json) => _$PublicGroupModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String currency;
@override@JsonKey(fromJson: _toInt) final  int contributionAmount;
@override@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) final  PublicGroupFrequencyModel frequency;
@override@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) final  PublicGroupPayoutModeModel? payoutMode;
@override@JsonKey(fromJson: _toInt) final  int memberCount;
@override final  bool alreadyStarted;
@override final  bool? rulesetConfigured;
@override final  bool? isCurrentUserMember;
@override final  PublicGroupRulesModel? rules;

/// Create a copy of PublicGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicGroupModelCopyWith<_PublicGroupModel> get copyWith => __$PublicGroupModelCopyWithImpl<_PublicGroupModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicGroupModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.payoutMode, payoutMode) || other.payoutMode == payoutMode)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.alreadyStarted, alreadyStarted) || other.alreadyStarted == alreadyStarted)&&(identical(other.rulesetConfigured, rulesetConfigured) || other.rulesetConfigured == rulesetConfigured)&&(identical(other.isCurrentUserMember, isCurrentUserMember) || other.isCurrentUserMember == isCurrentUserMember)&&(identical(other.rules, rules) || other.rules == rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,currency,contributionAmount,frequency,payoutMode,memberCount,alreadyStarted,rulesetConfigured,isCurrentUserMember,rules);

@override
String toString() {
  return 'PublicGroupModel(id: $id, name: $name, description: $description, currency: $currency, contributionAmount: $contributionAmount, frequency: $frequency, payoutMode: $payoutMode, memberCount: $memberCount, alreadyStarted: $alreadyStarted, rulesetConfigured: $rulesetConfigured, isCurrentUserMember: $isCurrentUserMember, rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$PublicGroupModelCopyWith<$Res> implements $PublicGroupModelCopyWith<$Res> {
  factory _$PublicGroupModelCopyWith(_PublicGroupModel value, $Res Function(_PublicGroupModel) _then) = __$PublicGroupModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String currency,@JsonKey(fromJson: _toInt) int contributionAmount,@JsonKey(unknownEnumValue: PublicGroupFrequencyModel.unknown) PublicGroupFrequencyModel frequency,@JsonKey(unknownEnumValue: PublicGroupPayoutModeModel.unknown) PublicGroupPayoutModeModel? payoutMode,@JsonKey(fromJson: _toInt) int memberCount, bool alreadyStarted, bool? rulesetConfigured, bool? isCurrentUserMember, PublicGroupRulesModel? rules
});


@override $PublicGroupRulesModelCopyWith<$Res>? get rules;

}
/// @nodoc
class __$PublicGroupModelCopyWithImpl<$Res>
    implements _$PublicGroupModelCopyWith<$Res> {
  __$PublicGroupModelCopyWithImpl(this._self, this._then);

  final _PublicGroupModel _self;
  final $Res Function(_PublicGroupModel) _then;

/// Create a copy of PublicGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? currency = null,Object? contributionAmount = null,Object? frequency = null,Object? payoutMode = freezed,Object? memberCount = null,Object? alreadyStarted = null,Object? rulesetConfigured = freezed,Object? isCurrentUserMember = freezed,Object? rules = freezed,}) {
  return _then(_PublicGroupModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: null == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PublicGroupFrequencyModel,payoutMode: freezed == payoutMode ? _self.payoutMode : payoutMode // ignore: cast_nullable_to_non_nullable
as PublicGroupPayoutModeModel?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,alreadyStarted: null == alreadyStarted ? _self.alreadyStarted : alreadyStarted // ignore: cast_nullable_to_non_nullable
as bool,rulesetConfigured: freezed == rulesetConfigured ? _self.rulesetConfigured : rulesetConfigured // ignore: cast_nullable_to_non_nullable
as bool?,isCurrentUserMember: freezed == isCurrentUserMember ? _self.isCurrentUserMember : isCurrentUserMember // ignore: cast_nullable_to_non_nullable
as bool?,rules: freezed == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as PublicGroupRulesModel?,
  ));
}

/// Create a copy of PublicGroupModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicGroupRulesModelCopyWith<$Res>? get rules {
    if (_self.rules == null) {
    return null;
  }

  return $PublicGroupRulesModelCopyWith<$Res>(_self.rules!, (value) {
    return _then(_self.copyWith(rules: value));
  });
}
}

// dart format on
