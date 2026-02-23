import 'package:freezed_annotation/freezed_annotation.dart';

part 'contribution_dispute_model.freezed.dart';
part 'contribution_dispute_model.g.dart';

enum ContributionDisputeStatusModel {
  @JsonValue('OPEN')
  open,
  @JsonValue('MEDIATING')
  mediating,
  @JsonValue('RESOLVED')
  resolved,
  unknown,
}

@freezed
sealed class ContributionDisputeModel with _$ContributionDisputeModel {
  const factory ContributionDisputeModel({
    required String id,
    required String groupId,
    required String cycleId,
    required String contributionId,
    required String reportedByUserId,
    @JsonKey(unknownEnumValue: ContributionDisputeStatusModel.unknown)
    required ContributionDisputeStatusModel status,
    required String reason,
    String? note,
    String? mediationNote,
    DateTime? mediatedAt,
    String? mediatedByUserId,
    String? resolutionOutcome,
    String? resolutionNote,
    DateTime? resolvedAt,
    String? resolvedByUserId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ContributionDisputeModel;

  factory ContributionDisputeModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionDisputeModelFromJson(json);
}
