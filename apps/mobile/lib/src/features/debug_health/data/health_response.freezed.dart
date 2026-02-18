// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthResponse {

 String get status; HealthChecks get checks; DateTime get timestamp;
/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthResponseCopyWith<HealthResponse> get copyWith => _$HealthResponseCopyWithImpl<HealthResponse>(this as HealthResponse, _$identity);

  /// Serializes this HealthResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.checks, checks) || other.checks == checks)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,checks,timestamp);

@override
String toString() {
  return 'HealthResponse(status: $status, checks: $checks, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $HealthResponseCopyWith<$Res>  {
  factory $HealthResponseCopyWith(HealthResponse value, $Res Function(HealthResponse) _then) = _$HealthResponseCopyWithImpl;
@useResult
$Res call({
 String status, HealthChecks checks, DateTime timestamp
});


$HealthChecksCopyWith<$Res> get checks;

}
/// @nodoc
class _$HealthResponseCopyWithImpl<$Res>
    implements $HealthResponseCopyWith<$Res> {
  _$HealthResponseCopyWithImpl(this._self, this._then);

  final HealthResponse _self;
  final $Res Function(HealthResponse) _then;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? checks = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as HealthChecks,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthChecksCopyWith<$Res> get checks {
  
  return $HealthChecksCopyWith<$Res>(_self.checks, (value) {
    return _then(_self.copyWith(checks: value));
  });
}
}


/// Adds pattern-matching-related methods to [HealthResponse].
extension HealthResponsePatterns on HealthResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthResponse value)  $default,){
final _that = this;
switch (_that) {
case _HealthResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthResponse value)?  $default,){
final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  HealthChecks checks,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
return $default(_that.status,_that.checks,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  HealthChecks checks,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _HealthResponse():
return $default(_that.status,_that.checks,_that.timestamp);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  HealthChecks checks,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _HealthResponse() when $default != null:
return $default(_that.status,_that.checks,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthResponse implements HealthResponse {
  const _HealthResponse({required this.status, required this.checks, required this.timestamp});
  factory _HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);

@override final  String status;
@override final  HealthChecks checks;
@override final  DateTime timestamp;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthResponseCopyWith<_HealthResponse> get copyWith => __$HealthResponseCopyWithImpl<_HealthResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.checks, checks) || other.checks == checks)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,checks,timestamp);

@override
String toString() {
  return 'HealthResponse(status: $status, checks: $checks, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$HealthResponseCopyWith<$Res> implements $HealthResponseCopyWith<$Res> {
  factory _$HealthResponseCopyWith(_HealthResponse value, $Res Function(_HealthResponse) _then) = __$HealthResponseCopyWithImpl;
@override @useResult
$Res call({
 String status, HealthChecks checks, DateTime timestamp
});


@override $HealthChecksCopyWith<$Res> get checks;

}
/// @nodoc
class __$HealthResponseCopyWithImpl<$Res>
    implements _$HealthResponseCopyWith<$Res> {
  __$HealthResponseCopyWithImpl(this._self, this._then);

  final _HealthResponse _self;
  final $Res Function(_HealthResponse) _then;

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? checks = null,Object? timestamp = null,}) {
  return _then(_HealthResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as HealthChecks,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of HealthResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthChecksCopyWith<$Res> get checks {
  
  return $HealthChecksCopyWith<$Res>(_self.checks, (value) {
    return _then(_self.copyWith(checks: value));
  });
}
}


/// @nodoc
mixin _$HealthChecks {

 String get database; String get redis;
/// Create a copy of HealthChecks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthChecksCopyWith<HealthChecks> get copyWith => _$HealthChecksCopyWithImpl<HealthChecks>(this as HealthChecks, _$identity);

  /// Serializes this HealthChecks to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthChecks&&(identical(other.database, database) || other.database == database)&&(identical(other.redis, redis) || other.redis == redis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,database,redis);

@override
String toString() {
  return 'HealthChecks(database: $database, redis: $redis)';
}


}

/// @nodoc
abstract mixin class $HealthChecksCopyWith<$Res>  {
  factory $HealthChecksCopyWith(HealthChecks value, $Res Function(HealthChecks) _then) = _$HealthChecksCopyWithImpl;
@useResult
$Res call({
 String database, String redis
});




}
/// @nodoc
class _$HealthChecksCopyWithImpl<$Res>
    implements $HealthChecksCopyWith<$Res> {
  _$HealthChecksCopyWithImpl(this._self, this._then);

  final HealthChecks _self;
  final $Res Function(HealthChecks) _then;

/// Create a copy of HealthChecks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? database = null,Object? redis = null,}) {
  return _then(_self.copyWith(
database: null == database ? _self.database : database // ignore: cast_nullable_to_non_nullable
as String,redis: null == redis ? _self.redis : redis // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthChecks].
extension HealthChecksPatterns on HealthChecks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthChecks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthChecks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthChecks value)  $default,){
final _that = this;
switch (_that) {
case _HealthChecks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthChecks value)?  $default,){
final _that = this;
switch (_that) {
case _HealthChecks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String database,  String redis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthChecks() when $default != null:
return $default(_that.database,_that.redis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String database,  String redis)  $default,) {final _that = this;
switch (_that) {
case _HealthChecks():
return $default(_that.database,_that.redis);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String database,  String redis)?  $default,) {final _that = this;
switch (_that) {
case _HealthChecks() when $default != null:
return $default(_that.database,_that.redis);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthChecks implements HealthChecks {
  const _HealthChecks({required this.database, required this.redis});
  factory _HealthChecks.fromJson(Map<String, dynamic> json) => _$HealthChecksFromJson(json);

@override final  String database;
@override final  String redis;

/// Create a copy of HealthChecks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthChecksCopyWith<_HealthChecks> get copyWith => __$HealthChecksCopyWithImpl<_HealthChecks>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthChecksToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthChecks&&(identical(other.database, database) || other.database == database)&&(identical(other.redis, redis) || other.redis == redis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,database,redis);

@override
String toString() {
  return 'HealthChecks(database: $database, redis: $redis)';
}


}

/// @nodoc
abstract mixin class _$HealthChecksCopyWith<$Res> implements $HealthChecksCopyWith<$Res> {
  factory _$HealthChecksCopyWith(_HealthChecks value, $Res Function(_HealthChecks) _then) = __$HealthChecksCopyWithImpl;
@override @useResult
$Res call({
 String database, String redis
});




}
/// @nodoc
class __$HealthChecksCopyWithImpl<$Res>
    implements _$HealthChecksCopyWith<$Res> {
  __$HealthChecksCopyWithImpl(this._self, this._then);

  final _HealthChecks _self;
  final $Res Function(_HealthChecks) _then;

/// Create a copy of HealthChecks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? database = null,Object? redis = null,}) {
  return _then(_HealthChecks(
database: null == database ? _self.database : database // ignore: cast_nullable_to_non_nullable
as String,redis: null == redis ? _self.redis : redis // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
