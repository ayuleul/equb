import '../../app/router.dart';

String? mapNotificationPayloadToLocation(Map<String, dynamic> payload) {
  final route = _readString(payload, 'route');
  if (route != null) {
    return route;
  }

  final groupId = _readString(payload, 'groupId');
  final cycleId = _readString(payload, 'cycleId');
  final contributionId = _readString(payload, 'contributionId');
  final type = _readString(payload, 'type')?.toUpperCase();

  if (groupId != null && cycleId != null) {
    final isContributionType = type != null && type.startsWith('CONTRIBUTION_');
    if (isContributionType || contributionId != null) {
      return AppRoutePaths.groupCycleContributions(groupId, cycleId);
    }

    return AppRoutePaths.groupCycleDetail(groupId, cycleId);
  }

  if (groupId != null) {
    return AppRoutePaths.groupDetail(groupId);
  }

  return null;
}

String? _readString(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value is! String) {
    return null;
  }

  final normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }

  return normalized;
}
