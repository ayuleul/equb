import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_model.dart';

part 'member_model.freezed.dart';
part 'member_model.g.dart';

@freezed
sealed class MemberUserModel with _$MemberUserModel {
  const factory MemberUserModel({
    required String id,
    String? phone,
    String? fullName,
  }) = _MemberUserModel;

  factory MemberUserModel.fromJson(Map<String, dynamic> json) =>
      _$MemberUserModelFromJson(json);
}

@freezed
sealed class MemberModel with _$MemberModel {
  const MemberModel._();

  const factory MemberModel({
    @JsonKey(readValue: _readUserId) required String userId,
    String? groupId,
    required MemberUserModel user,
    @JsonKey(unknownEnumValue: MemberRoleModel.unknown)
    required MemberRoleModel role,
    @JsonKey(unknownEnumValue: MemberStatusModel.unknown)
    required MemberStatusModel status,
    @JsonKey(fromJson: _toNullableInt) int? payoutPosition,
    DateTime? joinedAt,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  String get displayName {
    final fullName = user.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    final phone = user.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return 'Member';
  }
}

Object? _readUserId(Map<dynamic, dynamic> json, String key) {
  final nested = json['user'];
  if (nested is Map && nested['id'] is String) {
    return nested['id'];
  }

  return json[key];
}

int? _toNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }

  return null;
}
