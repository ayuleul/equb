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
    @JsonKey(fromJson: _toInt) required int cycleNo,
    required DateTime dueDate,
    required String payoutUserId,
    @JsonKey(unknownEnumValue: CycleStatusModel.unknown)
    required CycleStatusModel status,
    String? createdByUserId,
    DateTime? createdAt,
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
