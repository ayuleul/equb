// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reputation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AllowedPublicEqubLimitsModel {

 int? get maxMembers;@JsonKey(fromJson: _toNullableInt) int? get maxContributionAmount; int? get maxDurationDays; int? get maxActivePublicEqubs;
/// Create a copy of AllowedPublicEqubLimitsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllowedPublicEqubLimitsModelCopyWith<AllowedPublicEqubLimitsModel> get copyWith => _$AllowedPublicEqubLimitsModelCopyWithImpl<AllowedPublicEqubLimitsModel>(this as AllowedPublicEqubLimitsModel, _$identity);

  /// Serializes this AllowedPublicEqubLimitsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllowedPublicEqubLimitsModel&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.maxContributionAmount, maxContributionAmount) || other.maxContributionAmount == maxContributionAmount)&&(identical(other.maxDurationDays, maxDurationDays) || other.maxDurationDays == maxDurationDays)&&(identical(other.maxActivePublicEqubs, maxActivePublicEqubs) || other.maxActivePublicEqubs == maxActivePublicEqubs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxMembers,maxContributionAmount,maxDurationDays,maxActivePublicEqubs);

@override
String toString() {
  return 'AllowedPublicEqubLimitsModel(maxMembers: $maxMembers, maxContributionAmount: $maxContributionAmount, maxDurationDays: $maxDurationDays, maxActivePublicEqubs: $maxActivePublicEqubs)';
}


}

/// @nodoc
abstract mixin class $AllowedPublicEqubLimitsModelCopyWith<$Res>  {
  factory $AllowedPublicEqubLimitsModelCopyWith(AllowedPublicEqubLimitsModel value, $Res Function(AllowedPublicEqubLimitsModel) _then) = _$AllowedPublicEqubLimitsModelCopyWithImpl;
@useResult
$Res call({
 int? maxMembers,@JsonKey(fromJson: _toNullableInt) int? maxContributionAmount, int? maxDurationDays, int? maxActivePublicEqubs
});




}
/// @nodoc
class _$AllowedPublicEqubLimitsModelCopyWithImpl<$Res>
    implements $AllowedPublicEqubLimitsModelCopyWith<$Res> {
  _$AllowedPublicEqubLimitsModelCopyWithImpl(this._self, this._then);

  final AllowedPublicEqubLimitsModel _self;
  final $Res Function(AllowedPublicEqubLimitsModel) _then;

/// Create a copy of AllowedPublicEqubLimitsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxMembers = freezed,Object? maxContributionAmount = freezed,Object? maxDurationDays = freezed,Object? maxActivePublicEqubs = freezed,}) {
  return _then(_self.copyWith(
maxMembers: freezed == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int?,maxContributionAmount: freezed == maxContributionAmount ? _self.maxContributionAmount : maxContributionAmount // ignore: cast_nullable_to_non_nullable
as int?,maxDurationDays: freezed == maxDurationDays ? _self.maxDurationDays : maxDurationDays // ignore: cast_nullable_to_non_nullable
as int?,maxActivePublicEqubs: freezed == maxActivePublicEqubs ? _self.maxActivePublicEqubs : maxActivePublicEqubs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AllowedPublicEqubLimitsModel].
extension AllowedPublicEqubLimitsModelPatterns on AllowedPublicEqubLimitsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllowedPublicEqubLimitsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllowedPublicEqubLimitsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllowedPublicEqubLimitsModel value)  $default,){
final _that = this;
switch (_that) {
case _AllowedPublicEqubLimitsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllowedPublicEqubLimitsModel value)?  $default,){
final _that = this;
switch (_that) {
case _AllowedPublicEqubLimitsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? maxMembers, @JsonKey(fromJson: _toNullableInt)  int? maxContributionAmount,  int? maxDurationDays,  int? maxActivePublicEqubs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllowedPublicEqubLimitsModel() when $default != null:
return $default(_that.maxMembers,_that.maxContributionAmount,_that.maxDurationDays,_that.maxActivePublicEqubs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? maxMembers, @JsonKey(fromJson: _toNullableInt)  int? maxContributionAmount,  int? maxDurationDays,  int? maxActivePublicEqubs)  $default,) {final _that = this;
switch (_that) {
case _AllowedPublicEqubLimitsModel():
return $default(_that.maxMembers,_that.maxContributionAmount,_that.maxDurationDays,_that.maxActivePublicEqubs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? maxMembers, @JsonKey(fromJson: _toNullableInt)  int? maxContributionAmount,  int? maxDurationDays,  int? maxActivePublicEqubs)?  $default,) {final _that = this;
switch (_that) {
case _AllowedPublicEqubLimitsModel() when $default != null:
return $default(_that.maxMembers,_that.maxContributionAmount,_that.maxDurationDays,_that.maxActivePublicEqubs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AllowedPublicEqubLimitsModel implements AllowedPublicEqubLimitsModel {
  const _AllowedPublicEqubLimitsModel({this.maxMembers, @JsonKey(fromJson: _toNullableInt) this.maxContributionAmount, this.maxDurationDays, this.maxActivePublicEqubs});
  factory _AllowedPublicEqubLimitsModel.fromJson(Map<String, dynamic> json) => _$AllowedPublicEqubLimitsModelFromJson(json);

@override final  int? maxMembers;
@override@JsonKey(fromJson: _toNullableInt) final  int? maxContributionAmount;
@override final  int? maxDurationDays;
@override final  int? maxActivePublicEqubs;

/// Create a copy of AllowedPublicEqubLimitsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllowedPublicEqubLimitsModelCopyWith<_AllowedPublicEqubLimitsModel> get copyWith => __$AllowedPublicEqubLimitsModelCopyWithImpl<_AllowedPublicEqubLimitsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AllowedPublicEqubLimitsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllowedPublicEqubLimitsModel&&(identical(other.maxMembers, maxMembers) || other.maxMembers == maxMembers)&&(identical(other.maxContributionAmount, maxContributionAmount) || other.maxContributionAmount == maxContributionAmount)&&(identical(other.maxDurationDays, maxDurationDays) || other.maxDurationDays == maxDurationDays)&&(identical(other.maxActivePublicEqubs, maxActivePublicEqubs) || other.maxActivePublicEqubs == maxActivePublicEqubs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxMembers,maxContributionAmount,maxDurationDays,maxActivePublicEqubs);

@override
String toString() {
  return 'AllowedPublicEqubLimitsModel(maxMembers: $maxMembers, maxContributionAmount: $maxContributionAmount, maxDurationDays: $maxDurationDays, maxActivePublicEqubs: $maxActivePublicEqubs)';
}


}

/// @nodoc
abstract mixin class _$AllowedPublicEqubLimitsModelCopyWith<$Res> implements $AllowedPublicEqubLimitsModelCopyWith<$Res> {
  factory _$AllowedPublicEqubLimitsModelCopyWith(_AllowedPublicEqubLimitsModel value, $Res Function(_AllowedPublicEqubLimitsModel) _then) = __$AllowedPublicEqubLimitsModelCopyWithImpl;
@override @useResult
$Res call({
 int? maxMembers,@JsonKey(fromJson: _toNullableInt) int? maxContributionAmount, int? maxDurationDays, int? maxActivePublicEqubs
});




}
/// @nodoc
class __$AllowedPublicEqubLimitsModelCopyWithImpl<$Res>
    implements _$AllowedPublicEqubLimitsModelCopyWith<$Res> {
  __$AllowedPublicEqubLimitsModelCopyWithImpl(this._self, this._then);

  final _AllowedPublicEqubLimitsModel _self;
  final $Res Function(_AllowedPublicEqubLimitsModel) _then;

/// Create a copy of AllowedPublicEqubLimitsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxMembers = freezed,Object? maxContributionAmount = freezed,Object? maxDurationDays = freezed,Object? maxActivePublicEqubs = freezed,}) {
  return _then(_AllowedPublicEqubLimitsModel(
maxMembers: freezed == maxMembers ? _self.maxMembers : maxMembers // ignore: cast_nullable_to_non_nullable
as int?,maxContributionAmount: freezed == maxContributionAmount ? _self.maxContributionAmount : maxContributionAmount // ignore: cast_nullable_to_non_nullable
as int?,maxDurationDays: freezed == maxDurationDays ? _self.maxDurationDays : maxDurationDays // ignore: cast_nullable_to_non_nullable
as int?,maxActivePublicEqubs: freezed == maxActivePublicEqubs ? _self.maxActivePublicEqubs : maxActivePublicEqubs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ReputationBadgeModel {

 String get code; String get label; String get description;
/// Create a copy of ReputationBadgeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReputationBadgeModelCopyWith<ReputationBadgeModel> get copyWith => _$ReputationBadgeModelCopyWithImpl<ReputationBadgeModel>(this as ReputationBadgeModel, _$identity);

  /// Serializes this ReputationBadgeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReputationBadgeModel&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,label,description);

@override
String toString() {
  return 'ReputationBadgeModel(code: $code, label: $label, description: $description)';
}


}

/// @nodoc
abstract mixin class $ReputationBadgeModelCopyWith<$Res>  {
  factory $ReputationBadgeModelCopyWith(ReputationBadgeModel value, $Res Function(ReputationBadgeModel) _then) = _$ReputationBadgeModelCopyWithImpl;
@useResult
$Res call({
 String code, String label, String description
});




}
/// @nodoc
class _$ReputationBadgeModelCopyWithImpl<$Res>
    implements $ReputationBadgeModelCopyWith<$Res> {
  _$ReputationBadgeModelCopyWithImpl(this._self, this._then);

  final ReputationBadgeModel _self;
  final $Res Function(ReputationBadgeModel) _then;

/// Create a copy of ReputationBadgeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? label = null,Object? description = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReputationBadgeModel].
extension ReputationBadgeModelPatterns on ReputationBadgeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReputationBadgeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReputationBadgeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReputationBadgeModel value)  $default,){
final _that = this;
switch (_that) {
case _ReputationBadgeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReputationBadgeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReputationBadgeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String label,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReputationBadgeModel() when $default != null:
return $default(_that.code,_that.label,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String label,  String description)  $default,) {final _that = this;
switch (_that) {
case _ReputationBadgeModel():
return $default(_that.code,_that.label,_that.description);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String label,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ReputationBadgeModel() when $default != null:
return $default(_that.code,_that.label,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReputationBadgeModel implements ReputationBadgeModel {
  const _ReputationBadgeModel({required this.code, required this.label, required this.description});
  factory _ReputationBadgeModel.fromJson(Map<String, dynamic> json) => _$ReputationBadgeModelFromJson(json);

@override final  String code;
@override final  String label;
@override final  String description;

/// Create a copy of ReputationBadgeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReputationBadgeModelCopyWith<_ReputationBadgeModel> get copyWith => __$ReputationBadgeModelCopyWithImpl<_ReputationBadgeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReputationBadgeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReputationBadgeModel&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,label,description);

@override
String toString() {
  return 'ReputationBadgeModel(code: $code, label: $label, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ReputationBadgeModelCopyWith<$Res> implements $ReputationBadgeModelCopyWith<$Res> {
  factory _$ReputationBadgeModelCopyWith(_ReputationBadgeModel value, $Res Function(_ReputationBadgeModel) _then) = __$ReputationBadgeModelCopyWithImpl;
@override @useResult
$Res call({
 String code, String label, String description
});




}
/// @nodoc
class __$ReputationBadgeModelCopyWithImpl<$Res>
    implements _$ReputationBadgeModelCopyWith<$Res> {
  __$ReputationBadgeModelCopyWithImpl(this._self, this._then);

  final _ReputationBadgeModel _self;
  final $Res Function(_ReputationBadgeModel) _then;

/// Create a copy of ReputationBadgeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? label = null,Object? description = null,}) {
  return _then(_ReputationBadgeModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReputationComponentsModel {

@JsonKey(fromJson: _toInt) int get payment;@JsonKey(fromJson: _toInt) int get completion;@JsonKey(fromJson: _toInt) int get behavior;@JsonKey(fromJson: _toInt) int get experience;
/// Create a copy of ReputationComponentsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReputationComponentsModelCopyWith<ReputationComponentsModel> get copyWith => _$ReputationComponentsModelCopyWithImpl<ReputationComponentsModel>(this as ReputationComponentsModel, _$identity);

  /// Serializes this ReputationComponentsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReputationComponentsModel&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.completion, completion) || other.completion == completion)&&(identical(other.behavior, behavior) || other.behavior == behavior)&&(identical(other.experience, experience) || other.experience == experience));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payment,completion,behavior,experience);

@override
String toString() {
  return 'ReputationComponentsModel(payment: $payment, completion: $completion, behavior: $behavior, experience: $experience)';
}


}

/// @nodoc
abstract mixin class $ReputationComponentsModelCopyWith<$Res>  {
  factory $ReputationComponentsModelCopyWith(ReputationComponentsModel value, $Res Function(ReputationComponentsModel) _then) = _$ReputationComponentsModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _toInt) int payment,@JsonKey(fromJson: _toInt) int completion,@JsonKey(fromJson: _toInt) int behavior,@JsonKey(fromJson: _toInt) int experience
});




}
/// @nodoc
class _$ReputationComponentsModelCopyWithImpl<$Res>
    implements $ReputationComponentsModelCopyWith<$Res> {
  _$ReputationComponentsModelCopyWithImpl(this._self, this._then);

  final ReputationComponentsModel _self;
  final $Res Function(ReputationComponentsModel) _then;

/// Create a copy of ReputationComponentsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payment = null,Object? completion = null,Object? behavior = null,Object? experience = null,}) {
  return _then(_self.copyWith(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as int,completion: null == completion ? _self.completion : completion // ignore: cast_nullable_to_non_nullable
as int,behavior: null == behavior ? _self.behavior : behavior // ignore: cast_nullable_to_non_nullable
as int,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReputationComponentsModel].
extension ReputationComponentsModelPatterns on ReputationComponentsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReputationComponentsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReputationComponentsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReputationComponentsModel value)  $default,){
final _that = this;
switch (_that) {
case _ReputationComponentsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReputationComponentsModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReputationComponentsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int payment, @JsonKey(fromJson: _toInt)  int completion, @JsonKey(fromJson: _toInt)  int behavior, @JsonKey(fromJson: _toInt)  int experience)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReputationComponentsModel() when $default != null:
return $default(_that.payment,_that.completion,_that.behavior,_that.experience);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _toInt)  int payment, @JsonKey(fromJson: _toInt)  int completion, @JsonKey(fromJson: _toInt)  int behavior, @JsonKey(fromJson: _toInt)  int experience)  $default,) {final _that = this;
switch (_that) {
case _ReputationComponentsModel():
return $default(_that.payment,_that.completion,_that.behavior,_that.experience);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _toInt)  int payment, @JsonKey(fromJson: _toInt)  int completion, @JsonKey(fromJson: _toInt)  int behavior, @JsonKey(fromJson: _toInt)  int experience)?  $default,) {final _that = this;
switch (_that) {
case _ReputationComponentsModel() when $default != null:
return $default(_that.payment,_that.completion,_that.behavior,_that.experience);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReputationComponentsModel implements ReputationComponentsModel {
  const _ReputationComponentsModel({@JsonKey(fromJson: _toInt) required this.payment, @JsonKey(fromJson: _toInt) required this.completion, @JsonKey(fromJson: _toInt) required this.behavior, @JsonKey(fromJson: _toInt) required this.experience});
  factory _ReputationComponentsModel.fromJson(Map<String, dynamic> json) => _$ReputationComponentsModelFromJson(json);

@override@JsonKey(fromJson: _toInt) final  int payment;
@override@JsonKey(fromJson: _toInt) final  int completion;
@override@JsonKey(fromJson: _toInt) final  int behavior;
@override@JsonKey(fromJson: _toInt) final  int experience;

/// Create a copy of ReputationComponentsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReputationComponentsModelCopyWith<_ReputationComponentsModel> get copyWith => __$ReputationComponentsModelCopyWithImpl<_ReputationComponentsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReputationComponentsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReputationComponentsModel&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.completion, completion) || other.completion == completion)&&(identical(other.behavior, behavior) || other.behavior == behavior)&&(identical(other.experience, experience) || other.experience == experience));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,payment,completion,behavior,experience);

@override
String toString() {
  return 'ReputationComponentsModel(payment: $payment, completion: $completion, behavior: $behavior, experience: $experience)';
}


}

/// @nodoc
abstract mixin class _$ReputationComponentsModelCopyWith<$Res> implements $ReputationComponentsModelCopyWith<$Res> {
  factory _$ReputationComponentsModelCopyWith(_ReputationComponentsModel value, $Res Function(_ReputationComponentsModel) _then) = __$ReputationComponentsModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _toInt) int payment,@JsonKey(fromJson: _toInt) int completion,@JsonKey(fromJson: _toInt) int behavior,@JsonKey(fromJson: _toInt) int experience
});




}
/// @nodoc
class __$ReputationComponentsModelCopyWithImpl<$Res>
    implements _$ReputationComponentsModelCopyWith<$Res> {
  __$ReputationComponentsModelCopyWithImpl(this._self, this._then);

  final _ReputationComponentsModel _self;
  final $Res Function(_ReputationComponentsModel) _then;

/// Create a copy of ReputationComponentsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payment = null,Object? completion = null,Object? behavior = null,Object? experience = null,}) {
  return _then(_ReputationComponentsModel(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as int,completion: null == completion ? _self.completion : completion // ignore: cast_nullable_to_non_nullable
as int,behavior: null == behavior ? _self.behavior : behavior // ignore: cast_nullable_to_non_nullable
as int,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MemberReputationSummaryModel {

 String get userId;@JsonKey(fromJson: _toInt) int get trustScore; String get trustLevel; String get summaryLabel;@JsonKey(fromJson: _toInt) int get equbsCompleted;@JsonKey(fromJson: _toInt) int get equbsHosted; double? get onTimePaymentRate;
/// Create a copy of MemberReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberReputationSummaryModelCopyWith<MemberReputationSummaryModel> get copyWith => _$MemberReputationSummaryModelCopyWithImpl<MemberReputationSummaryModel>(this as MemberReputationSummaryModel, _$identity);

  /// Serializes this MemberReputationSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberReputationSummaryModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.trustLevel, trustLevel) || other.trustLevel == trustLevel)&&(identical(other.summaryLabel, summaryLabel) || other.summaryLabel == summaryLabel)&&(identical(other.equbsCompleted, equbsCompleted) || other.equbsCompleted == equbsCompleted)&&(identical(other.equbsHosted, equbsHosted) || other.equbsHosted == equbsHosted)&&(identical(other.onTimePaymentRate, onTimePaymentRate) || other.onTimePaymentRate == onTimePaymentRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,trustScore,trustLevel,summaryLabel,equbsCompleted,equbsHosted,onTimePaymentRate);

@override
String toString() {
  return 'MemberReputationSummaryModel(userId: $userId, trustScore: $trustScore, trustLevel: $trustLevel, summaryLabel: $summaryLabel, equbsCompleted: $equbsCompleted, equbsHosted: $equbsHosted, onTimePaymentRate: $onTimePaymentRate)';
}


}

/// @nodoc
abstract mixin class $MemberReputationSummaryModelCopyWith<$Res>  {
  factory $MemberReputationSummaryModelCopyWith(MemberReputationSummaryModel value, $Res Function(MemberReputationSummaryModel) _then) = _$MemberReputationSummaryModelCopyWithImpl;
@useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int trustScore, String trustLevel, String summaryLabel,@JsonKey(fromJson: _toInt) int equbsCompleted,@JsonKey(fromJson: _toInt) int equbsHosted, double? onTimePaymentRate
});




}
/// @nodoc
class _$MemberReputationSummaryModelCopyWithImpl<$Res>
    implements $MemberReputationSummaryModelCopyWith<$Res> {
  _$MemberReputationSummaryModelCopyWithImpl(this._self, this._then);

  final MemberReputationSummaryModel _self;
  final $Res Function(MemberReputationSummaryModel) _then;

/// Create a copy of MemberReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? trustScore = null,Object? trustLevel = null,Object? summaryLabel = null,Object? equbsCompleted = null,Object? equbsHosted = null,Object? onTimePaymentRate = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,trustLevel: null == trustLevel ? _self.trustLevel : trustLevel // ignore: cast_nullable_to_non_nullable
as String,summaryLabel: null == summaryLabel ? _self.summaryLabel : summaryLabel // ignore: cast_nullable_to_non_nullable
as String,equbsCompleted: null == equbsCompleted ? _self.equbsCompleted : equbsCompleted // ignore: cast_nullable_to_non_nullable
as int,equbsHosted: null == equbsHosted ? _self.equbsHosted : equbsHosted // ignore: cast_nullable_to_non_nullable
as int,onTimePaymentRate: freezed == onTimePaymentRate ? _self.onTimePaymentRate : onTimePaymentRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberReputationSummaryModel].
extension MemberReputationSummaryModelPatterns on MemberReputationSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberReputationSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberReputationSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberReputationSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberReputationSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberReputationSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberReputationSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsCompleted, @JsonKey(fromJson: _toInt)  int equbsHosted,  double? onTimePaymentRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberReputationSummaryModel() when $default != null:
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsCompleted,_that.equbsHosted,_that.onTimePaymentRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsCompleted, @JsonKey(fromJson: _toInt)  int equbsHosted,  double? onTimePaymentRate)  $default,) {final _that = this;
switch (_that) {
case _MemberReputationSummaryModel():
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsCompleted,_that.equbsHosted,_that.onTimePaymentRate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsCompleted, @JsonKey(fromJson: _toInt)  int equbsHosted,  double? onTimePaymentRate)?  $default,) {final _that = this;
switch (_that) {
case _MemberReputationSummaryModel() when $default != null:
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsCompleted,_that.equbsHosted,_that.onTimePaymentRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberReputationSummaryModel implements MemberReputationSummaryModel {
  const _MemberReputationSummaryModel({required this.userId, @JsonKey(fromJson: _toInt) required this.trustScore, required this.trustLevel, required this.summaryLabel, @JsonKey(fromJson: _toInt) this.equbsCompleted = 0, @JsonKey(fromJson: _toInt) this.equbsHosted = 0, this.onTimePaymentRate});
  factory _MemberReputationSummaryModel.fromJson(Map<String, dynamic> json) => _$MemberReputationSummaryModelFromJson(json);

@override final  String userId;
@override@JsonKey(fromJson: _toInt) final  int trustScore;
@override final  String trustLevel;
@override final  String summaryLabel;
@override@JsonKey(fromJson: _toInt) final  int equbsCompleted;
@override@JsonKey(fromJson: _toInt) final  int equbsHosted;
@override final  double? onTimePaymentRate;

/// Create a copy of MemberReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberReputationSummaryModelCopyWith<_MemberReputationSummaryModel> get copyWith => __$MemberReputationSummaryModelCopyWithImpl<_MemberReputationSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberReputationSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberReputationSummaryModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.trustLevel, trustLevel) || other.trustLevel == trustLevel)&&(identical(other.summaryLabel, summaryLabel) || other.summaryLabel == summaryLabel)&&(identical(other.equbsCompleted, equbsCompleted) || other.equbsCompleted == equbsCompleted)&&(identical(other.equbsHosted, equbsHosted) || other.equbsHosted == equbsHosted)&&(identical(other.onTimePaymentRate, onTimePaymentRate) || other.onTimePaymentRate == onTimePaymentRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,trustScore,trustLevel,summaryLabel,equbsCompleted,equbsHosted,onTimePaymentRate);

@override
String toString() {
  return 'MemberReputationSummaryModel(userId: $userId, trustScore: $trustScore, trustLevel: $trustLevel, summaryLabel: $summaryLabel, equbsCompleted: $equbsCompleted, equbsHosted: $equbsHosted, onTimePaymentRate: $onTimePaymentRate)';
}


}

/// @nodoc
abstract mixin class _$MemberReputationSummaryModelCopyWith<$Res> implements $MemberReputationSummaryModelCopyWith<$Res> {
  factory _$MemberReputationSummaryModelCopyWith(_MemberReputationSummaryModel value, $Res Function(_MemberReputationSummaryModel) _then) = __$MemberReputationSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int trustScore, String trustLevel, String summaryLabel,@JsonKey(fromJson: _toInt) int equbsCompleted,@JsonKey(fromJson: _toInt) int equbsHosted, double? onTimePaymentRate
});




}
/// @nodoc
class __$MemberReputationSummaryModelCopyWithImpl<$Res>
    implements _$MemberReputationSummaryModelCopyWith<$Res> {
  __$MemberReputationSummaryModelCopyWithImpl(this._self, this._then);

  final _MemberReputationSummaryModel _self;
  final $Res Function(_MemberReputationSummaryModel) _then;

/// Create a copy of MemberReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? trustScore = null,Object? trustLevel = null,Object? summaryLabel = null,Object? equbsCompleted = null,Object? equbsHosted = null,Object? onTimePaymentRate = freezed,}) {
  return _then(_MemberReputationSummaryModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,trustLevel: null == trustLevel ? _self.trustLevel : trustLevel // ignore: cast_nullable_to_non_nullable
as String,summaryLabel: null == summaryLabel ? _self.summaryLabel : summaryLabel // ignore: cast_nullable_to_non_nullable
as String,equbsCompleted: null == equbsCompleted ? _self.equbsCompleted : equbsCompleted // ignore: cast_nullable_to_non_nullable
as int,equbsHosted: null == equbsHosted ? _self.equbsHosted : equbsHosted // ignore: cast_nullable_to_non_nullable
as int,onTimePaymentRate: freezed == onTimePaymentRate ? _self.onTimePaymentRate : onTimePaymentRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$HostReputationSummaryModel {

 String get userId;@JsonKey(fromJson: _toInt) int get trustScore; String get trustLevel; String get summaryLabel;@JsonKey(fromJson: _toInt) int get equbsHosted;@JsonKey(fromJson: _toInt) int get hostedEqubsCompleted;@JsonKey(fromJson: _toInt) int get turnsParticipated; double? get hostedCompletionRate;@JsonKey(fromJson: _toInt) int get cancelledGroupsCount;@JsonKey(fromJson: _toInt) int get hostDisputesCount;
/// Create a copy of HostReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HostReputationSummaryModelCopyWith<HostReputationSummaryModel> get copyWith => _$HostReputationSummaryModelCopyWithImpl<HostReputationSummaryModel>(this as HostReputationSummaryModel, _$identity);

  /// Serializes this HostReputationSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HostReputationSummaryModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.trustLevel, trustLevel) || other.trustLevel == trustLevel)&&(identical(other.summaryLabel, summaryLabel) || other.summaryLabel == summaryLabel)&&(identical(other.equbsHosted, equbsHosted) || other.equbsHosted == equbsHosted)&&(identical(other.hostedEqubsCompleted, hostedEqubsCompleted) || other.hostedEqubsCompleted == hostedEqubsCompleted)&&(identical(other.turnsParticipated, turnsParticipated) || other.turnsParticipated == turnsParticipated)&&(identical(other.hostedCompletionRate, hostedCompletionRate) || other.hostedCompletionRate == hostedCompletionRate)&&(identical(other.cancelledGroupsCount, cancelledGroupsCount) || other.cancelledGroupsCount == cancelledGroupsCount)&&(identical(other.hostDisputesCount, hostDisputesCount) || other.hostDisputesCount == hostDisputesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,trustScore,trustLevel,summaryLabel,equbsHosted,hostedEqubsCompleted,turnsParticipated,hostedCompletionRate,cancelledGroupsCount,hostDisputesCount);

@override
String toString() {
  return 'HostReputationSummaryModel(userId: $userId, trustScore: $trustScore, trustLevel: $trustLevel, summaryLabel: $summaryLabel, equbsHosted: $equbsHosted, hostedEqubsCompleted: $hostedEqubsCompleted, turnsParticipated: $turnsParticipated, hostedCompletionRate: $hostedCompletionRate, cancelledGroupsCount: $cancelledGroupsCount, hostDisputesCount: $hostDisputesCount)';
}


}

/// @nodoc
abstract mixin class $HostReputationSummaryModelCopyWith<$Res>  {
  factory $HostReputationSummaryModelCopyWith(HostReputationSummaryModel value, $Res Function(HostReputationSummaryModel) _then) = _$HostReputationSummaryModelCopyWithImpl;
@useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int trustScore, String trustLevel, String summaryLabel,@JsonKey(fromJson: _toInt) int equbsHosted,@JsonKey(fromJson: _toInt) int hostedEqubsCompleted,@JsonKey(fromJson: _toInt) int turnsParticipated, double? hostedCompletionRate,@JsonKey(fromJson: _toInt) int cancelledGroupsCount,@JsonKey(fromJson: _toInt) int hostDisputesCount
});




}
/// @nodoc
class _$HostReputationSummaryModelCopyWithImpl<$Res>
    implements $HostReputationSummaryModelCopyWith<$Res> {
  _$HostReputationSummaryModelCopyWithImpl(this._self, this._then);

  final HostReputationSummaryModel _self;
  final $Res Function(HostReputationSummaryModel) _then;

/// Create a copy of HostReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? trustScore = null,Object? trustLevel = null,Object? summaryLabel = null,Object? equbsHosted = null,Object? hostedEqubsCompleted = null,Object? turnsParticipated = null,Object? hostedCompletionRate = freezed,Object? cancelledGroupsCount = null,Object? hostDisputesCount = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,trustLevel: null == trustLevel ? _self.trustLevel : trustLevel // ignore: cast_nullable_to_non_nullable
as String,summaryLabel: null == summaryLabel ? _self.summaryLabel : summaryLabel // ignore: cast_nullable_to_non_nullable
as String,equbsHosted: null == equbsHosted ? _self.equbsHosted : equbsHosted // ignore: cast_nullable_to_non_nullable
as int,hostedEqubsCompleted: null == hostedEqubsCompleted ? _self.hostedEqubsCompleted : hostedEqubsCompleted // ignore: cast_nullable_to_non_nullable
as int,turnsParticipated: null == turnsParticipated ? _self.turnsParticipated : turnsParticipated // ignore: cast_nullable_to_non_nullable
as int,hostedCompletionRate: freezed == hostedCompletionRate ? _self.hostedCompletionRate : hostedCompletionRate // ignore: cast_nullable_to_non_nullable
as double?,cancelledGroupsCount: null == cancelledGroupsCount ? _self.cancelledGroupsCount : cancelledGroupsCount // ignore: cast_nullable_to_non_nullable
as int,hostDisputesCount: null == hostDisputesCount ? _self.hostDisputesCount : hostDisputesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HostReputationSummaryModel].
extension HostReputationSummaryModelPatterns on HostReputationSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HostReputationSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HostReputationSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HostReputationSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _HostReputationSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HostReputationSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _HostReputationSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsHosted, @JsonKey(fromJson: _toInt)  int hostedEqubsCompleted, @JsonKey(fromJson: _toInt)  int turnsParticipated,  double? hostedCompletionRate, @JsonKey(fromJson: _toInt)  int cancelledGroupsCount, @JsonKey(fromJson: _toInt)  int hostDisputesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HostReputationSummaryModel() when $default != null:
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsHosted,_that.hostedEqubsCompleted,_that.turnsParticipated,_that.hostedCompletionRate,_that.cancelledGroupsCount,_that.hostDisputesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsHosted, @JsonKey(fromJson: _toInt)  int hostedEqubsCompleted, @JsonKey(fromJson: _toInt)  int turnsParticipated,  double? hostedCompletionRate, @JsonKey(fromJson: _toInt)  int cancelledGroupsCount, @JsonKey(fromJson: _toInt)  int hostDisputesCount)  $default,) {final _that = this;
switch (_that) {
case _HostReputationSummaryModel():
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsHosted,_that.hostedEqubsCompleted,_that.turnsParticipated,_that.hostedCompletionRate,_that.cancelledGroupsCount,_that.hostDisputesCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsHosted, @JsonKey(fromJson: _toInt)  int hostedEqubsCompleted, @JsonKey(fromJson: _toInt)  int turnsParticipated,  double? hostedCompletionRate, @JsonKey(fromJson: _toInt)  int cancelledGroupsCount, @JsonKey(fromJson: _toInt)  int hostDisputesCount)?  $default,) {final _that = this;
switch (_that) {
case _HostReputationSummaryModel() when $default != null:
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsHosted,_that.hostedEqubsCompleted,_that.turnsParticipated,_that.hostedCompletionRate,_that.cancelledGroupsCount,_that.hostDisputesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HostReputationSummaryModel implements HostReputationSummaryModel {
  const _HostReputationSummaryModel({required this.userId, @JsonKey(fromJson: _toInt) required this.trustScore, required this.trustLevel, required this.summaryLabel, @JsonKey(fromJson: _toInt) required this.equbsHosted, @JsonKey(fromJson: _toInt) required this.hostedEqubsCompleted, @JsonKey(fromJson: _toInt) required this.turnsParticipated, this.hostedCompletionRate, @JsonKey(fromJson: _toInt) required this.cancelledGroupsCount, @JsonKey(fromJson: _toInt) required this.hostDisputesCount});
  factory _HostReputationSummaryModel.fromJson(Map<String, dynamic> json) => _$HostReputationSummaryModelFromJson(json);

@override final  String userId;
@override@JsonKey(fromJson: _toInt) final  int trustScore;
@override final  String trustLevel;
@override final  String summaryLabel;
@override@JsonKey(fromJson: _toInt) final  int equbsHosted;
@override@JsonKey(fromJson: _toInt) final  int hostedEqubsCompleted;
@override@JsonKey(fromJson: _toInt) final  int turnsParticipated;
@override final  double? hostedCompletionRate;
@override@JsonKey(fromJson: _toInt) final  int cancelledGroupsCount;
@override@JsonKey(fromJson: _toInt) final  int hostDisputesCount;

/// Create a copy of HostReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HostReputationSummaryModelCopyWith<_HostReputationSummaryModel> get copyWith => __$HostReputationSummaryModelCopyWithImpl<_HostReputationSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HostReputationSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HostReputationSummaryModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.trustLevel, trustLevel) || other.trustLevel == trustLevel)&&(identical(other.summaryLabel, summaryLabel) || other.summaryLabel == summaryLabel)&&(identical(other.equbsHosted, equbsHosted) || other.equbsHosted == equbsHosted)&&(identical(other.hostedEqubsCompleted, hostedEqubsCompleted) || other.hostedEqubsCompleted == hostedEqubsCompleted)&&(identical(other.turnsParticipated, turnsParticipated) || other.turnsParticipated == turnsParticipated)&&(identical(other.hostedCompletionRate, hostedCompletionRate) || other.hostedCompletionRate == hostedCompletionRate)&&(identical(other.cancelledGroupsCount, cancelledGroupsCount) || other.cancelledGroupsCount == cancelledGroupsCount)&&(identical(other.hostDisputesCount, hostDisputesCount) || other.hostDisputesCount == hostDisputesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,trustScore,trustLevel,summaryLabel,equbsHosted,hostedEqubsCompleted,turnsParticipated,hostedCompletionRate,cancelledGroupsCount,hostDisputesCount);

@override
String toString() {
  return 'HostReputationSummaryModel(userId: $userId, trustScore: $trustScore, trustLevel: $trustLevel, summaryLabel: $summaryLabel, equbsHosted: $equbsHosted, hostedEqubsCompleted: $hostedEqubsCompleted, turnsParticipated: $turnsParticipated, hostedCompletionRate: $hostedCompletionRate, cancelledGroupsCount: $cancelledGroupsCount, hostDisputesCount: $hostDisputesCount)';
}


}

/// @nodoc
abstract mixin class _$HostReputationSummaryModelCopyWith<$Res> implements $HostReputationSummaryModelCopyWith<$Res> {
  factory _$HostReputationSummaryModelCopyWith(_HostReputationSummaryModel value, $Res Function(_HostReputationSummaryModel) _then) = __$HostReputationSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int trustScore, String trustLevel, String summaryLabel,@JsonKey(fromJson: _toInt) int equbsHosted,@JsonKey(fromJson: _toInt) int hostedEqubsCompleted,@JsonKey(fromJson: _toInt) int turnsParticipated, double? hostedCompletionRate,@JsonKey(fromJson: _toInt) int cancelledGroupsCount,@JsonKey(fromJson: _toInt) int hostDisputesCount
});




}
/// @nodoc
class __$HostReputationSummaryModelCopyWithImpl<$Res>
    implements _$HostReputationSummaryModelCopyWith<$Res> {
  __$HostReputationSummaryModelCopyWithImpl(this._self, this._then);

  final _HostReputationSummaryModel _self;
  final $Res Function(_HostReputationSummaryModel) _then;

/// Create a copy of HostReputationSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? trustScore = null,Object? trustLevel = null,Object? summaryLabel = null,Object? equbsHosted = null,Object? hostedEqubsCompleted = null,Object? turnsParticipated = null,Object? hostedCompletionRate = freezed,Object? cancelledGroupsCount = null,Object? hostDisputesCount = null,}) {
  return _then(_HostReputationSummaryModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,trustLevel: null == trustLevel ? _self.trustLevel : trustLevel // ignore: cast_nullable_to_non_nullable
as String,summaryLabel: null == summaryLabel ? _self.summaryLabel : summaryLabel // ignore: cast_nullable_to_non_nullable
as String,equbsHosted: null == equbsHosted ? _self.equbsHosted : equbsHosted // ignore: cast_nullable_to_non_nullable
as int,hostedEqubsCompleted: null == hostedEqubsCompleted ? _self.hostedEqubsCompleted : hostedEqubsCompleted // ignore: cast_nullable_to_non_nullable
as int,turnsParticipated: null == turnsParticipated ? _self.turnsParticipated : turnsParticipated // ignore: cast_nullable_to_non_nullable
as int,hostedCompletionRate: freezed == hostedCompletionRate ? _self.hostedCompletionRate : hostedCompletionRate // ignore: cast_nullable_to_non_nullable
as double?,cancelledGroupsCount: null == cancelledGroupsCount ? _self.cancelledGroupsCount : cancelledGroupsCount // ignore: cast_nullable_to_non_nullable
as int,hostDisputesCount: null == hostDisputesCount ? _self.hostDisputesCount : hostDisputesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GroupTrustSummaryModel {

 String get groupId;@JsonKey(fromJson: _toInt) int get hostScore; double? get averageMemberScore; double? get verifiedMembersPercent; String get groupTrustLevel; HostReputationSummaryModel get host;
/// Create a copy of GroupTrustSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupTrustSummaryModelCopyWith<GroupTrustSummaryModel> get copyWith => _$GroupTrustSummaryModelCopyWithImpl<GroupTrustSummaryModel>(this as GroupTrustSummaryModel, _$identity);

  /// Serializes this GroupTrustSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupTrustSummaryModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.hostScore, hostScore) || other.hostScore == hostScore)&&(identical(other.averageMemberScore, averageMemberScore) || other.averageMemberScore == averageMemberScore)&&(identical(other.verifiedMembersPercent, verifiedMembersPercent) || other.verifiedMembersPercent == verifiedMembersPercent)&&(identical(other.groupTrustLevel, groupTrustLevel) || other.groupTrustLevel == groupTrustLevel)&&(identical(other.host, host) || other.host == host));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,hostScore,averageMemberScore,verifiedMembersPercent,groupTrustLevel,host);

@override
String toString() {
  return 'GroupTrustSummaryModel(groupId: $groupId, hostScore: $hostScore, averageMemberScore: $averageMemberScore, verifiedMembersPercent: $verifiedMembersPercent, groupTrustLevel: $groupTrustLevel, host: $host)';
}


}

/// @nodoc
abstract mixin class $GroupTrustSummaryModelCopyWith<$Res>  {
  factory $GroupTrustSummaryModelCopyWith(GroupTrustSummaryModel value, $Res Function(GroupTrustSummaryModel) _then) = _$GroupTrustSummaryModelCopyWithImpl;
@useResult
$Res call({
 String groupId,@JsonKey(fromJson: _toInt) int hostScore, double? averageMemberScore, double? verifiedMembersPercent, String groupTrustLevel, HostReputationSummaryModel host
});


$HostReputationSummaryModelCopyWith<$Res> get host;

}
/// @nodoc
class _$GroupTrustSummaryModelCopyWithImpl<$Res>
    implements $GroupTrustSummaryModelCopyWith<$Res> {
  _$GroupTrustSummaryModelCopyWithImpl(this._self, this._then);

  final GroupTrustSummaryModel _self;
  final $Res Function(GroupTrustSummaryModel) _then;

/// Create a copy of GroupTrustSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? hostScore = null,Object? averageMemberScore = freezed,Object? verifiedMembersPercent = freezed,Object? groupTrustLevel = null,Object? host = null,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,hostScore: null == hostScore ? _self.hostScore : hostScore // ignore: cast_nullable_to_non_nullable
as int,averageMemberScore: freezed == averageMemberScore ? _self.averageMemberScore : averageMemberScore // ignore: cast_nullable_to_non_nullable
as double?,verifiedMembersPercent: freezed == verifiedMembersPercent ? _self.verifiedMembersPercent : verifiedMembersPercent // ignore: cast_nullable_to_non_nullable
as double?,groupTrustLevel: null == groupTrustLevel ? _self.groupTrustLevel : groupTrustLevel // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as HostReputationSummaryModel,
  ));
}
/// Create a copy of GroupTrustSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HostReputationSummaryModelCopyWith<$Res> get host {
  
  return $HostReputationSummaryModelCopyWith<$Res>(_self.host, (value) {
    return _then(_self.copyWith(host: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupTrustSummaryModel].
extension GroupTrustSummaryModelPatterns on GroupTrustSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupTrustSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupTrustSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupTrustSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _GroupTrustSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupTrustSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _GroupTrustSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId, @JsonKey(fromJson: _toInt)  int hostScore,  double? averageMemberScore,  double? verifiedMembersPercent,  String groupTrustLevel,  HostReputationSummaryModel host)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupTrustSummaryModel() when $default != null:
return $default(_that.groupId,_that.hostScore,_that.averageMemberScore,_that.verifiedMembersPercent,_that.groupTrustLevel,_that.host);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId, @JsonKey(fromJson: _toInt)  int hostScore,  double? averageMemberScore,  double? verifiedMembersPercent,  String groupTrustLevel,  HostReputationSummaryModel host)  $default,) {final _that = this;
switch (_that) {
case _GroupTrustSummaryModel():
return $default(_that.groupId,_that.hostScore,_that.averageMemberScore,_that.verifiedMembersPercent,_that.groupTrustLevel,_that.host);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId, @JsonKey(fromJson: _toInt)  int hostScore,  double? averageMemberScore,  double? verifiedMembersPercent,  String groupTrustLevel,  HostReputationSummaryModel host)?  $default,) {final _that = this;
switch (_that) {
case _GroupTrustSummaryModel() when $default != null:
return $default(_that.groupId,_that.hostScore,_that.averageMemberScore,_that.verifiedMembersPercent,_that.groupTrustLevel,_that.host);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupTrustSummaryModel implements GroupTrustSummaryModel {
  const _GroupTrustSummaryModel({required this.groupId, @JsonKey(fromJson: _toInt) required this.hostScore, this.averageMemberScore, this.verifiedMembersPercent, required this.groupTrustLevel, required this.host});
  factory _GroupTrustSummaryModel.fromJson(Map<String, dynamic> json) => _$GroupTrustSummaryModelFromJson(json);

@override final  String groupId;
@override@JsonKey(fromJson: _toInt) final  int hostScore;
@override final  double? averageMemberScore;
@override final  double? verifiedMembersPercent;
@override final  String groupTrustLevel;
@override final  HostReputationSummaryModel host;

/// Create a copy of GroupTrustSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupTrustSummaryModelCopyWith<_GroupTrustSummaryModel> get copyWith => __$GroupTrustSummaryModelCopyWithImpl<_GroupTrustSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupTrustSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupTrustSummaryModel&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.hostScore, hostScore) || other.hostScore == hostScore)&&(identical(other.averageMemberScore, averageMemberScore) || other.averageMemberScore == averageMemberScore)&&(identical(other.verifiedMembersPercent, verifiedMembersPercent) || other.verifiedMembersPercent == verifiedMembersPercent)&&(identical(other.groupTrustLevel, groupTrustLevel) || other.groupTrustLevel == groupTrustLevel)&&(identical(other.host, host) || other.host == host));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,hostScore,averageMemberScore,verifiedMembersPercent,groupTrustLevel,host);

@override
String toString() {
  return 'GroupTrustSummaryModel(groupId: $groupId, hostScore: $hostScore, averageMemberScore: $averageMemberScore, verifiedMembersPercent: $verifiedMembersPercent, groupTrustLevel: $groupTrustLevel, host: $host)';
}


}

/// @nodoc
abstract mixin class _$GroupTrustSummaryModelCopyWith<$Res> implements $GroupTrustSummaryModelCopyWith<$Res> {
  factory _$GroupTrustSummaryModelCopyWith(_GroupTrustSummaryModel value, $Res Function(_GroupTrustSummaryModel) _then) = __$GroupTrustSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 String groupId,@JsonKey(fromJson: _toInt) int hostScore, double? averageMemberScore, double? verifiedMembersPercent, String groupTrustLevel, HostReputationSummaryModel host
});


@override $HostReputationSummaryModelCopyWith<$Res> get host;

}
/// @nodoc
class __$GroupTrustSummaryModelCopyWithImpl<$Res>
    implements _$GroupTrustSummaryModelCopyWith<$Res> {
  __$GroupTrustSummaryModelCopyWithImpl(this._self, this._then);

  final _GroupTrustSummaryModel _self;
  final $Res Function(_GroupTrustSummaryModel) _then;

/// Create a copy of GroupTrustSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? hostScore = null,Object? averageMemberScore = freezed,Object? verifiedMembersPercent = freezed,Object? groupTrustLevel = null,Object? host = null,}) {
  return _then(_GroupTrustSummaryModel(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,hostScore: null == hostScore ? _self.hostScore : hostScore // ignore: cast_nullable_to_non_nullable
as int,averageMemberScore: freezed == averageMemberScore ? _self.averageMemberScore : averageMemberScore // ignore: cast_nullable_to_non_nullable
as double?,verifiedMembersPercent: freezed == verifiedMembersPercent ? _self.verifiedMembersPercent : verifiedMembersPercent // ignore: cast_nullable_to_non_nullable
as double?,groupTrustLevel: null == groupTrustLevel ? _self.groupTrustLevel : groupTrustLevel // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as HostReputationSummaryModel,
  ));
}

/// Create a copy of GroupTrustSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HostReputationSummaryModelCopyWith<$Res> get host {
  
  return $HostReputationSummaryModelCopyWith<$Res>(_self.host, (value) {
    return _then(_self.copyWith(host: value));
  });
}
}


/// @nodoc
mixin _$ReputationEligibilityModel {

 bool get canHostPublicGroup; bool get canJoinHighValuePublicGroup; bool get canAccessLending; bool get canAccessMarketplace; String? get hostTier; String get hostReputationLevel; AllowedPublicEqubLimitsModel get allowedPublicEqubLimits;
/// Create a copy of ReputationEligibilityModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReputationEligibilityModelCopyWith<ReputationEligibilityModel> get copyWith => _$ReputationEligibilityModelCopyWithImpl<ReputationEligibilityModel>(this as ReputationEligibilityModel, _$identity);

  /// Serializes this ReputationEligibilityModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReputationEligibilityModel&&(identical(other.canHostPublicGroup, canHostPublicGroup) || other.canHostPublicGroup == canHostPublicGroup)&&(identical(other.canJoinHighValuePublicGroup, canJoinHighValuePublicGroup) || other.canJoinHighValuePublicGroup == canJoinHighValuePublicGroup)&&(identical(other.canAccessLending, canAccessLending) || other.canAccessLending == canAccessLending)&&(identical(other.canAccessMarketplace, canAccessMarketplace) || other.canAccessMarketplace == canAccessMarketplace)&&(identical(other.hostTier, hostTier) || other.hostTier == hostTier)&&(identical(other.hostReputationLevel, hostReputationLevel) || other.hostReputationLevel == hostReputationLevel)&&(identical(other.allowedPublicEqubLimits, allowedPublicEqubLimits) || other.allowedPublicEqubLimits == allowedPublicEqubLimits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canHostPublicGroup,canJoinHighValuePublicGroup,canAccessLending,canAccessMarketplace,hostTier,hostReputationLevel,allowedPublicEqubLimits);

@override
String toString() {
  return 'ReputationEligibilityModel(canHostPublicGroup: $canHostPublicGroup, canJoinHighValuePublicGroup: $canJoinHighValuePublicGroup, canAccessLending: $canAccessLending, canAccessMarketplace: $canAccessMarketplace, hostTier: $hostTier, hostReputationLevel: $hostReputationLevel, allowedPublicEqubLimits: $allowedPublicEqubLimits)';
}


}

/// @nodoc
abstract mixin class $ReputationEligibilityModelCopyWith<$Res>  {
  factory $ReputationEligibilityModelCopyWith(ReputationEligibilityModel value, $Res Function(ReputationEligibilityModel) _then) = _$ReputationEligibilityModelCopyWithImpl;
@useResult
$Res call({
 bool canHostPublicGroup, bool canJoinHighValuePublicGroup, bool canAccessLending, bool canAccessMarketplace, String? hostTier, String hostReputationLevel, AllowedPublicEqubLimitsModel allowedPublicEqubLimits
});


$AllowedPublicEqubLimitsModelCopyWith<$Res> get allowedPublicEqubLimits;

}
/// @nodoc
class _$ReputationEligibilityModelCopyWithImpl<$Res>
    implements $ReputationEligibilityModelCopyWith<$Res> {
  _$ReputationEligibilityModelCopyWithImpl(this._self, this._then);

  final ReputationEligibilityModel _self;
  final $Res Function(ReputationEligibilityModel) _then;

/// Create a copy of ReputationEligibilityModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canHostPublicGroup = null,Object? canJoinHighValuePublicGroup = null,Object? canAccessLending = null,Object? canAccessMarketplace = null,Object? hostTier = freezed,Object? hostReputationLevel = null,Object? allowedPublicEqubLimits = null,}) {
  return _then(_self.copyWith(
canHostPublicGroup: null == canHostPublicGroup ? _self.canHostPublicGroup : canHostPublicGroup // ignore: cast_nullable_to_non_nullable
as bool,canJoinHighValuePublicGroup: null == canJoinHighValuePublicGroup ? _self.canJoinHighValuePublicGroup : canJoinHighValuePublicGroup // ignore: cast_nullable_to_non_nullable
as bool,canAccessLending: null == canAccessLending ? _self.canAccessLending : canAccessLending // ignore: cast_nullable_to_non_nullable
as bool,canAccessMarketplace: null == canAccessMarketplace ? _self.canAccessMarketplace : canAccessMarketplace // ignore: cast_nullable_to_non_nullable
as bool,hostTier: freezed == hostTier ? _self.hostTier : hostTier // ignore: cast_nullable_to_non_nullable
as String?,hostReputationLevel: null == hostReputationLevel ? _self.hostReputationLevel : hostReputationLevel // ignore: cast_nullable_to_non_nullable
as String,allowedPublicEqubLimits: null == allowedPublicEqubLimits ? _self.allowedPublicEqubLimits : allowedPublicEqubLimits // ignore: cast_nullable_to_non_nullable
as AllowedPublicEqubLimitsModel,
  ));
}
/// Create a copy of ReputationEligibilityModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AllowedPublicEqubLimitsModelCopyWith<$Res> get allowedPublicEqubLimits {
  
  return $AllowedPublicEqubLimitsModelCopyWith<$Res>(_self.allowedPublicEqubLimits, (value) {
    return _then(_self.copyWith(allowedPublicEqubLimits: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReputationEligibilityModel].
extension ReputationEligibilityModelPatterns on ReputationEligibilityModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReputationEligibilityModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReputationEligibilityModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReputationEligibilityModel value)  $default,){
final _that = this;
switch (_that) {
case _ReputationEligibilityModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReputationEligibilityModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReputationEligibilityModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canHostPublicGroup,  bool canJoinHighValuePublicGroup,  bool canAccessLending,  bool canAccessMarketplace,  String? hostTier,  String hostReputationLevel,  AllowedPublicEqubLimitsModel allowedPublicEqubLimits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReputationEligibilityModel() when $default != null:
return $default(_that.canHostPublicGroup,_that.canJoinHighValuePublicGroup,_that.canAccessLending,_that.canAccessMarketplace,_that.hostTier,_that.hostReputationLevel,_that.allowedPublicEqubLimits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canHostPublicGroup,  bool canJoinHighValuePublicGroup,  bool canAccessLending,  bool canAccessMarketplace,  String? hostTier,  String hostReputationLevel,  AllowedPublicEqubLimitsModel allowedPublicEqubLimits)  $default,) {final _that = this;
switch (_that) {
case _ReputationEligibilityModel():
return $default(_that.canHostPublicGroup,_that.canJoinHighValuePublicGroup,_that.canAccessLending,_that.canAccessMarketplace,_that.hostTier,_that.hostReputationLevel,_that.allowedPublicEqubLimits);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canHostPublicGroup,  bool canJoinHighValuePublicGroup,  bool canAccessLending,  bool canAccessMarketplace,  String? hostTier,  String hostReputationLevel,  AllowedPublicEqubLimitsModel allowedPublicEqubLimits)?  $default,) {final _that = this;
switch (_that) {
case _ReputationEligibilityModel() when $default != null:
return $default(_that.canHostPublicGroup,_that.canJoinHighValuePublicGroup,_that.canAccessLending,_that.canAccessMarketplace,_that.hostTier,_that.hostReputationLevel,_that.allowedPublicEqubLimits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReputationEligibilityModel implements ReputationEligibilityModel {
  const _ReputationEligibilityModel({required this.canHostPublicGroup, required this.canJoinHighValuePublicGroup, required this.canAccessLending, required this.canAccessMarketplace, this.hostTier, required this.hostReputationLevel, required this.allowedPublicEqubLimits});
  factory _ReputationEligibilityModel.fromJson(Map<String, dynamic> json) => _$ReputationEligibilityModelFromJson(json);

@override final  bool canHostPublicGroup;
@override final  bool canJoinHighValuePublicGroup;
@override final  bool canAccessLending;
@override final  bool canAccessMarketplace;
@override final  String? hostTier;
@override final  String hostReputationLevel;
@override final  AllowedPublicEqubLimitsModel allowedPublicEqubLimits;

/// Create a copy of ReputationEligibilityModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReputationEligibilityModelCopyWith<_ReputationEligibilityModel> get copyWith => __$ReputationEligibilityModelCopyWithImpl<_ReputationEligibilityModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReputationEligibilityModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReputationEligibilityModel&&(identical(other.canHostPublicGroup, canHostPublicGroup) || other.canHostPublicGroup == canHostPublicGroup)&&(identical(other.canJoinHighValuePublicGroup, canJoinHighValuePublicGroup) || other.canJoinHighValuePublicGroup == canJoinHighValuePublicGroup)&&(identical(other.canAccessLending, canAccessLending) || other.canAccessLending == canAccessLending)&&(identical(other.canAccessMarketplace, canAccessMarketplace) || other.canAccessMarketplace == canAccessMarketplace)&&(identical(other.hostTier, hostTier) || other.hostTier == hostTier)&&(identical(other.hostReputationLevel, hostReputationLevel) || other.hostReputationLevel == hostReputationLevel)&&(identical(other.allowedPublicEqubLimits, allowedPublicEqubLimits) || other.allowedPublicEqubLimits == allowedPublicEqubLimits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canHostPublicGroup,canJoinHighValuePublicGroup,canAccessLending,canAccessMarketplace,hostTier,hostReputationLevel,allowedPublicEqubLimits);

@override
String toString() {
  return 'ReputationEligibilityModel(canHostPublicGroup: $canHostPublicGroup, canJoinHighValuePublicGroup: $canJoinHighValuePublicGroup, canAccessLending: $canAccessLending, canAccessMarketplace: $canAccessMarketplace, hostTier: $hostTier, hostReputationLevel: $hostReputationLevel, allowedPublicEqubLimits: $allowedPublicEqubLimits)';
}


}

/// @nodoc
abstract mixin class _$ReputationEligibilityModelCopyWith<$Res> implements $ReputationEligibilityModelCopyWith<$Res> {
  factory _$ReputationEligibilityModelCopyWith(_ReputationEligibilityModel value, $Res Function(_ReputationEligibilityModel) _then) = __$ReputationEligibilityModelCopyWithImpl;
@override @useResult
$Res call({
 bool canHostPublicGroup, bool canJoinHighValuePublicGroup, bool canAccessLending, bool canAccessMarketplace, String? hostTier, String hostReputationLevel, AllowedPublicEqubLimitsModel allowedPublicEqubLimits
});


@override $AllowedPublicEqubLimitsModelCopyWith<$Res> get allowedPublicEqubLimits;

}
/// @nodoc
class __$ReputationEligibilityModelCopyWithImpl<$Res>
    implements _$ReputationEligibilityModelCopyWith<$Res> {
  __$ReputationEligibilityModelCopyWithImpl(this._self, this._then);

  final _ReputationEligibilityModel _self;
  final $Res Function(_ReputationEligibilityModel) _then;

/// Create a copy of ReputationEligibilityModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canHostPublicGroup = null,Object? canJoinHighValuePublicGroup = null,Object? canAccessLending = null,Object? canAccessMarketplace = null,Object? hostTier = freezed,Object? hostReputationLevel = null,Object? allowedPublicEqubLimits = null,}) {
  return _then(_ReputationEligibilityModel(
canHostPublicGroup: null == canHostPublicGroup ? _self.canHostPublicGroup : canHostPublicGroup // ignore: cast_nullable_to_non_nullable
as bool,canJoinHighValuePublicGroup: null == canJoinHighValuePublicGroup ? _self.canJoinHighValuePublicGroup : canJoinHighValuePublicGroup // ignore: cast_nullable_to_non_nullable
as bool,canAccessLending: null == canAccessLending ? _self.canAccessLending : canAccessLending // ignore: cast_nullable_to_non_nullable
as bool,canAccessMarketplace: null == canAccessMarketplace ? _self.canAccessMarketplace : canAccessMarketplace // ignore: cast_nullable_to_non_nullable
as bool,hostTier: freezed == hostTier ? _self.hostTier : hostTier // ignore: cast_nullable_to_non_nullable
as String?,hostReputationLevel: null == hostReputationLevel ? _self.hostReputationLevel : hostReputationLevel // ignore: cast_nullable_to_non_nullable
as String,allowedPublicEqubLimits: null == allowedPublicEqubLimits ? _self.allowedPublicEqubLimits : allowedPublicEqubLimits // ignore: cast_nullable_to_non_nullable
as AllowedPublicEqubLimitsModel,
  ));
}

/// Create a copy of ReputationEligibilityModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AllowedPublicEqubLimitsModelCopyWith<$Res> get allowedPublicEqubLimits {
  
  return $AllowedPublicEqubLimitsModelCopyWith<$Res>(_self.allowedPublicEqubLimits, (value) {
    return _then(_self.copyWith(allowedPublicEqubLimits: value));
  });
}
}


/// @nodoc
mixin _$ReputationHistoryEntryModel {

 String get id; String get userId; String get eventType;@JsonKey(fromJson: _toInt) int get scoreDelta; Map<String, int> get metricChanges; String? get relatedGroupId; String? get relatedCycleId; Map<String, dynamic>? get metadata; DateTime get createdAt;
/// Create a copy of ReputationHistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReputationHistoryEntryModelCopyWith<ReputationHistoryEntryModel> get copyWith => _$ReputationHistoryEntryModelCopyWithImpl<ReputationHistoryEntryModel>(this as ReputationHistoryEntryModel, _$identity);

  /// Serializes this ReputationHistoryEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReputationHistoryEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.scoreDelta, scoreDelta) || other.scoreDelta == scoreDelta)&&const DeepCollectionEquality().equals(other.metricChanges, metricChanges)&&(identical(other.relatedGroupId, relatedGroupId) || other.relatedGroupId == relatedGroupId)&&(identical(other.relatedCycleId, relatedCycleId) || other.relatedCycleId == relatedCycleId)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,eventType,scoreDelta,const DeepCollectionEquality().hash(metricChanges),relatedGroupId,relatedCycleId,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'ReputationHistoryEntryModel(id: $id, userId: $userId, eventType: $eventType, scoreDelta: $scoreDelta, metricChanges: $metricChanges, relatedGroupId: $relatedGroupId, relatedCycleId: $relatedCycleId, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReputationHistoryEntryModelCopyWith<$Res>  {
  factory $ReputationHistoryEntryModelCopyWith(ReputationHistoryEntryModel value, $Res Function(ReputationHistoryEntryModel) _then) = _$ReputationHistoryEntryModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String eventType,@JsonKey(fromJson: _toInt) int scoreDelta, Map<String, int> metricChanges, String? relatedGroupId, String? relatedCycleId, Map<String, dynamic>? metadata, DateTime createdAt
});




}
/// @nodoc
class _$ReputationHistoryEntryModelCopyWithImpl<$Res>
    implements $ReputationHistoryEntryModelCopyWith<$Res> {
  _$ReputationHistoryEntryModelCopyWithImpl(this._self, this._then);

  final ReputationHistoryEntryModel _self;
  final $Res Function(ReputationHistoryEntryModel) _then;

/// Create a copy of ReputationHistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? eventType = null,Object? scoreDelta = null,Object? metricChanges = null,Object? relatedGroupId = freezed,Object? relatedCycleId = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,scoreDelta: null == scoreDelta ? _self.scoreDelta : scoreDelta // ignore: cast_nullable_to_non_nullable
as int,metricChanges: null == metricChanges ? _self.metricChanges : metricChanges // ignore: cast_nullable_to_non_nullable
as Map<String, int>,relatedGroupId: freezed == relatedGroupId ? _self.relatedGroupId : relatedGroupId // ignore: cast_nullable_to_non_nullable
as String?,relatedCycleId: freezed == relatedCycleId ? _self.relatedCycleId : relatedCycleId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReputationHistoryEntryModel].
extension ReputationHistoryEntryModelPatterns on ReputationHistoryEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReputationHistoryEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReputationHistoryEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReputationHistoryEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _ReputationHistoryEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReputationHistoryEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReputationHistoryEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String eventType, @JsonKey(fromJson: _toInt)  int scoreDelta,  Map<String, int> metricChanges,  String? relatedGroupId,  String? relatedCycleId,  Map<String, dynamic>? metadata,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReputationHistoryEntryModel() when $default != null:
return $default(_that.id,_that.userId,_that.eventType,_that.scoreDelta,_that.metricChanges,_that.relatedGroupId,_that.relatedCycleId,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String eventType, @JsonKey(fromJson: _toInt)  int scoreDelta,  Map<String, int> metricChanges,  String? relatedGroupId,  String? relatedCycleId,  Map<String, dynamic>? metadata,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReputationHistoryEntryModel():
return $default(_that.id,_that.userId,_that.eventType,_that.scoreDelta,_that.metricChanges,_that.relatedGroupId,_that.relatedCycleId,_that.metadata,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String eventType, @JsonKey(fromJson: _toInt)  int scoreDelta,  Map<String, int> metricChanges,  String? relatedGroupId,  String? relatedCycleId,  Map<String, dynamic>? metadata,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReputationHistoryEntryModel() when $default != null:
return $default(_that.id,_that.userId,_that.eventType,_that.scoreDelta,_that.metricChanges,_that.relatedGroupId,_that.relatedCycleId,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReputationHistoryEntryModel implements ReputationHistoryEntryModel {
  const _ReputationHistoryEntryModel({required this.id, required this.userId, required this.eventType, @JsonKey(fromJson: _toInt) required this.scoreDelta, final  Map<String, int> metricChanges = const <String, int>{}, this.relatedGroupId, this.relatedCycleId, final  Map<String, dynamic>? metadata, required this.createdAt}): _metricChanges = metricChanges,_metadata = metadata;
  factory _ReputationHistoryEntryModel.fromJson(Map<String, dynamic> json) => _$ReputationHistoryEntryModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String eventType;
@override@JsonKey(fromJson: _toInt) final  int scoreDelta;
 final  Map<String, int> _metricChanges;
@override@JsonKey() Map<String, int> get metricChanges {
  if (_metricChanges is EqualUnmodifiableMapView) return _metricChanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metricChanges);
}

@override final  String? relatedGroupId;
@override final  String? relatedCycleId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;

/// Create a copy of ReputationHistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReputationHistoryEntryModelCopyWith<_ReputationHistoryEntryModel> get copyWith => __$ReputationHistoryEntryModelCopyWithImpl<_ReputationHistoryEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReputationHistoryEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReputationHistoryEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.scoreDelta, scoreDelta) || other.scoreDelta == scoreDelta)&&const DeepCollectionEquality().equals(other._metricChanges, _metricChanges)&&(identical(other.relatedGroupId, relatedGroupId) || other.relatedGroupId == relatedGroupId)&&(identical(other.relatedCycleId, relatedCycleId) || other.relatedCycleId == relatedCycleId)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,eventType,scoreDelta,const DeepCollectionEquality().hash(_metricChanges),relatedGroupId,relatedCycleId,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'ReputationHistoryEntryModel(id: $id, userId: $userId, eventType: $eventType, scoreDelta: $scoreDelta, metricChanges: $metricChanges, relatedGroupId: $relatedGroupId, relatedCycleId: $relatedCycleId, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReputationHistoryEntryModelCopyWith<$Res> implements $ReputationHistoryEntryModelCopyWith<$Res> {
  factory _$ReputationHistoryEntryModelCopyWith(_ReputationHistoryEntryModel value, $Res Function(_ReputationHistoryEntryModel) _then) = __$ReputationHistoryEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String eventType,@JsonKey(fromJson: _toInt) int scoreDelta, Map<String, int> metricChanges, String? relatedGroupId, String? relatedCycleId, Map<String, dynamic>? metadata, DateTime createdAt
});




}
/// @nodoc
class __$ReputationHistoryEntryModelCopyWithImpl<$Res>
    implements _$ReputationHistoryEntryModelCopyWith<$Res> {
  __$ReputationHistoryEntryModelCopyWithImpl(this._self, this._then);

  final _ReputationHistoryEntryModel _self;
  final $Res Function(_ReputationHistoryEntryModel) _then;

/// Create a copy of ReputationHistoryEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? eventType = null,Object? scoreDelta = null,Object? metricChanges = null,Object? relatedGroupId = freezed,Object? relatedCycleId = freezed,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_ReputationHistoryEntryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,scoreDelta: null == scoreDelta ? _self.scoreDelta : scoreDelta // ignore: cast_nullable_to_non_nullable
as int,metricChanges: null == metricChanges ? _self._metricChanges : metricChanges // ignore: cast_nullable_to_non_nullable
as Map<String, int>,relatedGroupId: freezed == relatedGroupId ? _self.relatedGroupId : relatedGroupId // ignore: cast_nullable_to_non_nullable
as String?,relatedCycleId: freezed == relatedCycleId ? _self.relatedCycleId : relatedCycleId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ReputationHistoryPageModel {

 List<ReputationHistoryEntryModel> get items; int get page; int get limit; int get total;
/// Create a copy of ReputationHistoryPageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReputationHistoryPageModelCopyWith<ReputationHistoryPageModel> get copyWith => _$ReputationHistoryPageModelCopyWithImpl<ReputationHistoryPageModel>(this as ReputationHistoryPageModel, _$identity);

  /// Serializes this ReputationHistoryPageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReputationHistoryPageModel&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,limit,total);

@override
String toString() {
  return 'ReputationHistoryPageModel(items: $items, page: $page, limit: $limit, total: $total)';
}


}

/// @nodoc
abstract mixin class $ReputationHistoryPageModelCopyWith<$Res>  {
  factory $ReputationHistoryPageModelCopyWith(ReputationHistoryPageModel value, $Res Function(ReputationHistoryPageModel) _then) = _$ReputationHistoryPageModelCopyWithImpl;
@useResult
$Res call({
 List<ReputationHistoryEntryModel> items, int page, int limit, int total
});




}
/// @nodoc
class _$ReputationHistoryPageModelCopyWithImpl<$Res>
    implements $ReputationHistoryPageModelCopyWith<$Res> {
  _$ReputationHistoryPageModelCopyWithImpl(this._self, this._then);

  final ReputationHistoryPageModel _self;
  final $Res Function(ReputationHistoryPageModel) _then;

/// Create a copy of ReputationHistoryPageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? limit = null,Object? total = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReputationHistoryEntryModel>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReputationHistoryPageModel].
extension ReputationHistoryPageModelPatterns on ReputationHistoryPageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReputationHistoryPageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReputationHistoryPageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReputationHistoryPageModel value)  $default,){
final _that = this;
switch (_that) {
case _ReputationHistoryPageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReputationHistoryPageModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReputationHistoryPageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ReputationHistoryEntryModel> items,  int page,  int limit,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReputationHistoryPageModel() when $default != null:
return $default(_that.items,_that.page,_that.limit,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ReputationHistoryEntryModel> items,  int page,  int limit,  int total)  $default,) {final _that = this;
switch (_that) {
case _ReputationHistoryPageModel():
return $default(_that.items,_that.page,_that.limit,_that.total);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ReputationHistoryEntryModel> items,  int page,  int limit,  int total)?  $default,) {final _that = this;
switch (_that) {
case _ReputationHistoryPageModel() when $default != null:
return $default(_that.items,_that.page,_that.limit,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReputationHistoryPageModel implements ReputationHistoryPageModel {
  const _ReputationHistoryPageModel({final  List<ReputationHistoryEntryModel> items = const <ReputationHistoryEntryModel>[], this.page = 1, this.limit = 10, this.total = 0}): _items = items;
  factory _ReputationHistoryPageModel.fromJson(Map<String, dynamic> json) => _$ReputationHistoryPageModelFromJson(json);

 final  List<ReputationHistoryEntryModel> _items;
@override@JsonKey() List<ReputationHistoryEntryModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int page;
@override@JsonKey() final  int limit;
@override@JsonKey() final  int total;

/// Create a copy of ReputationHistoryPageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReputationHistoryPageModelCopyWith<_ReputationHistoryPageModel> get copyWith => __$ReputationHistoryPageModelCopyWithImpl<_ReputationHistoryPageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReputationHistoryPageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReputationHistoryPageModel&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,limit,total);

@override
String toString() {
  return 'ReputationHistoryPageModel(items: $items, page: $page, limit: $limit, total: $total)';
}


}

/// @nodoc
abstract mixin class _$ReputationHistoryPageModelCopyWith<$Res> implements $ReputationHistoryPageModelCopyWith<$Res> {
  factory _$ReputationHistoryPageModelCopyWith(_ReputationHistoryPageModel value, $Res Function(_ReputationHistoryPageModel) _then) = __$ReputationHistoryPageModelCopyWithImpl;
@override @useResult
$Res call({
 List<ReputationHistoryEntryModel> items, int page, int limit, int total
});




}
/// @nodoc
class __$ReputationHistoryPageModelCopyWithImpl<$Res>
    implements _$ReputationHistoryPageModelCopyWith<$Res> {
  __$ReputationHistoryPageModelCopyWithImpl(this._self, this._then);

  final _ReputationHistoryPageModel _self;
  final $Res Function(_ReputationHistoryPageModel) _then;

/// Create a copy of ReputationHistoryPageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? limit = null,Object? total = null,}) {
  return _then(_ReputationHistoryPageModel(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReputationHistoryEntryModel>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReputationProfileModel {

 String get userId;@JsonKey(fromJson: _toInt) int get trustScore; String get trustLevel; String get summaryLabel;@JsonKey(fromJson: _toInt) int get equbsJoined;@JsonKey(fromJson: _toInt) int get equbsCompleted;@JsonKey(fromJson: _toInt) int get equbsLeftEarly;@JsonKey(fromJson: _toInt) int get equbsHosted;@JsonKey(fromJson: _toInt) int get hostedEqubsCompleted;@JsonKey(fromJson: _toInt) int get onTimePayments;@JsonKey(fromJson: _toInt) int get latePayments;@JsonKey(fromJson: _toInt) int get missedPayments;@JsonKey(fromJson: _toInt) int get turnsParticipated;@JsonKey(fromJson: _toInt) int get payoutsReceived;@JsonKey(fromJson: _toInt) int get payoutsConfirmed;@JsonKey(fromJson: _toInt) int get removalsCount;@JsonKey(fromJson: _toInt) int get disputesCount;@JsonKey(fromJson: _toInt) int get cancelledGroupsCount;@JsonKey(fromJson: _toInt) int get hostDisputesCount; ReputationComponentsModel get components; double? get baseScore; double? get activityFactor; double? get adjustedScore; double? get confidenceFactor; DateTime? get lastEqubActivityAt; double? get onTimePaymentRate; double? get hostedCompletionRate; DateTime get updatedAt; ReputationEligibilityModel get eligibility; List<ReputationBadgeModel> get badges;
/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReputationProfileModelCopyWith<ReputationProfileModel> get copyWith => _$ReputationProfileModelCopyWithImpl<ReputationProfileModel>(this as ReputationProfileModel, _$identity);

  /// Serializes this ReputationProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReputationProfileModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.trustLevel, trustLevel) || other.trustLevel == trustLevel)&&(identical(other.summaryLabel, summaryLabel) || other.summaryLabel == summaryLabel)&&(identical(other.equbsJoined, equbsJoined) || other.equbsJoined == equbsJoined)&&(identical(other.equbsCompleted, equbsCompleted) || other.equbsCompleted == equbsCompleted)&&(identical(other.equbsLeftEarly, equbsLeftEarly) || other.equbsLeftEarly == equbsLeftEarly)&&(identical(other.equbsHosted, equbsHosted) || other.equbsHosted == equbsHosted)&&(identical(other.hostedEqubsCompleted, hostedEqubsCompleted) || other.hostedEqubsCompleted == hostedEqubsCompleted)&&(identical(other.onTimePayments, onTimePayments) || other.onTimePayments == onTimePayments)&&(identical(other.latePayments, latePayments) || other.latePayments == latePayments)&&(identical(other.missedPayments, missedPayments) || other.missedPayments == missedPayments)&&(identical(other.turnsParticipated, turnsParticipated) || other.turnsParticipated == turnsParticipated)&&(identical(other.payoutsReceived, payoutsReceived) || other.payoutsReceived == payoutsReceived)&&(identical(other.payoutsConfirmed, payoutsConfirmed) || other.payoutsConfirmed == payoutsConfirmed)&&(identical(other.removalsCount, removalsCount) || other.removalsCount == removalsCount)&&(identical(other.disputesCount, disputesCount) || other.disputesCount == disputesCount)&&(identical(other.cancelledGroupsCount, cancelledGroupsCount) || other.cancelledGroupsCount == cancelledGroupsCount)&&(identical(other.hostDisputesCount, hostDisputesCount) || other.hostDisputesCount == hostDisputesCount)&&(identical(other.components, components) || other.components == components)&&(identical(other.baseScore, baseScore) || other.baseScore == baseScore)&&(identical(other.activityFactor, activityFactor) || other.activityFactor == activityFactor)&&(identical(other.adjustedScore, adjustedScore) || other.adjustedScore == adjustedScore)&&(identical(other.confidenceFactor, confidenceFactor) || other.confidenceFactor == confidenceFactor)&&(identical(other.lastEqubActivityAt, lastEqubActivityAt) || other.lastEqubActivityAt == lastEqubActivityAt)&&(identical(other.onTimePaymentRate, onTimePaymentRate) || other.onTimePaymentRate == onTimePaymentRate)&&(identical(other.hostedCompletionRate, hostedCompletionRate) || other.hostedCompletionRate == hostedCompletionRate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.eligibility, eligibility) || other.eligibility == eligibility)&&const DeepCollectionEquality().equals(other.badges, badges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,trustScore,trustLevel,summaryLabel,equbsJoined,equbsCompleted,equbsLeftEarly,equbsHosted,hostedEqubsCompleted,onTimePayments,latePayments,missedPayments,turnsParticipated,payoutsReceived,payoutsConfirmed,removalsCount,disputesCount,cancelledGroupsCount,hostDisputesCount,components,baseScore,activityFactor,adjustedScore,confidenceFactor,lastEqubActivityAt,onTimePaymentRate,hostedCompletionRate,updatedAt,eligibility,const DeepCollectionEquality().hash(badges)]);

@override
String toString() {
  return 'ReputationProfileModel(userId: $userId, trustScore: $trustScore, trustLevel: $trustLevel, summaryLabel: $summaryLabel, equbsJoined: $equbsJoined, equbsCompleted: $equbsCompleted, equbsLeftEarly: $equbsLeftEarly, equbsHosted: $equbsHosted, hostedEqubsCompleted: $hostedEqubsCompleted, onTimePayments: $onTimePayments, latePayments: $latePayments, missedPayments: $missedPayments, turnsParticipated: $turnsParticipated, payoutsReceived: $payoutsReceived, payoutsConfirmed: $payoutsConfirmed, removalsCount: $removalsCount, disputesCount: $disputesCount, cancelledGroupsCount: $cancelledGroupsCount, hostDisputesCount: $hostDisputesCount, components: $components, baseScore: $baseScore, activityFactor: $activityFactor, adjustedScore: $adjustedScore, confidenceFactor: $confidenceFactor, lastEqubActivityAt: $lastEqubActivityAt, onTimePaymentRate: $onTimePaymentRate, hostedCompletionRate: $hostedCompletionRate, updatedAt: $updatedAt, eligibility: $eligibility, badges: $badges)';
}


}

/// @nodoc
abstract mixin class $ReputationProfileModelCopyWith<$Res>  {
  factory $ReputationProfileModelCopyWith(ReputationProfileModel value, $Res Function(ReputationProfileModel) _then) = _$ReputationProfileModelCopyWithImpl;
@useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int trustScore, String trustLevel, String summaryLabel,@JsonKey(fromJson: _toInt) int equbsJoined,@JsonKey(fromJson: _toInt) int equbsCompleted,@JsonKey(fromJson: _toInt) int equbsLeftEarly,@JsonKey(fromJson: _toInt) int equbsHosted,@JsonKey(fromJson: _toInt) int hostedEqubsCompleted,@JsonKey(fromJson: _toInt) int onTimePayments,@JsonKey(fromJson: _toInt) int latePayments,@JsonKey(fromJson: _toInt) int missedPayments,@JsonKey(fromJson: _toInt) int turnsParticipated,@JsonKey(fromJson: _toInt) int payoutsReceived,@JsonKey(fromJson: _toInt) int payoutsConfirmed,@JsonKey(fromJson: _toInt) int removalsCount,@JsonKey(fromJson: _toInt) int disputesCount,@JsonKey(fromJson: _toInt) int cancelledGroupsCount,@JsonKey(fromJson: _toInt) int hostDisputesCount, ReputationComponentsModel components, double? baseScore, double? activityFactor, double? adjustedScore, double? confidenceFactor, DateTime? lastEqubActivityAt, double? onTimePaymentRate, double? hostedCompletionRate, DateTime updatedAt, ReputationEligibilityModel eligibility, List<ReputationBadgeModel> badges
});


$ReputationComponentsModelCopyWith<$Res> get components;$ReputationEligibilityModelCopyWith<$Res> get eligibility;

}
/// @nodoc
class _$ReputationProfileModelCopyWithImpl<$Res>
    implements $ReputationProfileModelCopyWith<$Res> {
  _$ReputationProfileModelCopyWithImpl(this._self, this._then);

  final ReputationProfileModel _self;
  final $Res Function(ReputationProfileModel) _then;

/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? trustScore = null,Object? trustLevel = null,Object? summaryLabel = null,Object? equbsJoined = null,Object? equbsCompleted = null,Object? equbsLeftEarly = null,Object? equbsHosted = null,Object? hostedEqubsCompleted = null,Object? onTimePayments = null,Object? latePayments = null,Object? missedPayments = null,Object? turnsParticipated = null,Object? payoutsReceived = null,Object? payoutsConfirmed = null,Object? removalsCount = null,Object? disputesCount = null,Object? cancelledGroupsCount = null,Object? hostDisputesCount = null,Object? components = null,Object? baseScore = freezed,Object? activityFactor = freezed,Object? adjustedScore = freezed,Object? confidenceFactor = freezed,Object? lastEqubActivityAt = freezed,Object? onTimePaymentRate = freezed,Object? hostedCompletionRate = freezed,Object? updatedAt = null,Object? eligibility = null,Object? badges = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,trustLevel: null == trustLevel ? _self.trustLevel : trustLevel // ignore: cast_nullable_to_non_nullable
as String,summaryLabel: null == summaryLabel ? _self.summaryLabel : summaryLabel // ignore: cast_nullable_to_non_nullable
as String,equbsJoined: null == equbsJoined ? _self.equbsJoined : equbsJoined // ignore: cast_nullable_to_non_nullable
as int,equbsCompleted: null == equbsCompleted ? _self.equbsCompleted : equbsCompleted // ignore: cast_nullable_to_non_nullable
as int,equbsLeftEarly: null == equbsLeftEarly ? _self.equbsLeftEarly : equbsLeftEarly // ignore: cast_nullable_to_non_nullable
as int,equbsHosted: null == equbsHosted ? _self.equbsHosted : equbsHosted // ignore: cast_nullable_to_non_nullable
as int,hostedEqubsCompleted: null == hostedEqubsCompleted ? _self.hostedEqubsCompleted : hostedEqubsCompleted // ignore: cast_nullable_to_non_nullable
as int,onTimePayments: null == onTimePayments ? _self.onTimePayments : onTimePayments // ignore: cast_nullable_to_non_nullable
as int,latePayments: null == latePayments ? _self.latePayments : latePayments // ignore: cast_nullable_to_non_nullable
as int,missedPayments: null == missedPayments ? _self.missedPayments : missedPayments // ignore: cast_nullable_to_non_nullable
as int,turnsParticipated: null == turnsParticipated ? _self.turnsParticipated : turnsParticipated // ignore: cast_nullable_to_non_nullable
as int,payoutsReceived: null == payoutsReceived ? _self.payoutsReceived : payoutsReceived // ignore: cast_nullable_to_non_nullable
as int,payoutsConfirmed: null == payoutsConfirmed ? _self.payoutsConfirmed : payoutsConfirmed // ignore: cast_nullable_to_non_nullable
as int,removalsCount: null == removalsCount ? _self.removalsCount : removalsCount // ignore: cast_nullable_to_non_nullable
as int,disputesCount: null == disputesCount ? _self.disputesCount : disputesCount // ignore: cast_nullable_to_non_nullable
as int,cancelledGroupsCount: null == cancelledGroupsCount ? _self.cancelledGroupsCount : cancelledGroupsCount // ignore: cast_nullable_to_non_nullable
as int,hostDisputesCount: null == hostDisputesCount ? _self.hostDisputesCount : hostDisputesCount // ignore: cast_nullable_to_non_nullable
as int,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as ReputationComponentsModel,baseScore: freezed == baseScore ? _self.baseScore : baseScore // ignore: cast_nullable_to_non_nullable
as double?,activityFactor: freezed == activityFactor ? _self.activityFactor : activityFactor // ignore: cast_nullable_to_non_nullable
as double?,adjustedScore: freezed == adjustedScore ? _self.adjustedScore : adjustedScore // ignore: cast_nullable_to_non_nullable
as double?,confidenceFactor: freezed == confidenceFactor ? _self.confidenceFactor : confidenceFactor // ignore: cast_nullable_to_non_nullable
as double?,lastEqubActivityAt: freezed == lastEqubActivityAt ? _self.lastEqubActivityAt : lastEqubActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,onTimePaymentRate: freezed == onTimePaymentRate ? _self.onTimePaymentRate : onTimePaymentRate // ignore: cast_nullable_to_non_nullable
as double?,hostedCompletionRate: freezed == hostedCompletionRate ? _self.hostedCompletionRate : hostedCompletionRate // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,eligibility: null == eligibility ? _self.eligibility : eligibility // ignore: cast_nullable_to_non_nullable
as ReputationEligibilityModel,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<ReputationBadgeModel>,
  ));
}
/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReputationComponentsModelCopyWith<$Res> get components {
  
  return $ReputationComponentsModelCopyWith<$Res>(_self.components, (value) {
    return _then(_self.copyWith(components: value));
  });
}/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReputationEligibilityModelCopyWith<$Res> get eligibility {
  
  return $ReputationEligibilityModelCopyWith<$Res>(_self.eligibility, (value) {
    return _then(_self.copyWith(eligibility: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReputationProfileModel].
extension ReputationProfileModelPatterns on ReputationProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReputationProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReputationProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReputationProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _ReputationProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReputationProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReputationProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsJoined, @JsonKey(fromJson: _toInt)  int equbsCompleted, @JsonKey(fromJson: _toInt)  int equbsLeftEarly, @JsonKey(fromJson: _toInt)  int equbsHosted, @JsonKey(fromJson: _toInt)  int hostedEqubsCompleted, @JsonKey(fromJson: _toInt)  int onTimePayments, @JsonKey(fromJson: _toInt)  int latePayments, @JsonKey(fromJson: _toInt)  int missedPayments, @JsonKey(fromJson: _toInt)  int turnsParticipated, @JsonKey(fromJson: _toInt)  int payoutsReceived, @JsonKey(fromJson: _toInt)  int payoutsConfirmed, @JsonKey(fromJson: _toInt)  int removalsCount, @JsonKey(fromJson: _toInt)  int disputesCount, @JsonKey(fromJson: _toInt)  int cancelledGroupsCount, @JsonKey(fromJson: _toInt)  int hostDisputesCount,  ReputationComponentsModel components,  double? baseScore,  double? activityFactor,  double? adjustedScore,  double? confidenceFactor,  DateTime? lastEqubActivityAt,  double? onTimePaymentRate,  double? hostedCompletionRate,  DateTime updatedAt,  ReputationEligibilityModel eligibility,  List<ReputationBadgeModel> badges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReputationProfileModel() when $default != null:
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsJoined,_that.equbsCompleted,_that.equbsLeftEarly,_that.equbsHosted,_that.hostedEqubsCompleted,_that.onTimePayments,_that.latePayments,_that.missedPayments,_that.turnsParticipated,_that.payoutsReceived,_that.payoutsConfirmed,_that.removalsCount,_that.disputesCount,_that.cancelledGroupsCount,_that.hostDisputesCount,_that.components,_that.baseScore,_that.activityFactor,_that.adjustedScore,_that.confidenceFactor,_that.lastEqubActivityAt,_that.onTimePaymentRate,_that.hostedCompletionRate,_that.updatedAt,_that.eligibility,_that.badges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsJoined, @JsonKey(fromJson: _toInt)  int equbsCompleted, @JsonKey(fromJson: _toInt)  int equbsLeftEarly, @JsonKey(fromJson: _toInt)  int equbsHosted, @JsonKey(fromJson: _toInt)  int hostedEqubsCompleted, @JsonKey(fromJson: _toInt)  int onTimePayments, @JsonKey(fromJson: _toInt)  int latePayments, @JsonKey(fromJson: _toInt)  int missedPayments, @JsonKey(fromJson: _toInt)  int turnsParticipated, @JsonKey(fromJson: _toInt)  int payoutsReceived, @JsonKey(fromJson: _toInt)  int payoutsConfirmed, @JsonKey(fromJson: _toInt)  int removalsCount, @JsonKey(fromJson: _toInt)  int disputesCount, @JsonKey(fromJson: _toInt)  int cancelledGroupsCount, @JsonKey(fromJson: _toInt)  int hostDisputesCount,  ReputationComponentsModel components,  double? baseScore,  double? activityFactor,  double? adjustedScore,  double? confidenceFactor,  DateTime? lastEqubActivityAt,  double? onTimePaymentRate,  double? hostedCompletionRate,  DateTime updatedAt,  ReputationEligibilityModel eligibility,  List<ReputationBadgeModel> badges)  $default,) {final _that = this;
switch (_that) {
case _ReputationProfileModel():
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsJoined,_that.equbsCompleted,_that.equbsLeftEarly,_that.equbsHosted,_that.hostedEqubsCompleted,_that.onTimePayments,_that.latePayments,_that.missedPayments,_that.turnsParticipated,_that.payoutsReceived,_that.payoutsConfirmed,_that.removalsCount,_that.disputesCount,_that.cancelledGroupsCount,_that.hostDisputesCount,_that.components,_that.baseScore,_that.activityFactor,_that.adjustedScore,_that.confidenceFactor,_that.lastEqubActivityAt,_that.onTimePaymentRate,_that.hostedCompletionRate,_that.updatedAt,_that.eligibility,_that.badges);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId, @JsonKey(fromJson: _toInt)  int trustScore,  String trustLevel,  String summaryLabel, @JsonKey(fromJson: _toInt)  int equbsJoined, @JsonKey(fromJson: _toInt)  int equbsCompleted, @JsonKey(fromJson: _toInt)  int equbsLeftEarly, @JsonKey(fromJson: _toInt)  int equbsHosted, @JsonKey(fromJson: _toInt)  int hostedEqubsCompleted, @JsonKey(fromJson: _toInt)  int onTimePayments, @JsonKey(fromJson: _toInt)  int latePayments, @JsonKey(fromJson: _toInt)  int missedPayments, @JsonKey(fromJson: _toInt)  int turnsParticipated, @JsonKey(fromJson: _toInt)  int payoutsReceived, @JsonKey(fromJson: _toInt)  int payoutsConfirmed, @JsonKey(fromJson: _toInt)  int removalsCount, @JsonKey(fromJson: _toInt)  int disputesCount, @JsonKey(fromJson: _toInt)  int cancelledGroupsCount, @JsonKey(fromJson: _toInt)  int hostDisputesCount,  ReputationComponentsModel components,  double? baseScore,  double? activityFactor,  double? adjustedScore,  double? confidenceFactor,  DateTime? lastEqubActivityAt,  double? onTimePaymentRate,  double? hostedCompletionRate,  DateTime updatedAt,  ReputationEligibilityModel eligibility,  List<ReputationBadgeModel> badges)?  $default,) {final _that = this;
switch (_that) {
case _ReputationProfileModel() when $default != null:
return $default(_that.userId,_that.trustScore,_that.trustLevel,_that.summaryLabel,_that.equbsJoined,_that.equbsCompleted,_that.equbsLeftEarly,_that.equbsHosted,_that.hostedEqubsCompleted,_that.onTimePayments,_that.latePayments,_that.missedPayments,_that.turnsParticipated,_that.payoutsReceived,_that.payoutsConfirmed,_that.removalsCount,_that.disputesCount,_that.cancelledGroupsCount,_that.hostDisputesCount,_that.components,_that.baseScore,_that.activityFactor,_that.adjustedScore,_that.confidenceFactor,_that.lastEqubActivityAt,_that.onTimePaymentRate,_that.hostedCompletionRate,_that.updatedAt,_that.eligibility,_that.badges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReputationProfileModel extends ReputationProfileModel {
  const _ReputationProfileModel({required this.userId, @JsonKey(fromJson: _toInt) required this.trustScore, required this.trustLevel, required this.summaryLabel, @JsonKey(fromJson: _toInt) required this.equbsJoined, @JsonKey(fromJson: _toInt) required this.equbsCompleted, @JsonKey(fromJson: _toInt) this.equbsLeftEarly = 0, @JsonKey(fromJson: _toInt) required this.equbsHosted, @JsonKey(fromJson: _toInt) required this.hostedEqubsCompleted, @JsonKey(fromJson: _toInt) required this.onTimePayments, @JsonKey(fromJson: _toInt) required this.latePayments, @JsonKey(fromJson: _toInt) required this.missedPayments, @JsonKey(fromJson: _toInt) this.turnsParticipated = 0, @JsonKey(fromJson: _toInt) required this.payoutsReceived, @JsonKey(fromJson: _toInt) required this.payoutsConfirmed, @JsonKey(fromJson: _toInt) required this.removalsCount, @JsonKey(fromJson: _toInt) required this.disputesCount, @JsonKey(fromJson: _toInt) this.cancelledGroupsCount = 0, @JsonKey(fromJson: _toInt) this.hostDisputesCount = 0, required this.components, this.baseScore, this.activityFactor, this.adjustedScore, this.confidenceFactor, this.lastEqubActivityAt, this.onTimePaymentRate, this.hostedCompletionRate, required this.updatedAt, required this.eligibility, final  List<ReputationBadgeModel> badges = const <ReputationBadgeModel>[]}): _badges = badges,super._();
  factory _ReputationProfileModel.fromJson(Map<String, dynamic> json) => _$ReputationProfileModelFromJson(json);

@override final  String userId;
@override@JsonKey(fromJson: _toInt) final  int trustScore;
@override final  String trustLevel;
@override final  String summaryLabel;
@override@JsonKey(fromJson: _toInt) final  int equbsJoined;
@override@JsonKey(fromJson: _toInt) final  int equbsCompleted;
@override@JsonKey(fromJson: _toInt) final  int equbsLeftEarly;
@override@JsonKey(fromJson: _toInt) final  int equbsHosted;
@override@JsonKey(fromJson: _toInt) final  int hostedEqubsCompleted;
@override@JsonKey(fromJson: _toInt) final  int onTimePayments;
@override@JsonKey(fromJson: _toInt) final  int latePayments;
@override@JsonKey(fromJson: _toInt) final  int missedPayments;
@override@JsonKey(fromJson: _toInt) final  int turnsParticipated;
@override@JsonKey(fromJson: _toInt) final  int payoutsReceived;
@override@JsonKey(fromJson: _toInt) final  int payoutsConfirmed;
@override@JsonKey(fromJson: _toInt) final  int removalsCount;
@override@JsonKey(fromJson: _toInt) final  int disputesCount;
@override@JsonKey(fromJson: _toInt) final  int cancelledGroupsCount;
@override@JsonKey(fromJson: _toInt) final  int hostDisputesCount;
@override final  ReputationComponentsModel components;
@override final  double? baseScore;
@override final  double? activityFactor;
@override final  double? adjustedScore;
@override final  double? confidenceFactor;
@override final  DateTime? lastEqubActivityAt;
@override final  double? onTimePaymentRate;
@override final  double? hostedCompletionRate;
@override final  DateTime updatedAt;
@override final  ReputationEligibilityModel eligibility;
 final  List<ReputationBadgeModel> _badges;
@override@JsonKey() List<ReputationBadgeModel> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}


/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReputationProfileModelCopyWith<_ReputationProfileModel> get copyWith => __$ReputationProfileModelCopyWithImpl<_ReputationProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReputationProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReputationProfileModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.trustLevel, trustLevel) || other.trustLevel == trustLevel)&&(identical(other.summaryLabel, summaryLabel) || other.summaryLabel == summaryLabel)&&(identical(other.equbsJoined, equbsJoined) || other.equbsJoined == equbsJoined)&&(identical(other.equbsCompleted, equbsCompleted) || other.equbsCompleted == equbsCompleted)&&(identical(other.equbsLeftEarly, equbsLeftEarly) || other.equbsLeftEarly == equbsLeftEarly)&&(identical(other.equbsHosted, equbsHosted) || other.equbsHosted == equbsHosted)&&(identical(other.hostedEqubsCompleted, hostedEqubsCompleted) || other.hostedEqubsCompleted == hostedEqubsCompleted)&&(identical(other.onTimePayments, onTimePayments) || other.onTimePayments == onTimePayments)&&(identical(other.latePayments, latePayments) || other.latePayments == latePayments)&&(identical(other.missedPayments, missedPayments) || other.missedPayments == missedPayments)&&(identical(other.turnsParticipated, turnsParticipated) || other.turnsParticipated == turnsParticipated)&&(identical(other.payoutsReceived, payoutsReceived) || other.payoutsReceived == payoutsReceived)&&(identical(other.payoutsConfirmed, payoutsConfirmed) || other.payoutsConfirmed == payoutsConfirmed)&&(identical(other.removalsCount, removalsCount) || other.removalsCount == removalsCount)&&(identical(other.disputesCount, disputesCount) || other.disputesCount == disputesCount)&&(identical(other.cancelledGroupsCount, cancelledGroupsCount) || other.cancelledGroupsCount == cancelledGroupsCount)&&(identical(other.hostDisputesCount, hostDisputesCount) || other.hostDisputesCount == hostDisputesCount)&&(identical(other.components, components) || other.components == components)&&(identical(other.baseScore, baseScore) || other.baseScore == baseScore)&&(identical(other.activityFactor, activityFactor) || other.activityFactor == activityFactor)&&(identical(other.adjustedScore, adjustedScore) || other.adjustedScore == adjustedScore)&&(identical(other.confidenceFactor, confidenceFactor) || other.confidenceFactor == confidenceFactor)&&(identical(other.lastEqubActivityAt, lastEqubActivityAt) || other.lastEqubActivityAt == lastEqubActivityAt)&&(identical(other.onTimePaymentRate, onTimePaymentRate) || other.onTimePaymentRate == onTimePaymentRate)&&(identical(other.hostedCompletionRate, hostedCompletionRate) || other.hostedCompletionRate == hostedCompletionRate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.eligibility, eligibility) || other.eligibility == eligibility)&&const DeepCollectionEquality().equals(other._badges, _badges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,userId,trustScore,trustLevel,summaryLabel,equbsJoined,equbsCompleted,equbsLeftEarly,equbsHosted,hostedEqubsCompleted,onTimePayments,latePayments,missedPayments,turnsParticipated,payoutsReceived,payoutsConfirmed,removalsCount,disputesCount,cancelledGroupsCount,hostDisputesCount,components,baseScore,activityFactor,adjustedScore,confidenceFactor,lastEqubActivityAt,onTimePaymentRate,hostedCompletionRate,updatedAt,eligibility,const DeepCollectionEquality().hash(_badges)]);

@override
String toString() {
  return 'ReputationProfileModel(userId: $userId, trustScore: $trustScore, trustLevel: $trustLevel, summaryLabel: $summaryLabel, equbsJoined: $equbsJoined, equbsCompleted: $equbsCompleted, equbsLeftEarly: $equbsLeftEarly, equbsHosted: $equbsHosted, hostedEqubsCompleted: $hostedEqubsCompleted, onTimePayments: $onTimePayments, latePayments: $latePayments, missedPayments: $missedPayments, turnsParticipated: $turnsParticipated, payoutsReceived: $payoutsReceived, payoutsConfirmed: $payoutsConfirmed, removalsCount: $removalsCount, disputesCount: $disputesCount, cancelledGroupsCount: $cancelledGroupsCount, hostDisputesCount: $hostDisputesCount, components: $components, baseScore: $baseScore, activityFactor: $activityFactor, adjustedScore: $adjustedScore, confidenceFactor: $confidenceFactor, lastEqubActivityAt: $lastEqubActivityAt, onTimePaymentRate: $onTimePaymentRate, hostedCompletionRate: $hostedCompletionRate, updatedAt: $updatedAt, eligibility: $eligibility, badges: $badges)';
}


}

/// @nodoc
abstract mixin class _$ReputationProfileModelCopyWith<$Res> implements $ReputationProfileModelCopyWith<$Res> {
  factory _$ReputationProfileModelCopyWith(_ReputationProfileModel value, $Res Function(_ReputationProfileModel) _then) = __$ReputationProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String userId,@JsonKey(fromJson: _toInt) int trustScore, String trustLevel, String summaryLabel,@JsonKey(fromJson: _toInt) int equbsJoined,@JsonKey(fromJson: _toInt) int equbsCompleted,@JsonKey(fromJson: _toInt) int equbsLeftEarly,@JsonKey(fromJson: _toInt) int equbsHosted,@JsonKey(fromJson: _toInt) int hostedEqubsCompleted,@JsonKey(fromJson: _toInt) int onTimePayments,@JsonKey(fromJson: _toInt) int latePayments,@JsonKey(fromJson: _toInt) int missedPayments,@JsonKey(fromJson: _toInt) int turnsParticipated,@JsonKey(fromJson: _toInt) int payoutsReceived,@JsonKey(fromJson: _toInt) int payoutsConfirmed,@JsonKey(fromJson: _toInt) int removalsCount,@JsonKey(fromJson: _toInt) int disputesCount,@JsonKey(fromJson: _toInt) int cancelledGroupsCount,@JsonKey(fromJson: _toInt) int hostDisputesCount, ReputationComponentsModel components, double? baseScore, double? activityFactor, double? adjustedScore, double? confidenceFactor, DateTime? lastEqubActivityAt, double? onTimePaymentRate, double? hostedCompletionRate, DateTime updatedAt, ReputationEligibilityModel eligibility, List<ReputationBadgeModel> badges
});


@override $ReputationComponentsModelCopyWith<$Res> get components;@override $ReputationEligibilityModelCopyWith<$Res> get eligibility;

}
/// @nodoc
class __$ReputationProfileModelCopyWithImpl<$Res>
    implements _$ReputationProfileModelCopyWith<$Res> {
  __$ReputationProfileModelCopyWithImpl(this._self, this._then);

  final _ReputationProfileModel _self;
  final $Res Function(_ReputationProfileModel) _then;

/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? trustScore = null,Object? trustLevel = null,Object? summaryLabel = null,Object? equbsJoined = null,Object? equbsCompleted = null,Object? equbsLeftEarly = null,Object? equbsHosted = null,Object? hostedEqubsCompleted = null,Object? onTimePayments = null,Object? latePayments = null,Object? missedPayments = null,Object? turnsParticipated = null,Object? payoutsReceived = null,Object? payoutsConfirmed = null,Object? removalsCount = null,Object? disputesCount = null,Object? cancelledGroupsCount = null,Object? hostDisputesCount = null,Object? components = null,Object? baseScore = freezed,Object? activityFactor = freezed,Object? adjustedScore = freezed,Object? confidenceFactor = freezed,Object? lastEqubActivityAt = freezed,Object? onTimePaymentRate = freezed,Object? hostedCompletionRate = freezed,Object? updatedAt = null,Object? eligibility = null,Object? badges = null,}) {
  return _then(_ReputationProfileModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,trustLevel: null == trustLevel ? _self.trustLevel : trustLevel // ignore: cast_nullable_to_non_nullable
as String,summaryLabel: null == summaryLabel ? _self.summaryLabel : summaryLabel // ignore: cast_nullable_to_non_nullable
as String,equbsJoined: null == equbsJoined ? _self.equbsJoined : equbsJoined // ignore: cast_nullable_to_non_nullable
as int,equbsCompleted: null == equbsCompleted ? _self.equbsCompleted : equbsCompleted // ignore: cast_nullable_to_non_nullable
as int,equbsLeftEarly: null == equbsLeftEarly ? _self.equbsLeftEarly : equbsLeftEarly // ignore: cast_nullable_to_non_nullable
as int,equbsHosted: null == equbsHosted ? _self.equbsHosted : equbsHosted // ignore: cast_nullable_to_non_nullable
as int,hostedEqubsCompleted: null == hostedEqubsCompleted ? _self.hostedEqubsCompleted : hostedEqubsCompleted // ignore: cast_nullable_to_non_nullable
as int,onTimePayments: null == onTimePayments ? _self.onTimePayments : onTimePayments // ignore: cast_nullable_to_non_nullable
as int,latePayments: null == latePayments ? _self.latePayments : latePayments // ignore: cast_nullable_to_non_nullable
as int,missedPayments: null == missedPayments ? _self.missedPayments : missedPayments // ignore: cast_nullable_to_non_nullable
as int,turnsParticipated: null == turnsParticipated ? _self.turnsParticipated : turnsParticipated // ignore: cast_nullable_to_non_nullable
as int,payoutsReceived: null == payoutsReceived ? _self.payoutsReceived : payoutsReceived // ignore: cast_nullable_to_non_nullable
as int,payoutsConfirmed: null == payoutsConfirmed ? _self.payoutsConfirmed : payoutsConfirmed // ignore: cast_nullable_to_non_nullable
as int,removalsCount: null == removalsCount ? _self.removalsCount : removalsCount // ignore: cast_nullable_to_non_nullable
as int,disputesCount: null == disputesCount ? _self.disputesCount : disputesCount // ignore: cast_nullable_to_non_nullable
as int,cancelledGroupsCount: null == cancelledGroupsCount ? _self.cancelledGroupsCount : cancelledGroupsCount // ignore: cast_nullable_to_non_nullable
as int,hostDisputesCount: null == hostDisputesCount ? _self.hostDisputesCount : hostDisputesCount // ignore: cast_nullable_to_non_nullable
as int,components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as ReputationComponentsModel,baseScore: freezed == baseScore ? _self.baseScore : baseScore // ignore: cast_nullable_to_non_nullable
as double?,activityFactor: freezed == activityFactor ? _self.activityFactor : activityFactor // ignore: cast_nullable_to_non_nullable
as double?,adjustedScore: freezed == adjustedScore ? _self.adjustedScore : adjustedScore // ignore: cast_nullable_to_non_nullable
as double?,confidenceFactor: freezed == confidenceFactor ? _self.confidenceFactor : confidenceFactor // ignore: cast_nullable_to_non_nullable
as double?,lastEqubActivityAt: freezed == lastEqubActivityAt ? _self.lastEqubActivityAt : lastEqubActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,onTimePaymentRate: freezed == onTimePaymentRate ? _self.onTimePaymentRate : onTimePaymentRate // ignore: cast_nullable_to_non_nullable
as double?,hostedCompletionRate: freezed == hostedCompletionRate ? _self.hostedCompletionRate : hostedCompletionRate // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,eligibility: null == eligibility ? _self.eligibility : eligibility // ignore: cast_nullable_to_non_nullable
as ReputationEligibilityModel,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<ReputationBadgeModel>,
  ));
}

/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReputationComponentsModelCopyWith<$Res> get components {
  
  return $ReputationComponentsModelCopyWith<$Res>(_self.components, (value) {
    return _then(_self.copyWith(components: value));
  });
}/// Create a copy of ReputationProfileModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReputationEligibilityModelCopyWith<$Res> get eligibility {
  
  return $ReputationEligibilityModelCopyWith<$Res>(_self.eligibility, (value) {
    return _then(_self.copyWith(eligibility: value));
  });
}
}

// dart format on
