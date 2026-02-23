import 'package:freezed_annotation/freezed_annotation.dart';

part 'cycle_model.freezed.dart';
part 'cycle_model.g.dart';

enum CycleStatusModel {
  @JsonValue('OPEN')
  open,
  @JsonValue('CLOSED')
  closed,
  unknown,
}

enum CycleStateModel {
  @JsonValue('DUE')
  due,
  @JsonValue('COLLECTING')
  collecting,
  @JsonValue('READY_FOR_PAYOUT')
  readyForPayout,
  @JsonValue('DISBURSED')
  disbursed,
  @JsonValue('CLOSED')
  closed,
  unknown,
}

enum AuctionStatusModel {
  @JsonValue('NONE')
  none,
  @JsonValue('OPEN')
  open,
  @JsonValue('CLOSED')
  closed,
  unknown,
}

@freezed
sealed class CyclePayoutUserModel with _$CyclePayoutUserModel {
  const factory CyclePayoutUserModel({
    required String id,
    String? phone,
    String? fullName,
  }) = _CyclePayoutUserModel;

  factory CyclePayoutUserModel.fromJson(Map<String, dynamic> json) =>
      _$CyclePayoutUserModelFromJson(json);
}

@freezed
sealed class CycleModel with _$CycleModel {
  const factory CycleModel({
    required String id,
    required String groupId,
    String? roundId,
    @JsonKey(fromJson: _toInt) required int cycleNo,
    required DateTime dueDate,
    DateTime? dueAt,
    @JsonKey(unknownEnumValue: CycleStateModel.unknown) CycleStateModel? state,
    String? scheduledPayoutUserId,
    String? finalPayoutUserId,
    required String payoutUserId,
    @JsonKey(unknownEnumValue: AuctionStatusModel.unknown)
    AuctionStatusModel? auctionStatus,
    @JsonKey(fromJson: _toNullableInt) int? winningBidAmount,
    String? winningBidUserId,
    @JsonKey(unknownEnumValue: CycleStatusModel.unknown)
    required CycleStatusModel status,
    String? createdByUserId,
    DateTime? createdAt,
    CyclePayoutUserModel? scheduledPayoutUser,
    CyclePayoutUserModel? finalPayoutUser,
    CyclePayoutUserModel? winningBidUser,
    CyclePayoutUserModel? payoutUser,
  }) = _CycleModel;

  factory CycleModel.fromJson(Map<String, dynamic> json) =>
      _$CycleModelFromJson(json);
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

int? _toNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}
