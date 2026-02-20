// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {

 String get id; String get userId; String? get groupId;@JsonKey(unknownEnumValue: NotificationTypeModel.unknown) NotificationTypeModel get type; String get title; String get body;@JsonKey(fromJson: _mapFromJson, toJson: _mapToJson) Map<String, dynamic>? get dataJson;@JsonKey(unknownEnumValue: NotificationStatusModel.unknown) NotificationStatusModel get status; DateTime get createdAt; DateTime? get readAt;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.dataJson, dataJson)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,groupId,type,title,body,const DeepCollectionEquality().hash(dataJson),status,createdAt,readAt);

@override
String toString() {
  return 'NotificationModel(id: $id, userId: $userId, groupId: $groupId, type: $type, title: $title, body: $body, dataJson: $dataJson, status: $status, createdAt: $createdAt, readAt: $readAt)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? groupId,@JsonKey(unknownEnumValue: NotificationTypeModel.unknown) NotificationTypeModel type, String title, String body,@JsonKey(fromJson: _mapFromJson, toJson: _mapToJson) Map<String, dynamic>? dataJson,@JsonKey(unknownEnumValue: NotificationStatusModel.unknown) NotificationStatusModel status, DateTime createdAt, DateTime? readAt
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? groupId = freezed,Object? type = null,Object? title = null,Object? body = null,Object? dataJson = freezed,Object? status = null,Object? createdAt = null,Object? readAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationTypeModel,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,dataJson: freezed == dataJson ? _self.dataJson : dataJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatusModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? groupId, @JsonKey(unknownEnumValue: NotificationTypeModel.unknown)  NotificationTypeModel type,  String title,  String body, @JsonKey(fromJson: _mapFromJson, toJson: _mapToJson)  Map<String, dynamic>? dataJson, @JsonKey(unknownEnumValue: NotificationStatusModel.unknown)  NotificationStatusModel status,  DateTime createdAt,  DateTime? readAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.userId,_that.groupId,_that.type,_that.title,_that.body,_that.dataJson,_that.status,_that.createdAt,_that.readAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? groupId, @JsonKey(unknownEnumValue: NotificationTypeModel.unknown)  NotificationTypeModel type,  String title,  String body, @JsonKey(fromJson: _mapFromJson, toJson: _mapToJson)  Map<String, dynamic>? dataJson, @JsonKey(unknownEnumValue: NotificationStatusModel.unknown)  NotificationStatusModel status,  DateTime createdAt,  DateTime? readAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.id,_that.userId,_that.groupId,_that.type,_that.title,_that.body,_that.dataJson,_that.status,_that.createdAt,_that.readAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? groupId, @JsonKey(unknownEnumValue: NotificationTypeModel.unknown)  NotificationTypeModel type,  String title,  String body, @JsonKey(fromJson: _mapFromJson, toJson: _mapToJson)  Map<String, dynamic>? dataJson, @JsonKey(unknownEnumValue: NotificationStatusModel.unknown)  NotificationStatusModel status,  DateTime createdAt,  DateTime? readAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.userId,_that.groupId,_that.type,_that.title,_that.body,_that.dataJson,_that.status,_that.createdAt,_that.readAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationModel extends NotificationModel {
  const _NotificationModel({required this.id, required this.userId, this.groupId, @JsonKey(unknownEnumValue: NotificationTypeModel.unknown) required this.type, required this.title, required this.body, @JsonKey(fromJson: _mapFromJson, toJson: _mapToJson) final  Map<String, dynamic>? dataJson, @JsonKey(unknownEnumValue: NotificationStatusModel.unknown) required this.status, required this.createdAt, this.readAt}): _dataJson = dataJson,super._();
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? groupId;
@override@JsonKey(unknownEnumValue: NotificationTypeModel.unknown) final  NotificationTypeModel type;
@override final  String title;
@override final  String body;
 final  Map<String, dynamic>? _dataJson;
@override@JsonKey(fromJson: _mapFromJson, toJson: _mapToJson) Map<String, dynamic>? get dataJson {
  final value = _dataJson;
  if (value == null) return null;
  if (_dataJson is EqualUnmodifiableMapView) return _dataJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(unknownEnumValue: NotificationStatusModel.unknown) final  NotificationStatusModel status;
@override final  DateTime createdAt;
@override final  DateTime? readAt;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._dataJson, _dataJson)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,groupId,type,title,body,const DeepCollectionEquality().hash(_dataJson),status,createdAt,readAt);

@override
String toString() {
  return 'NotificationModel(id: $id, userId: $userId, groupId: $groupId, type: $type, title: $title, body: $body, dataJson: $dataJson, status: $status, createdAt: $createdAt, readAt: $readAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? groupId,@JsonKey(unknownEnumValue: NotificationTypeModel.unknown) NotificationTypeModel type, String title, String body,@JsonKey(fromJson: _mapFromJson, toJson: _mapToJson) Map<String, dynamic>? dataJson,@JsonKey(unknownEnumValue: NotificationStatusModel.unknown) NotificationStatusModel status, DateTime createdAt, DateTime? readAt
});




}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? groupId = freezed,Object? type = null,Object? title = null,Object? body = null,Object? dataJson = freezed,Object? status = null,Object? createdAt = null,Object? readAt = freezed,}) {
  return _then(_NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationTypeModel,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,dataJson: freezed == dataJson ? _self._dataJson : dataJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatusModel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NotificationListModel {

 List<NotificationModel> get items;@JsonKey(fromJson: _toInt) int get total;@JsonKey(fromJson: _toInt) int get offset;@JsonKey(fromJson: _toInt) int get limit;
/// Create a copy of NotificationListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationListModelCopyWith<NotificationListModel> get copyWith => _$NotificationListModelCopyWithImpl<NotificationListModel>(this as NotificationListModel, _$identity);

  /// Serializes this NotificationListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationListModel&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,offset,limit);

@override
String toString() {
  return 'NotificationListModel(items: $items, total: $total, offset: $offset, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $NotificationListModelCopyWith<$Res>  {
  factory $NotificationListModelCopyWith(NotificationListModel value, $Res Function(NotificationListModel) _then) = _$NotificationListModelCopyWithImpl;
@useResult
$Res call({
 List<NotificationModel> items,@JsonKey(fromJson: _toInt) int total,@JsonKey(fromJson: _toInt) int offset,@JsonKey(fromJson: _toInt) int limit
});




}
/// @nodoc
class _$NotificationListModelCopyWithImpl<$Res>
    implements $NotificationListModelCopyWith<$Res> {
  _$NotificationListModelCopyWithImpl(this._self, this._then);

  final NotificationListModel _self;
  final $Res Function(NotificationListModel) _then;

/// Create a copy of NotificationListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? offset = null,Object? limit = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationListModel].
extension NotificationListModelPatterns on NotificationListModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationListModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationListModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationListModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationListModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationListModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NotificationModel> items, @JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int offset, @JsonKey(fromJson: _toInt)  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationListModel() when $default != null:
return $default(_that.items,_that.total,_that.offset,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NotificationModel> items, @JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int offset, @JsonKey(fromJson: _toInt)  int limit)  $default,) {final _that = this;
switch (_that) {
case _NotificationListModel():
return $default(_that.items,_that.total,_that.offset,_that.limit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NotificationModel> items, @JsonKey(fromJson: _toInt)  int total, @JsonKey(fromJson: _toInt)  int offset, @JsonKey(fromJson: _toInt)  int limit)?  $default,) {final _that = this;
switch (_that) {
case _NotificationListModel() when $default != null:
return $default(_that.items,_that.total,_that.offset,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationListModel implements NotificationListModel {
  const _NotificationListModel({final  List<NotificationModel> items = const <NotificationModel>[], @JsonKey(fromJson: _toInt) this.total = 0, @JsonKey(fromJson: _toInt) this.offset = 0, @JsonKey(fromJson: _toInt) this.limit = 20}): _items = items;
  factory _NotificationListModel.fromJson(Map<String, dynamic> json) => _$NotificationListModelFromJson(json);

 final  List<NotificationModel> _items;
@override@JsonKey() List<NotificationModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(fromJson: _toInt) final  int total;
@override@JsonKey(fromJson: _toInt) final  int offset;
@override@JsonKey(fromJson: _toInt) final  int limit;

/// Create a copy of NotificationListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationListModelCopyWith<_NotificationListModel> get copyWith => __$NotificationListModelCopyWithImpl<_NotificationListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationListModel&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,offset,limit);

@override
String toString() {
  return 'NotificationListModel(items: $items, total: $total, offset: $offset, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$NotificationListModelCopyWith<$Res> implements $NotificationListModelCopyWith<$Res> {
  factory _$NotificationListModelCopyWith(_NotificationListModel value, $Res Function(_NotificationListModel) _then) = __$NotificationListModelCopyWithImpl;
@override @useResult
$Res call({
 List<NotificationModel> items,@JsonKey(fromJson: _toInt) int total,@JsonKey(fromJson: _toInt) int offset,@JsonKey(fromJson: _toInt) int limit
});




}
/// @nodoc
class __$NotificationListModelCopyWithImpl<$Res>
    implements _$NotificationListModelCopyWith<$Res> {
  __$NotificationListModelCopyWithImpl(this._self, this._then);

  final _NotificationListModel _self;
  final $Res Function(_NotificationListModel) _then;

/// Create a copy of NotificationListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? offset = null,Object? limit = null,}) {
  return _then(_NotificationListModel(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
