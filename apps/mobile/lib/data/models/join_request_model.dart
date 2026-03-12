import 'package:freezed_annotation/freezed_annotation.dart';

part 'join_request_model.freezed.dart';
part 'join_request_model.g.dart';

enum JoinRequestStatusModel {
  @JsonValue('REQUESTED')
  requested,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('WITHDRAWN')
  withdrawn,
  unknown,
}

@freezed
sealed class JoinRequestUserModel with _$JoinRequestUserModel {
  const factory JoinRequestUserModel({
    required String id,
    String? phone,
    String? fullName,
  }) = _JoinRequestUserModel;

  factory JoinRequestUserModel.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestUserModelFromJson(json);
}

@freezed
sealed class JoinRequestModel with _$JoinRequestModel {
  const JoinRequestModel._();

  const factory JoinRequestModel({
    required String id,
    required String groupId,
    required String userId,
    @JsonKey(unknownEnumValue: JoinRequestStatusModel.unknown)
    required JoinRequestStatusModel status,
    String? message,
    required DateTime createdAt,
    DateTime? reviewedAt,
    String? reviewedByUserId,
    DateTime? retryAvailableAt,
    JoinRequestUserModel? user,
  }) = _JoinRequestModel;

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestModelFromJson(json);

  String get requesterName {
    final fullName = user?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    final phone = user?.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return 'Member';
  }
}
