// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_group_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateGroupRequest {

 String get name; int? get contributionAmount;@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) GroupFrequencyModel? get frequency;@JsonKey(toJson: _nullableDateToIsoString) DateTime? get startDate; String get currency;
/// Create a copy of CreateGroupRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGroupRequestCopyWith<CreateGroupRequest> get copyWith => _$CreateGroupRequestCopyWithImpl<CreateGroupRequest>(this as CreateGroupRequest, _$identity);

  /// Serializes this CreateGroupRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGroupRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,contributionAmount,frequency,startDate,currency);

@override
String toString() {
  return 'CreateGroupRequest(name: $name, contributionAmount: $contributionAmount, frequency: $frequency, startDate: $startDate, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $CreateGroupRequestCopyWith<$Res>  {
  factory $CreateGroupRequestCopyWith(CreateGroupRequest value, $Res Function(CreateGroupRequest) _then) = _$CreateGroupRequestCopyWithImpl;
@useResult
$Res call({
 String name, int? contributionAmount,@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) GroupFrequencyModel? frequency,@JsonKey(toJson: _nullableDateToIsoString) DateTime? startDate, String currency
});




}
/// @nodoc
class _$CreateGroupRequestCopyWithImpl<$Res>
    implements $CreateGroupRequestCopyWith<$Res> {
  _$CreateGroupRequestCopyWithImpl(this._self, this._then);

  final CreateGroupRequest _self;
  final $Res Function(CreateGroupRequest) _then;

/// Create a copy of CreateGroupRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? contributionAmount = freezed,Object? frequency = freezed,Object? startDate = freezed,Object? currency = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: freezed == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupFrequencyModel?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGroupRequest].
extension CreateGroupRequestPatterns on CreateGroupRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGroupRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGroupRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGroupRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateGroupRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGroupRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGroupRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int? contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)  GroupFrequencyModel? frequency, @JsonKey(toJson: _nullableDateToIsoString)  DateTime? startDate,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGroupRequest() when $default != null:
return $default(_that.name,_that.contributionAmount,_that.frequency,_that.startDate,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int? contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)  GroupFrequencyModel? frequency, @JsonKey(toJson: _nullableDateToIsoString)  DateTime? startDate,  String currency)  $default,) {final _that = this;
switch (_that) {
case _CreateGroupRequest():
return $default(_that.name,_that.contributionAmount,_that.frequency,_that.startDate,_that.currency);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int? contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)  GroupFrequencyModel? frequency, @JsonKey(toJson: _nullableDateToIsoString)  DateTime? startDate,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _CreateGroupRequest() when $default != null:
return $default(_that.name,_that.contributionAmount,_that.frequency,_that.startDate,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateGroupRequest implements CreateGroupRequest {
  const _CreateGroupRequest({required this.name, this.contributionAmount, @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) this.frequency, @JsonKey(toJson: _nullableDateToIsoString) this.startDate, this.currency = 'ETB'});
  factory _CreateGroupRequest.fromJson(Map<String, dynamic> json) => _$CreateGroupRequestFromJson(json);

@override final  String name;
@override final  int? contributionAmount;
@override@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) final  GroupFrequencyModel? frequency;
@override@JsonKey(toJson: _nullableDateToIsoString) final  DateTime? startDate;
@override@JsonKey() final  String currency;

/// Create a copy of CreateGroupRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGroupRequestCopyWith<_CreateGroupRequest> get copyWith => __$CreateGroupRequestCopyWithImpl<_CreateGroupRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGroupRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGroupRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.contributionAmount, contributionAmount) || other.contributionAmount == contributionAmount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,contributionAmount,frequency,startDate,currency);

@override
String toString() {
  return 'CreateGroupRequest(name: $name, contributionAmount: $contributionAmount, frequency: $frequency, startDate: $startDate, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$CreateGroupRequestCopyWith<$Res> implements $CreateGroupRequestCopyWith<$Res> {
  factory _$CreateGroupRequestCopyWith(_CreateGroupRequest value, $Res Function(_CreateGroupRequest) _then) = __$CreateGroupRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, int? contributionAmount,@JsonKey(unknownEnumValue: GroupFrequencyModel.unknown) GroupFrequencyModel? frequency,@JsonKey(toJson: _nullableDateToIsoString) DateTime? startDate, String currency
});




}
/// @nodoc
class __$CreateGroupRequestCopyWithImpl<$Res>
    implements _$CreateGroupRequestCopyWith<$Res> {
  __$CreateGroupRequestCopyWithImpl(this._self, this._then);

  final _CreateGroupRequest _self;
  final $Res Function(_CreateGroupRequest) _then;

/// Create a copy of CreateGroupRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? contributionAmount = freezed,Object? frequency = freezed,Object? startDate = freezed,Object? currency = null,}) {
  return _then(_CreateGroupRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,contributionAmount: freezed == contributionAmount ? _self.contributionAmount : contributionAmount // ignore: cast_nullable_to_non_nullable
as int?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as GroupFrequencyModel?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
