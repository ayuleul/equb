// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reputation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AllowedPublicEqubLimitsModel _$AllowedPublicEqubLimitsModelFromJson(
  Map<String, dynamic> json,
) => _AllowedPublicEqubLimitsModel(
  maxMembers: (json['maxMembers'] as num?)?.toInt(),
  maxContributionAmount: _toNullableInt(json['maxContributionAmount']),
  maxDurationDays: (json['maxDurationDays'] as num?)?.toInt(),
  maxActivePublicEqubs: (json['maxActivePublicEqubs'] as num?)?.toInt(),
);

Map<String, dynamic> _$AllowedPublicEqubLimitsModelToJson(
  _AllowedPublicEqubLimitsModel instance,
) => <String, dynamic>{
  'maxMembers': instance.maxMembers,
  'maxContributionAmount': instance.maxContributionAmount,
  'maxDurationDays': instance.maxDurationDays,
  'maxActivePublicEqubs': instance.maxActivePublicEqubs,
};

_ReputationBadgeModel _$ReputationBadgeModelFromJson(
  Map<String, dynamic> json,
) => _ReputationBadgeModel(
  code: json['code'] as String,
  label: json['label'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$ReputationBadgeModelToJson(
  _ReputationBadgeModel instance,
) => <String, dynamic>{
  'code': instance.code,
  'label': instance.label,
  'description': instance.description,
};

_ReputationComponentsModel _$ReputationComponentsModelFromJson(
  Map<String, dynamic> json,
) => _ReputationComponentsModel(
  payment: _toInt(json['payment']),
  completion: _toInt(json['completion']),
  behavior: _toInt(json['behavior']),
  experience: _toInt(json['experience']),
);

Map<String, dynamic> _$ReputationComponentsModelToJson(
  _ReputationComponentsModel instance,
) => <String, dynamic>{
  'payment': instance.payment,
  'completion': instance.completion,
  'behavior': instance.behavior,
  'experience': instance.experience,
};

_MemberReputationSummaryModel _$MemberReputationSummaryModelFromJson(
  Map<String, dynamic> json,
) => _MemberReputationSummaryModel(
  userId: json['userId'] as String,
  trustScore: _toInt(json['trustScore']),
  trustLevel: json['trustLevel'] as String,
  summaryLabel: json['summaryLabel'] as String,
  equbsCompleted: json['equbsCompleted'] == null
      ? 0
      : _toInt(json['equbsCompleted']),
  equbsHosted: json['equbsHosted'] == null ? 0 : _toInt(json['equbsHosted']),
  onTimePaymentRate: (json['onTimePaymentRate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MemberReputationSummaryModelToJson(
  _MemberReputationSummaryModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'trustScore': instance.trustScore,
  'trustLevel': instance.trustLevel,
  'summaryLabel': instance.summaryLabel,
  'equbsCompleted': instance.equbsCompleted,
  'equbsHosted': instance.equbsHosted,
  'onTimePaymentRate': instance.onTimePaymentRate,
};

_HostReputationSummaryModel _$HostReputationSummaryModelFromJson(
  Map<String, dynamic> json,
) => _HostReputationSummaryModel(
  userId: json['userId'] as String,
  trustScore: _toInt(json['trustScore']),
  trustLevel: json['trustLevel'] as String,
  summaryLabel: json['summaryLabel'] as String,
  equbsHosted: _toInt(json['equbsHosted']),
  hostedEqubsCompleted: _toInt(json['hostedEqubsCompleted']),
  turnsParticipated: _toInt(json['turnsParticipated']),
  hostedCompletionRate: (json['hostedCompletionRate'] as num?)?.toDouble(),
  cancelledGroupsCount: _toInt(json['cancelledGroupsCount']),
  hostDisputesCount: _toInt(json['hostDisputesCount']),
);

Map<String, dynamic> _$HostReputationSummaryModelToJson(
  _HostReputationSummaryModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'trustScore': instance.trustScore,
  'trustLevel': instance.trustLevel,
  'summaryLabel': instance.summaryLabel,
  'equbsHosted': instance.equbsHosted,
  'hostedEqubsCompleted': instance.hostedEqubsCompleted,
  'turnsParticipated': instance.turnsParticipated,
  'hostedCompletionRate': instance.hostedCompletionRate,
  'cancelledGroupsCount': instance.cancelledGroupsCount,
  'hostDisputesCount': instance.hostDisputesCount,
};

_GroupTrustSummaryModel _$GroupTrustSummaryModelFromJson(
  Map<String, dynamic> json,
) => _GroupTrustSummaryModel(
  groupId: json['groupId'] as String,
  hostScore: _toInt(json['hostScore']),
  averageMemberScore: (json['averageMemberScore'] as num?)?.toDouble(),
  verifiedMembersPercent: (json['verifiedMembersPercent'] as num?)?.toDouble(),
  groupTrustLevel: json['groupTrustLevel'] as String,
  host: HostReputationSummaryModel.fromJson(
    json['host'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GroupTrustSummaryModelToJson(
  _GroupTrustSummaryModel instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'hostScore': instance.hostScore,
  'averageMemberScore': instance.averageMemberScore,
  'verifiedMembersPercent': instance.verifiedMembersPercent,
  'groupTrustLevel': instance.groupTrustLevel,
  'host': instance.host,
};

_ReputationEligibilityModel _$ReputationEligibilityModelFromJson(
  Map<String, dynamic> json,
) => _ReputationEligibilityModel(
  canHostPublicGroup: json['canHostPublicGroup'] as bool,
  canJoinHighValuePublicGroup: json['canJoinHighValuePublicGroup'] as bool,
  canAccessLending: json['canAccessLending'] as bool,
  canAccessMarketplace: json['canAccessMarketplace'] as bool,
  hostTier: json['hostTier'] as String?,
  hostReputationLevel: json['hostReputationLevel'] as String,
  allowedPublicEqubLimits: AllowedPublicEqubLimitsModel.fromJson(
    json['allowedPublicEqubLimits'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ReputationEligibilityModelToJson(
  _ReputationEligibilityModel instance,
) => <String, dynamic>{
  'canHostPublicGroup': instance.canHostPublicGroup,
  'canJoinHighValuePublicGroup': instance.canJoinHighValuePublicGroup,
  'canAccessLending': instance.canAccessLending,
  'canAccessMarketplace': instance.canAccessMarketplace,
  'hostTier': instance.hostTier,
  'hostReputationLevel': instance.hostReputationLevel,
  'allowedPublicEqubLimits': instance.allowedPublicEqubLimits,
};

_ReputationHistoryEntryModel _$ReputationHistoryEntryModelFromJson(
  Map<String, dynamic> json,
) => _ReputationHistoryEntryModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  eventType: json['eventType'] as String,
  scoreDelta: _toInt(json['scoreDelta']),
  metricChanges:
      (json['metricChanges'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  relatedGroupId: json['relatedGroupId'] as String?,
  relatedCycleId: json['relatedCycleId'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReputationHistoryEntryModelToJson(
  _ReputationHistoryEntryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'eventType': instance.eventType,
  'scoreDelta': instance.scoreDelta,
  'metricChanges': instance.metricChanges,
  'relatedGroupId': instance.relatedGroupId,
  'relatedCycleId': instance.relatedCycleId,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
};

_ReputationHistoryPageModel _$ReputationHistoryPageModelFromJson(
  Map<String, dynamic> json,
) => _ReputationHistoryPageModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) =>
                ReputationHistoryEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ReputationHistoryEntryModel>[],
  page: (json['page'] as num?)?.toInt() ?? 1,
  limit: (json['limit'] as num?)?.toInt() ?? 10,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReputationHistoryPageModelToJson(
  _ReputationHistoryPageModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
};

_ReputationProfileModel _$ReputationProfileModelFromJson(
  Map<String, dynamic> json,
) => _ReputationProfileModel(
  userId: json['userId'] as String,
  trustScore: _toInt(json['trustScore']),
  trustLevel: json['trustLevel'] as String,
  summaryLabel: json['summaryLabel'] as String,
  equbsJoined: _toInt(json['equbsJoined']),
  equbsCompleted: _toInt(json['equbsCompleted']),
  equbsLeftEarly: json['equbsLeftEarly'] == null
      ? 0
      : _toInt(json['equbsLeftEarly']),
  equbsHosted: _toInt(json['equbsHosted']),
  hostedEqubsCompleted: _toInt(json['hostedEqubsCompleted']),
  onTimePayments: _toInt(json['onTimePayments']),
  latePayments: _toInt(json['latePayments']),
  missedPayments: _toInt(json['missedPayments']),
  turnsParticipated: json['turnsParticipated'] == null
      ? 0
      : _toInt(json['turnsParticipated']),
  payoutsReceived: _toInt(json['payoutsReceived']),
  payoutsConfirmed: _toInt(json['payoutsConfirmed']),
  removalsCount: _toInt(json['removalsCount']),
  disputesCount: _toInt(json['disputesCount']),
  cancelledGroupsCount: json['cancelledGroupsCount'] == null
      ? 0
      : _toInt(json['cancelledGroupsCount']),
  hostDisputesCount: json['hostDisputesCount'] == null
      ? 0
      : _toInt(json['hostDisputesCount']),
  components: ReputationComponentsModel.fromJson(
    json['components'] as Map<String, dynamic>,
  ),
  baseScore: (json['baseScore'] as num?)?.toDouble(),
  activityFactor: (json['activityFactor'] as num?)?.toDouble(),
  adjustedScore: (json['adjustedScore'] as num?)?.toDouble(),
  confidenceFactor: (json['confidenceFactor'] as num?)?.toDouble(),
  lastEqubActivityAt: json['lastEqubActivityAt'] == null
      ? null
      : DateTime.parse(json['lastEqubActivityAt'] as String),
  onTimePaymentRate: (json['onTimePaymentRate'] as num?)?.toDouble(),
  hostedCompletionRate: (json['hostedCompletionRate'] as num?)?.toDouble(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  eligibility: ReputationEligibilityModel.fromJson(
    json['eligibility'] as Map<String, dynamic>,
  ),
  badges:
      (json['badges'] as List<dynamic>?)
          ?.map((e) => ReputationBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ReputationBadgeModel>[],
);

Map<String, dynamic> _$ReputationProfileModelToJson(
  _ReputationProfileModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'trustScore': instance.trustScore,
  'trustLevel': instance.trustLevel,
  'summaryLabel': instance.summaryLabel,
  'equbsJoined': instance.equbsJoined,
  'equbsCompleted': instance.equbsCompleted,
  'equbsLeftEarly': instance.equbsLeftEarly,
  'equbsHosted': instance.equbsHosted,
  'hostedEqubsCompleted': instance.hostedEqubsCompleted,
  'onTimePayments': instance.onTimePayments,
  'latePayments': instance.latePayments,
  'missedPayments': instance.missedPayments,
  'turnsParticipated': instance.turnsParticipated,
  'payoutsReceived': instance.payoutsReceived,
  'payoutsConfirmed': instance.payoutsConfirmed,
  'removalsCount': instance.removalsCount,
  'disputesCount': instance.disputesCount,
  'cancelledGroupsCount': instance.cancelledGroupsCount,
  'hostDisputesCount': instance.hostDisputesCount,
  'components': instance.components,
  'baseScore': instance.baseScore,
  'activityFactor': instance.activityFactor,
  'adjustedScore': instance.adjustedScore,
  'confidenceFactor': instance.confidenceFactor,
  'lastEqubActivityAt': instance.lastEqubActivityAt?.toIso8601String(),
  'onTimePaymentRate': instance.onTimePaymentRate,
  'hostedCompletionRate': instance.hostedCompletionRate,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'eligibility': instance.eligibility,
  'badges': instance.badges,
};
