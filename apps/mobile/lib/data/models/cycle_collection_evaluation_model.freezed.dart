// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_collection_evaluation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CycleCollectionEvaluationModel {

 String get cycleId; DateTime get dueAt; int get graceDays; DateTime get graceDeadline; DateTime get evaluatedAt; bool get strictCollection; bool get allVerified; bool get readyForPayout;@JsonKey(fromJson: _toInt) int get overdueCount;@JsonKey(fromJson: _toInt) int get lateMarkedCount;@JsonKey(fromJson: _toInt) int get fineLedgerEntriesCreated;@JsonKey(fromJson: _toInt) int get notifiedMembersCount;@JsonKey(fromJson: _toInt) int get notifiedGuarantorsCount;
/// Create a copy of CycleCollectionEvaluationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleCollectionEvaluationModelCopyWith<CycleCollectionEvaluationModel> get copyWith => _$CycleCollectionEvaluationModelCopyWithImpl<CycleCollectionEvaluationModel>(this as CycleCollectionEvaluationModel, _$identity);

  /// Serializes this CycleCollectionEvaluationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleCollectionEvaluationModel&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.graceDeadline, graceDeadline) || other.graceDeadline == graceDeadline)&&(identical(other.evaluatedAt, evaluatedAt) || other.evaluatedAt == evaluatedAt)&&(identical(other.strictCollection, strictCollection) || other.strictCollection == strictCollection)&&(identical(other.allVerified, allVerified) || other.allVerified == allVerified)&&(identical(other.readyForPayout, readyForPayout) || other.readyForPayout == readyForPayout)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.lateMarkedCount, lateMarkedCount) || other.lateMarkedCount == lateMarkedCount)&&(identical(other.fineLedgerEntriesCreated, fineLedgerEntriesCreated) || other.fineLedgerEntriesCreated == fineLedgerEntriesCreated)&&(identical(other.notifiedMembersCount, notifiedMembersCount) || other.notifiedMembersCount == notifiedMembersCount)&&(identical(other.notifiedGuarantorsCount, notifiedGuarantorsCount) || other.notifiedGuarantorsCount == notifiedGuarantorsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cycleId,dueAt,graceDays,graceDeadline,evaluatedAt,strictCollection,allVerified,readyForPayout,overdueCount,lateMarkedCount,fineLedgerEntriesCreated,notifiedMembersCount,notifiedGuarantorsCount);

@override
String toString() {
  return 'CycleCollectionEvaluationModel(cycleId: $cycleId, dueAt: $dueAt, graceDays: $graceDays, graceDeadline: $graceDeadline, evaluatedAt: $evaluatedAt, strictCollection: $strictCollection, allVerified: $allVerified, readyForPayout: $readyForPayout, overdueCount: $overdueCount, lateMarkedCount: $lateMarkedCount, fineLedgerEntriesCreated: $fineLedgerEntriesCreated, notifiedMembersCount: $notifiedMembersCount, notifiedGuarantorsCount: $notifiedGuarantorsCount)';
}


}

/// @nodoc
abstract mixin class $CycleCollectionEvaluationModelCopyWith<$Res>  {
  factory $CycleCollectionEvaluationModelCopyWith(CycleCollectionEvaluationModel value, $Res Function(CycleCollectionEvaluationModel) _then) = _$CycleCollectionEvaluationModelCopyWithImpl;
@useResult
$Res call({
 String cycleId, DateTime dueAt, int graceDays, DateTime graceDeadline, DateTime evaluatedAt, bool strictCollection, bool allVerified, bool readyForPayout,@JsonKey(fromJson: _toInt) int overdueCount,@JsonKey(fromJson: _toInt) int lateMarkedCount,@JsonKey(fromJson: _toInt) int fineLedgerEntriesCreated,@JsonKey(fromJson: _toInt) int notifiedMembersCount,@JsonKey(fromJson: _toInt) int notifiedGuarantorsCount
});




}
/// @nodoc
class _$CycleCollectionEvaluationModelCopyWithImpl<$Res>
    implements $CycleCollectionEvaluationModelCopyWith<$Res> {
  _$CycleCollectionEvaluationModelCopyWithImpl(this._self, this._then);

  final CycleCollectionEvaluationModel _self;
  final $Res Function(CycleCollectionEvaluationModel) _then;

/// Create a copy of CycleCollectionEvaluationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cycleId = null,Object? dueAt = null,Object? graceDays = null,Object? graceDeadline = null,Object? evaluatedAt = null,Object? strictCollection = null,Object? allVerified = null,Object? readyForPayout = null,Object? overdueCount = null,Object? lateMarkedCount = null,Object? fineLedgerEntriesCreated = null,Object? notifiedMembersCount = null,Object? notifiedGuarantorsCount = null,}) {
  return _then(_self.copyWith(
cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,graceDeadline: null == graceDeadline ? _self.graceDeadline : graceDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,evaluatedAt: null == evaluatedAt ? _self.evaluatedAt : evaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,strictCollection: null == strictCollection ? _self.strictCollection : strictCollection // ignore: cast_nullable_to_non_nullable
as bool,allVerified: null == allVerified ? _self.allVerified : allVerified // ignore: cast_nullable_to_non_nullable
as bool,readyForPayout: null == readyForPayout ? _self.readyForPayout : readyForPayout // ignore: cast_nullable_to_non_nullable
as bool,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,lateMarkedCount: null == lateMarkedCount ? _self.lateMarkedCount : lateMarkedCount // ignore: cast_nullable_to_non_nullable
as int,fineLedgerEntriesCreated: null == fineLedgerEntriesCreated ? _self.fineLedgerEntriesCreated : fineLedgerEntriesCreated // ignore: cast_nullable_to_non_nullable
as int,notifiedMembersCount: null == notifiedMembersCount ? _self.notifiedMembersCount : notifiedMembersCount // ignore: cast_nullable_to_non_nullable
as int,notifiedGuarantorsCount: null == notifiedGuarantorsCount ? _self.notifiedGuarantorsCount : notifiedGuarantorsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleCollectionEvaluationModel].
extension CycleCollectionEvaluationModelPatterns on CycleCollectionEvaluationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleCollectionEvaluationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleCollectionEvaluationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleCollectionEvaluationModel value)  $default,){
final _that = this;
switch (_that) {
case _CycleCollectionEvaluationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleCollectionEvaluationModel value)?  $default,){
final _that = this;
switch (_that) {
case _CycleCollectionEvaluationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String cycleId,  DateTime dueAt,  int graceDays,  DateTime graceDeadline,  DateTime evaluatedAt,  bool strictCollection,  bool allVerified,  bool readyForPayout, @JsonKey(fromJson: _toInt)  int overdueCount, @JsonKey(fromJson: _toInt)  int lateMarkedCount, @JsonKey(fromJson: _toInt)  int fineLedgerEntriesCreated, @JsonKey(fromJson: _toInt)  int notifiedMembersCount, @JsonKey(fromJson: _toInt)  int notifiedGuarantorsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleCollectionEvaluationModel() when $default != null:
return $default(_that.cycleId,_that.dueAt,_that.graceDays,_that.graceDeadline,_that.evaluatedAt,_that.strictCollection,_that.allVerified,_that.readyForPayout,_that.overdueCount,_that.lateMarkedCount,_that.fineLedgerEntriesCreated,_that.notifiedMembersCount,_that.notifiedGuarantorsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String cycleId,  DateTime dueAt,  int graceDays,  DateTime graceDeadline,  DateTime evaluatedAt,  bool strictCollection,  bool allVerified,  bool readyForPayout, @JsonKey(fromJson: _toInt)  int overdueCount, @JsonKey(fromJson: _toInt)  int lateMarkedCount, @JsonKey(fromJson: _toInt)  int fineLedgerEntriesCreated, @JsonKey(fromJson: _toInt)  int notifiedMembersCount, @JsonKey(fromJson: _toInt)  int notifiedGuarantorsCount)  $default,) {final _that = this;
switch (_that) {
case _CycleCollectionEvaluationModel():
return $default(_that.cycleId,_that.dueAt,_that.graceDays,_that.graceDeadline,_that.evaluatedAt,_that.strictCollection,_that.allVerified,_that.readyForPayout,_that.overdueCount,_that.lateMarkedCount,_that.fineLedgerEntriesCreated,_that.notifiedMembersCount,_that.notifiedGuarantorsCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String cycleId,  DateTime dueAt,  int graceDays,  DateTime graceDeadline,  DateTime evaluatedAt,  bool strictCollection,  bool allVerified,  bool readyForPayout, @JsonKey(fromJson: _toInt)  int overdueCount, @JsonKey(fromJson: _toInt)  int lateMarkedCount, @JsonKey(fromJson: _toInt)  int fineLedgerEntriesCreated, @JsonKey(fromJson: _toInt)  int notifiedMembersCount, @JsonKey(fromJson: _toInt)  int notifiedGuarantorsCount)?  $default,) {final _that = this;
switch (_that) {
case _CycleCollectionEvaluationModel() when $default != null:
return $default(_that.cycleId,_that.dueAt,_that.graceDays,_that.graceDeadline,_that.evaluatedAt,_that.strictCollection,_that.allVerified,_that.readyForPayout,_that.overdueCount,_that.lateMarkedCount,_that.fineLedgerEntriesCreated,_that.notifiedMembersCount,_that.notifiedGuarantorsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CycleCollectionEvaluationModel implements CycleCollectionEvaluationModel {
  const _CycleCollectionEvaluationModel({required this.cycleId, required this.dueAt, required this.graceDays, required this.graceDeadline, required this.evaluatedAt, required this.strictCollection, required this.allVerified, required this.readyForPayout, @JsonKey(fromJson: _toInt) required this.overdueCount, @JsonKey(fromJson: _toInt) required this.lateMarkedCount, @JsonKey(fromJson: _toInt) required this.fineLedgerEntriesCreated, @JsonKey(fromJson: _toInt) required this.notifiedMembersCount, @JsonKey(fromJson: _toInt) required this.notifiedGuarantorsCount});
  factory _CycleCollectionEvaluationModel.fromJson(Map<String, dynamic> json) => _$CycleCollectionEvaluationModelFromJson(json);

@override final  String cycleId;
@override final  DateTime dueAt;
@override final  int graceDays;
@override final  DateTime graceDeadline;
@override final  DateTime evaluatedAt;
@override final  bool strictCollection;
@override final  bool allVerified;
@override final  bool readyForPayout;
@override@JsonKey(fromJson: _toInt) final  int overdueCount;
@override@JsonKey(fromJson: _toInt) final  int lateMarkedCount;
@override@JsonKey(fromJson: _toInt) final  int fineLedgerEntriesCreated;
@override@JsonKey(fromJson: _toInt) final  int notifiedMembersCount;
@override@JsonKey(fromJson: _toInt) final  int notifiedGuarantorsCount;

/// Create a copy of CycleCollectionEvaluationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleCollectionEvaluationModelCopyWith<_CycleCollectionEvaluationModel> get copyWith => __$CycleCollectionEvaluationModelCopyWithImpl<_CycleCollectionEvaluationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CycleCollectionEvaluationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleCollectionEvaluationModel&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.graceDays, graceDays) || other.graceDays == graceDays)&&(identical(other.graceDeadline, graceDeadline) || other.graceDeadline == graceDeadline)&&(identical(other.evaluatedAt, evaluatedAt) || other.evaluatedAt == evaluatedAt)&&(identical(other.strictCollection, strictCollection) || other.strictCollection == strictCollection)&&(identical(other.allVerified, allVerified) || other.allVerified == allVerified)&&(identical(other.readyForPayout, readyForPayout) || other.readyForPayout == readyForPayout)&&(identical(other.overdueCount, overdueCount) || other.overdueCount == overdueCount)&&(identical(other.lateMarkedCount, lateMarkedCount) || other.lateMarkedCount == lateMarkedCount)&&(identical(other.fineLedgerEntriesCreated, fineLedgerEntriesCreated) || other.fineLedgerEntriesCreated == fineLedgerEntriesCreated)&&(identical(other.notifiedMembersCount, notifiedMembersCount) || other.notifiedMembersCount == notifiedMembersCount)&&(identical(other.notifiedGuarantorsCount, notifiedGuarantorsCount) || other.notifiedGuarantorsCount == notifiedGuarantorsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cycleId,dueAt,graceDays,graceDeadline,evaluatedAt,strictCollection,allVerified,readyForPayout,overdueCount,lateMarkedCount,fineLedgerEntriesCreated,notifiedMembersCount,notifiedGuarantorsCount);

@override
String toString() {
  return 'CycleCollectionEvaluationModel(cycleId: $cycleId, dueAt: $dueAt, graceDays: $graceDays, graceDeadline: $graceDeadline, evaluatedAt: $evaluatedAt, strictCollection: $strictCollection, allVerified: $allVerified, readyForPayout: $readyForPayout, overdueCount: $overdueCount, lateMarkedCount: $lateMarkedCount, fineLedgerEntriesCreated: $fineLedgerEntriesCreated, notifiedMembersCount: $notifiedMembersCount, notifiedGuarantorsCount: $notifiedGuarantorsCount)';
}


}

/// @nodoc
abstract mixin class _$CycleCollectionEvaluationModelCopyWith<$Res> implements $CycleCollectionEvaluationModelCopyWith<$Res> {
  factory _$CycleCollectionEvaluationModelCopyWith(_CycleCollectionEvaluationModel value, $Res Function(_CycleCollectionEvaluationModel) _then) = __$CycleCollectionEvaluationModelCopyWithImpl;
@override @useResult
$Res call({
 String cycleId, DateTime dueAt, int graceDays, DateTime graceDeadline, DateTime evaluatedAt, bool strictCollection, bool allVerified, bool readyForPayout,@JsonKey(fromJson: _toInt) int overdueCount,@JsonKey(fromJson: _toInt) int lateMarkedCount,@JsonKey(fromJson: _toInt) int fineLedgerEntriesCreated,@JsonKey(fromJson: _toInt) int notifiedMembersCount,@JsonKey(fromJson: _toInt) int notifiedGuarantorsCount
});




}
/// @nodoc
class __$CycleCollectionEvaluationModelCopyWithImpl<$Res>
    implements _$CycleCollectionEvaluationModelCopyWith<$Res> {
  __$CycleCollectionEvaluationModelCopyWithImpl(this._self, this._then);

  final _CycleCollectionEvaluationModel _self;
  final $Res Function(_CycleCollectionEvaluationModel) _then;

/// Create a copy of CycleCollectionEvaluationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cycleId = null,Object? dueAt = null,Object? graceDays = null,Object? graceDeadline = null,Object? evaluatedAt = null,Object? strictCollection = null,Object? allVerified = null,Object? readyForPayout = null,Object? overdueCount = null,Object? lateMarkedCount = null,Object? fineLedgerEntriesCreated = null,Object? notifiedMembersCount = null,Object? notifiedGuarantorsCount = null,}) {
  return _then(_CycleCollectionEvaluationModel(
cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,graceDays: null == graceDays ? _self.graceDays : graceDays // ignore: cast_nullable_to_non_nullable
as int,graceDeadline: null == graceDeadline ? _self.graceDeadline : graceDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,evaluatedAt: null == evaluatedAt ? _self.evaluatedAt : evaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,strictCollection: null == strictCollection ? _self.strictCollection : strictCollection // ignore: cast_nullable_to_non_nullable
as bool,allVerified: null == allVerified ? _self.allVerified : allVerified // ignore: cast_nullable_to_non_nullable
as bool,readyForPayout: null == readyForPayout ? _self.readyForPayout : readyForPayout // ignore: cast_nullable_to_non_nullable
as bool,overdueCount: null == overdueCount ? _self.overdueCount : overdueCount // ignore: cast_nullable_to_non_nullable
as int,lateMarkedCount: null == lateMarkedCount ? _self.lateMarkedCount : lateMarkedCount // ignore: cast_nullable_to_non_nullable
as int,fineLedgerEntriesCreated: null == fineLedgerEntriesCreated ? _self.fineLedgerEntriesCreated : fineLedgerEntriesCreated // ignore: cast_nullable_to_non_nullable
as int,notifiedMembersCount: null == notifiedMembersCount ? _self.notifiedMembersCount : notifiedMembersCount // ignore: cast_nullable_to_non_nullable
as int,notifiedGuarantorsCount: null == notifiedGuarantorsCount ? _self.notifiedGuarantorsCount : notifiedGuarantorsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
