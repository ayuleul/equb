import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_model.freezed.dart';
part 'invite_model.g.dart';

@freezed
sealed class InviteModel with _$InviteModel {
  const factory InviteModel({
    required String code,
    String? joinUrl,
    DateTime? expiresAt,
    @JsonKey(fromJson: _toNullableInt) int? maxUses,
    @JsonKey(fromJson: _toNullableInt) int? usedCount,
  }) = _InviteModel;

  factory InviteModel.fromJson(Map<String, dynamic> json) =>
      _$InviteModelFromJson(json);
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
