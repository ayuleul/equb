import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/group_model.dart';
import 'package:mobile/data/models/member_model.dart';
import 'package:mobile/features/cycles/payout_order_controller.dart';

void main() {
  test('buildPayoutOrderItems assigns contiguous 1..N positions', () {
    final members = <MemberModel>[
      MemberModel(
        userId: 'user-3',
        user: const MemberUserModel(id: 'user-3', fullName: 'C'),
        role: MemberRoleModel.member,
        status: MemberStatusModel.active,
      ),
      MemberModel(
        userId: 'user-1',
        user: const MemberUserModel(id: 'user-1', fullName: 'A'),
        role: MemberRoleModel.admin,
        status: MemberStatusModel.active,
      ),
      MemberModel(
        userId: 'user-2',
        user: const MemberUserModel(id: 'user-2', fullName: 'B'),
        role: MemberRoleModel.member,
        status: MemberStatusModel.active,
      ),
    ];

    final payload = buildPayoutOrderItems(members);

    expect(payload, hasLength(3));
    expect(payload[0].userId, 'user-3');
    expect(payload[0].payoutPosition, 1);
    expect(payload[1].userId, 'user-1');
    expect(payload[1].payoutPosition, 2);
    expect(payload[2].userId, 'user-2');
    expect(payload[2].payoutPosition, 3);
  });
}
