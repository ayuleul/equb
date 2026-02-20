// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContributionUserModel _$ContributionUserModelFromJson(
  Map<String, dynamic> json,
) => _ContributionUserModel(
  id: json['id'] as String,
  fullName: json['fullName'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$ContributionUserModelToJson(
  _ContributionUserModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'phone': instance.phone,
};

_ContributionModel _$ContributionModelFromJson(Map<String, dynamic> json) =>
    _ContributionModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      cycleId: json['cycleId'] as String,
      userId: json['userId'] as String,
      amount: _toInt(json['amount']),
      status: $enumDecode(
        _$ContributionStatusModelEnumMap,
        json['status'],
        unknownValue: ContributionStatusModel.unknown,
      ),
      proofFileKey: json['proofFileKey'] as String?,
      paymentRef: json['paymentRef'] as String?,
      note: json['note'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      rejectedAt: json['rejectedAt'] == null
          ? null
          : DateTime.parse(json['rejectedAt'] as String),
      rejectReason: json['rejectReason'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      user: ContributionUserModel.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ContributionModelToJson(_ContributionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'cycleId': instance.cycleId,
      'userId': instance.userId,
      'amount': instance.amount,
      'status': _$ContributionStatusModelEnumMap[instance.status]!,
      'proofFileKey': instance.proofFileKey,
      'paymentRef': instance.paymentRef,
      'note': instance.note,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'rejectReason': instance.rejectReason,
      'createdAt': instance.createdAt?.toIso8601String(),
      'user': instance.user,
    };

const _$ContributionStatusModelEnumMap = {
  ContributionStatusModel.pending: 'PENDING',
  ContributionStatusModel.submitted: 'SUBMITTED',
  ContributionStatusModel.confirmed: 'CONFIRMED',
  ContributionStatusModel.rejected: 'REJECTED',
  ContributionStatusModel.unknown: 'unknown',
};

_ContributionSummaryModel _$ContributionSummaryModelFromJson(
  Map<String, dynamic> json,
) => _ContributionSummaryModel(
  total: json['total'] == null ? 0 : _toInt(json['total']),
  pending: json['pending'] == null ? 0 : _toInt(json['pending']),
  submitted: json['submitted'] == null ? 0 : _toInt(json['submitted']),
  confirmed: json['confirmed'] == null ? 0 : _toInt(json['confirmed']),
  rejected: json['rejected'] == null ? 0 : _toInt(json['rejected']),
);

Map<String, dynamic> _$ContributionSummaryModelToJson(
  _ContributionSummaryModel instance,
) => <String, dynamic>{
  'total': instance.total,
  'pending': instance.pending,
  'submitted': instance.submitted,
  'confirmed': instance.confirmed,
  'rejected': instance.rejected,
};

_ContributionListModel _$ContributionListModelFromJson(
  Map<String, dynamic> json,
) => _ContributionListModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ContributionModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ContributionModel>[],
  summary: ContributionSummaryModel.fromJson(
    json['summary'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ContributionListModelToJson(
  _ContributionListModel instance,
) => <String, dynamic>{'items': instance.items, 'summary': instance.summary};
