import 'package:freezed_annotation/freezed_annotation.dart';

part 'payout_model.freezed.dart';
part 'payout_model.g.dart';

enum PayoutStatusModel {
  @JsonValue('PENDING')
  pending,
  @JsonValue('CONFIRMED')
  confirmed,
  unknown,
}

@freezed
sealed class PayoutUserModel with _$PayoutUserModel {
  const factory PayoutUserModel({
    required String id,
    String? fullName,
    String? phone,
  }) = _PayoutUserModel;

  factory PayoutUserModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutUserModelFromJson(json);
}

@freezed
sealed class PayoutModel with _$PayoutModel {
  const PayoutModel._();

  const factory PayoutModel({
    required String id,
    required String groupId,
    required String cycleId,
    required String toUserId,
    @JsonKey(fromJson: _toInt) required int amount,
    @JsonKey(unknownEnumValue: PayoutStatusModel.unknown)
    required PayoutStatusModel status,
    String? proofFileKey,
    String? paymentRef,
    String? note,
    String? createdByUserId,
    DateTime? createdAt,
    String? confirmedByUserId,
    DateTime? confirmedAt,
    required PayoutUserModel toUser,
  }) = _PayoutModel;

  factory PayoutModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutModelFromJson(json);

  String get recipientLabel {
    final fullName = toUser.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    final phone = toUser.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return toUserId;
  }
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
