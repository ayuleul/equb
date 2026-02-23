import 'package:freezed_annotation/freezed_annotation.dart';

part 'cycle_collection_evaluation_model.freezed.dart';
part 'cycle_collection_evaluation_model.g.dart';

@freezed
sealed class CycleCollectionEvaluationModel
    with _$CycleCollectionEvaluationModel {
  const factory CycleCollectionEvaluationModel({
    required String cycleId,
    required DateTime dueAt,
    required int graceDays,
    required DateTime graceDeadline,
    required DateTime evaluatedAt,
    required bool strictCollection,
    required bool allVerified,
    required bool readyForPayout,
    @JsonKey(fromJson: _toInt) required int overdueCount,
    @JsonKey(fromJson: _toInt) required int lateMarkedCount,
    @JsonKey(fromJson: _toInt) required int fineLedgerEntriesCreated,
    @JsonKey(fromJson: _toInt) required int notifiedMembersCount,
    @JsonKey(fromJson: _toInt) required int notifiedGuarantorsCount,
  }) = _CycleCollectionEvaluationModel;

  factory CycleCollectionEvaluationModel.fromJson(Map<String, dynamic> json) =>
      _$CycleCollectionEvaluationModelFromJson(json);
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
