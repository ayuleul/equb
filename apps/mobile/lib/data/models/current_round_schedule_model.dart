import '../../features/rounds/models/member_summary.dart';

class CurrentRoundScheduleModel {
  const CurrentRoundScheduleModel({
    required this.roundId,
    required this.roundNo,
    required this.drawSeedHash,
    required this.schedule,
  });

  final String roundId;
  final int roundNo;
  final String drawSeedHash;
  final List<RoundScheduleEntryModel> schedule;

  List<MemberSummary> get finalOrder {
    return schedule
        .map(
          (entry) => MemberSummary(
            userId: entry.userId,
            displayName: entry.displayName,
          ),
        )
        .toList(growable: false);
  }

  factory CurrentRoundScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawSchedule = (json['schedule'] as List?) ?? const <Object?>[];
    final schedule =
        rawSchedule
            .whereType<Object?>()
            .map((item) {
              if (item is Map<String, dynamic>) {
                return RoundScheduleEntryModel.fromJson(item);
              }
              if (item is Map) {
                return RoundScheduleEntryModel.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }
              return const RoundScheduleEntryModel(
                position: 0,
                userId: '',
                displayName: 'Member',
              );
            })
            .where((entry) => entry.userId.isNotEmpty)
            .toList(growable: false)
          ..sort((a, b) => a.position.compareTo(b.position));

    return CurrentRoundScheduleModel(
      roundId: (json['roundId'] as String?) ?? '',
      roundNo: _toInt(json['roundNo']),
      drawSeedHash: (json['drawSeedHash'] as String?) ?? '',
      schedule: schedule,
    );
  }
}

class RoundScheduleEntryModel {
  const RoundScheduleEntryModel({
    required this.position,
    required this.userId,
    required this.displayName,
  });

  final int position;
  final String userId;
  final String displayName;

  factory RoundScheduleEntryModel.fromJson(Map<String, dynamic> json) {
    final userId = (json['userId'] as String?) ?? '';
    final displayName = (json['displayName'] as String?)?.trim();

    return RoundScheduleEntryModel(
      position: _toInt(json['position']),
      userId: userId,
      displayName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : userId,
    );
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
