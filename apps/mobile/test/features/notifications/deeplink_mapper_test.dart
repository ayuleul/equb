import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/features/notifications/deeplink_mapper.dart';

void main() {
  group('mapNotificationPayloadToLocation', () {
    test('maps groupId only to group detail route', () {
      final location = mapNotificationPayloadToLocation(<String, dynamic>{
        'groupId': 'group-1',
      });

      expect(location, AppRoutePaths.groupDetail('group-1'));
    });

    test('maps groupId + cycleId to cycle detail route', () {
      final location = mapNotificationPayloadToLocation(<String, dynamic>{
        'groupId': 'group-1',
        'cycleId': 'cycle-1',
      });

      expect(location, AppRoutePaths.groupCycleDetail('group-1', 'cycle-1'));
    });

    test('maps lottery announcement payload to cycle detail route', () {
      final location = mapNotificationPayloadToLocation(<String, dynamic>{
        'type': 'LOTTERY_ANNOUNCEMENT',
        'groupId': 'group-1',
        'cycleId': 'cycle-1',
      });

      expect(location, AppRoutePaths.groupCycleDetail('group-1', 'cycle-1'));
    });

    test('maps groupId + cycleId + contributionId to contributions route', () {
      final location = mapNotificationPayloadToLocation(<String, dynamic>{
        'groupId': 'group-1',
        'cycleId': 'cycle-1',
        'contributionId': 'contrib-1',
      });

      expect(
        location,
        AppRoutePaths.groupCycleContributions('group-1', 'cycle-1'),
      );
    });

    test('prefers explicit route when provided', () {
      final location = mapNotificationPayloadToLocation(<String, dynamic>{
        'route': '/groups/group-9/cycles/cycle-9',
        'groupId': 'group-1',
        'cycleId': 'cycle-1',
      });

      expect(location, '/groups/group-9/cycles/cycle-9');
    });
  });
}
