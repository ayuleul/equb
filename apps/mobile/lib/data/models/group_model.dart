import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

enum GroupFrequencyModel {
  @JsonValue('WEEKLY')
  weekly,
  @JsonValue('MONTHLY')
  monthly,
  unknown,
}

enum GroupStatusModel {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('ARCHIVED')
  archived,
  unknown,
}

enum MemberRoleModel {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MEMBER')
  member,
  unknown,
}

enum MemberStatusModel {
  @JsonValue('INVITED')
  invited,
  @JsonValue('JOINED')
  joined,
  @JsonValue('VERIFIED')
  verified,
  @JsonValue('SUSPENDED')
  suspended,
  // legacy values kept temporarily for compatibility
  @JsonValue('ACTIVE')
  active,
  @JsonValue('LEFT')
  left,
  @JsonValue('REMOVED')
  removed,
  unknown,
}

@freezed
sealed class GroupMembershipModel with _$GroupMembershipModel {
  const factory GroupMembershipModel({
    @JsonKey(unknownEnumValue: MemberRoleModel.unknown)
    required MemberRoleModel role,
    @JsonKey(unknownEnumValue: MemberStatusModel.unknown)
    required MemberStatusModel status,
  }) = _GroupMembershipModel;

  factory GroupMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$GroupMembershipModelFromJson(json);
}

@freezed
sealed class GroupModel with _$GroupModel {
  const factory GroupModel({
    required String id,
    required String name,
    required String currency,
    @JsonKey(fromJson: _toInt) required int contributionAmount,
    @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)
    required GroupFrequencyModel frequency,
    required DateTime startDate,
    @JsonKey(unknownEnumValue: GroupStatusModel.unknown)
    required GroupStatusModel status,
    String? createdByUserId,
    DateTime? createdAt,
    bool? strictPayout,
    String? timezone,
    GroupMembershipModel? membership,
    @Default(false) bool rulesetConfigured,
    @Default(false) bool canInviteMembers,
    @Default(false) bool canStartCycle,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }

  return 0;
}
