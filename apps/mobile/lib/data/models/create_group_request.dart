import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_model.dart';

part 'create_group_request.freezed.dart';
part 'create_group_request.g.dart';

@freezed
sealed class CreateGroupRequest with _$CreateGroupRequest {
  const factory CreateGroupRequest({
    required String name,
    int? contributionAmount,
    @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)
    GroupFrequencyModel? frequency,
    @JsonKey(toJson: _nullableDateToIsoString) DateTime? startDate,
    @Default('ETB') String currency,
  }) = _CreateGroupRequest;

  factory CreateGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGroupRequestFromJson(json);
}

String? _nullableDateToIsoString(DateTime? value) {
  return value?.toUtc().toIso8601String();
}
