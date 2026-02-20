import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_model.dart';

part 'create_group_request.freezed.dart';
part 'create_group_request.g.dart';

@freezed
sealed class CreateGroupRequest with _$CreateGroupRequest {
  const factory CreateGroupRequest({
    required String name,
    required int contributionAmount,
    @JsonKey(unknownEnumValue: GroupFrequencyModel.unknown)
    required GroupFrequencyModel frequency,
    @JsonKey(toJson: _dateToIsoString) required DateTime startDate,
    @Default('ETB') String currency,
  }) = _CreateGroupRequest;

  factory CreateGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGroupRequestFromJson(json);
}

String _dateToIsoString(DateTime value) => value.toUtc().toIso8601String();
