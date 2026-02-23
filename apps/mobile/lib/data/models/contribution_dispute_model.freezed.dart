// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribution_dispute_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContributionDisputeModel {

 String get id; String get groupId; String get cycleId; String get contributionId; String get reportedByUserId;@JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown) ContributionDisputeStatusModel get status; String get reason; String? get note; String? get mediationNote; DateTime? get mediatedAt; String? get mediatedByUserId; String? get resolutionOutcome; String? get resolutionNote; DateTime? get resolvedAt; String? get resolvedByUserId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ContributionDisputeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionDisputeModelCopyWith<ContributionDisputeModel> get copyWith => _$ContributionDisputeModelCopyWithImpl<ContributionDisputeModel>(this as ContributionDisputeModel, _$identity);

  /// Serializes this ContributionDisputeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionDisputeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.contributionId, contributionId) || other.contributionId == contributionId)&&(identical(other.reportedByUserId, reportedByUserId) || other.reportedByUserId == reportedByUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.mediationNote, mediationNote) || other.mediationNote == mediationNote)&&(identical(other.mediatedAt, mediatedAt) || other.mediatedAt == mediatedAt)&&(identical(other.mediatedByUserId, mediatedByUserId) || other.mediatedByUserId == mediatedByUserId)&&(identical(other.resolutionOutcome, resolutionOutcome) || other.resolutionOutcome == resolutionOutcome)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedByUserId, resolvedByUserId) || other.resolvedByUserId == resolvedByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,cycleId,contributionId,reportedByUserId,status,reason,note,mediationNote,mediatedAt,mediatedByUserId,resolutionOutcome,resolutionNote,resolvedAt,resolvedByUserId,createdAt,updatedAt);

@override
String toString() {
  return 'ContributionDisputeModel(id: $id, groupId: $groupId, cycleId: $cycleId, contributionId: $contributionId, reportedByUserId: $reportedByUserId, status: $status, reason: $reason, note: $note, mediationNote: $mediationNote, mediatedAt: $mediatedAt, mediatedByUserId: $mediatedByUserId, resolutionOutcome: $resolutionOutcome, resolutionNote: $resolutionNote, resolvedAt: $resolvedAt, resolvedByUserId: $resolvedByUserId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ContributionDisputeModelCopyWith<$Res>  {
  factory $ContributionDisputeModelCopyWith(ContributionDisputeModel value, $Res Function(ContributionDisputeModel) _then) = _$ContributionDisputeModelCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String cycleId, String contributionId, String reportedByUserId,@JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown) ContributionDisputeStatusModel status, String reason, String? note, String? mediationNote, DateTime? mediatedAt, String? mediatedByUserId, String? resolutionOutcome, String? resolutionNote, DateTime? resolvedAt, String? resolvedByUserId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ContributionDisputeModelCopyWithImpl<$Res>
    implements $ContributionDisputeModelCopyWith<$Res> {
  _$ContributionDisputeModelCopyWithImpl(this._self, this._then);

  final ContributionDisputeModel _self;
  final $Res Function(ContributionDisputeModel) _then;

/// Create a copy of ContributionDisputeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? cycleId = null,Object? contributionId = null,Object? reportedByUserId = null,Object? status = null,Object? reason = null,Object? note = freezed,Object? mediationNote = freezed,Object? mediatedAt = freezed,Object? mediatedByUserId = freezed,Object? resolutionOutcome = freezed,Object? resolutionNote = freezed,Object? resolvedAt = freezed,Object? resolvedByUserId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,contributionId: null == contributionId ? _self.contributionId : contributionId // ignore: cast_nullable_to_non_nullable
as String,reportedByUserId: null == reportedByUserId ? _self.reportedByUserId : reportedByUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionDisputeStatusModel,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,mediationNote: freezed == mediationNote ? _self.mediationNote : mediationNote // ignore: cast_nullable_to_non_nullable
as String?,mediatedAt: freezed == mediatedAt ? _self.mediatedAt : mediatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mediatedByUserId: freezed == mediatedByUserId ? _self.mediatedByUserId : mediatedByUserId // ignore: cast_nullable_to_non_nullable
as String?,resolutionOutcome: freezed == resolutionOutcome ? _self.resolutionOutcome : resolutionOutcome // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedByUserId: freezed == resolvedByUserId ? _self.resolvedByUserId : resolvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributionDisputeModel].
extension ContributionDisputeModelPatterns on ContributionDisputeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionDisputeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionDisputeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionDisputeModel value)  $default,){
final _that = this;
switch (_that) {
case _ContributionDisputeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionDisputeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionDisputeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String cycleId,  String contributionId,  String reportedByUserId, @JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown)  ContributionDisputeStatusModel status,  String reason,  String? note,  String? mediationNote,  DateTime? mediatedAt,  String? mediatedByUserId,  String? resolutionOutcome,  String? resolutionNote,  DateTime? resolvedAt,  String? resolvedByUserId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionDisputeModel() when $default != null:
return $default(_that.id,_that.groupId,_that.cycleId,_that.contributionId,_that.reportedByUserId,_that.status,_that.reason,_that.note,_that.mediationNote,_that.mediatedAt,_that.mediatedByUserId,_that.resolutionOutcome,_that.resolutionNote,_that.resolvedAt,_that.resolvedByUserId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String cycleId,  String contributionId,  String reportedByUserId, @JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown)  ContributionDisputeStatusModel status,  String reason,  String? note,  String? mediationNote,  DateTime? mediatedAt,  String? mediatedByUserId,  String? resolutionOutcome,  String? resolutionNote,  DateTime? resolvedAt,  String? resolvedByUserId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ContributionDisputeModel():
return $default(_that.id,_that.groupId,_that.cycleId,_that.contributionId,_that.reportedByUserId,_that.status,_that.reason,_that.note,_that.mediationNote,_that.mediatedAt,_that.mediatedByUserId,_that.resolutionOutcome,_that.resolutionNote,_that.resolvedAt,_that.resolvedByUserId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String cycleId,  String contributionId,  String reportedByUserId, @JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown)  ContributionDisputeStatusModel status,  String reason,  String? note,  String? mediationNote,  DateTime? mediatedAt,  String? mediatedByUserId,  String? resolutionOutcome,  String? resolutionNote,  DateTime? resolvedAt,  String? resolvedByUserId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ContributionDisputeModel() when $default != null:
return $default(_that.id,_that.groupId,_that.cycleId,_that.contributionId,_that.reportedByUserId,_that.status,_that.reason,_that.note,_that.mediationNote,_that.mediatedAt,_that.mediatedByUserId,_that.resolutionOutcome,_that.resolutionNote,_that.resolvedAt,_that.resolvedByUserId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionDisputeModel implements ContributionDisputeModel {
  const _ContributionDisputeModel({required this.id, required this.groupId, required this.cycleId, required this.contributionId, required this.reportedByUserId, @JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown) required this.status, required this.reason, this.note, this.mediationNote, this.mediatedAt, this.mediatedByUserId, this.resolutionOutcome, this.resolutionNote, this.resolvedAt, this.resolvedByUserId, required this.createdAt, required this.updatedAt});
  factory _ContributionDisputeModel.fromJson(Map<String, dynamic> json) => _$ContributionDisputeModelFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String cycleId;
@override final  String contributionId;
@override final  String reportedByUserId;
@override@JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown) final  ContributionDisputeStatusModel status;
@override final  String reason;
@override final  String? note;
@override final  String? mediationNote;
@override final  DateTime? mediatedAt;
@override final  String? mediatedByUserId;
@override final  String? resolutionOutcome;
@override final  String? resolutionNote;
@override final  DateTime? resolvedAt;
@override final  String? resolvedByUserId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ContributionDisputeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionDisputeModelCopyWith<_ContributionDisputeModel> get copyWith => __$ContributionDisputeModelCopyWithImpl<_ContributionDisputeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionDisputeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionDisputeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.contributionId, contributionId) || other.contributionId == contributionId)&&(identical(other.reportedByUserId, reportedByUserId) || other.reportedByUserId == reportedByUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.mediationNote, mediationNote) || other.mediationNote == mediationNote)&&(identical(other.mediatedAt, mediatedAt) || other.mediatedAt == mediatedAt)&&(identical(other.mediatedByUserId, mediatedByUserId) || other.mediatedByUserId == mediatedByUserId)&&(identical(other.resolutionOutcome, resolutionOutcome) || other.resolutionOutcome == resolutionOutcome)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedByUserId, resolvedByUserId) || other.resolvedByUserId == resolvedByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,cycleId,contributionId,reportedByUserId,status,reason,note,mediationNote,mediatedAt,mediatedByUserId,resolutionOutcome,resolutionNote,resolvedAt,resolvedByUserId,createdAt,updatedAt);

@override
String toString() {
  return 'ContributionDisputeModel(id: $id, groupId: $groupId, cycleId: $cycleId, contributionId: $contributionId, reportedByUserId: $reportedByUserId, status: $status, reason: $reason, note: $note, mediationNote: $mediationNote, mediatedAt: $mediatedAt, mediatedByUserId: $mediatedByUserId, resolutionOutcome: $resolutionOutcome, resolutionNote: $resolutionNote, resolvedAt: $resolvedAt, resolvedByUserId: $resolvedByUserId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ContributionDisputeModelCopyWith<$Res> implements $ContributionDisputeModelCopyWith<$Res> {
  factory _$ContributionDisputeModelCopyWith(_ContributionDisputeModel value, $Res Function(_ContributionDisputeModel) _then) = __$ContributionDisputeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String cycleId, String contributionId, String reportedByUserId,@JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown) ContributionDisputeStatusModel status, String reason, String? note, String? mediationNote, DateTime? mediatedAt, String? mediatedByUserId, String? resolutionOutcome, String? resolutionNote, DateTime? resolvedAt, String? resolvedByUserId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ContributionDisputeModelCopyWithImpl<$Res>
    implements _$ContributionDisputeModelCopyWith<$Res> {
  __$ContributionDisputeModelCopyWithImpl(this._self, this._then);

  final _ContributionDisputeModel _self;
  final $Res Function(_ContributionDisputeModel) _then;

/// Create a copy of ContributionDisputeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? cycleId = null,Object? contributionId = null,Object? reportedByUserId = null,Object? status = null,Object? reason = null,Object? note = freezed,Object? mediationNote = freezed,Object? mediatedAt = freezed,Object? mediatedByUserId = freezed,Object? resolutionOutcome = freezed,Object? resolutionNote = freezed,Object? resolvedAt = freezed,Object? resolvedByUserId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ContributionDisputeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,contributionId: null == contributionId ? _self.contributionId : contributionId // ignore: cast_nullable_to_non_nullable
as String,reportedByUserId: null == reportedByUserId ? _self.reportedByUserId : reportedByUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionDisputeStatusModel,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,mediationNote: freezed == mediationNote ? _self.mediationNote : mediationNote // ignore: cast_nullable_to_non_nullable
as String?,mediatedAt: freezed == mediatedAt ? _self.mediatedAt : mediatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mediatedByUserId: freezed == mediatedByUserId ? _self.mediatedByUserId : mediatedByUserId // ignore: cast_nullable_to_non_nullable
as String?,resolutionOutcome: freezed == resolutionOutcome ? _self.resolutionOutcome : resolutionOutcome // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedByUserId: freezed == resolvedByUserId ? _self.resolvedByUserId : resolvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
