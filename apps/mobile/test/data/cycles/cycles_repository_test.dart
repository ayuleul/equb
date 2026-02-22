import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/cycles/cycles_api.dart';
import 'package:mobile/data/cycles/cycles_repository.dart';
import 'package:mobile/data/models/payout_order_item.dart';

void main() {
  group('CyclesRepository', () {
    test('listCycles maps API payload to typed CycleModel list', () async {
      final repository = CyclesRepository(
        _FakeCyclesApi(
          listCyclesPayload: <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'cycle-1',
              'groupId': 'group-1',
              'cycleNo': 1,
              'dueDate': '2026-03-20T00:00:00.000Z',
              'payoutUserId': 'user-1',
              'status': 'OPEN',
              'createdByUserId': 'admin-1',
              'createdAt': '2026-02-20T00:00:00.000Z',
              'payoutUser': <String, dynamic>{
                'id': 'user-1',
                'phone': '+251911223344',
                'fullName': 'Abebe',
              },
            },
          ],
        ),
      );

      final cycles = await repository.listCycles('group-1');

      expect(cycles, hasLength(1));
      expect(cycles.first.id, 'cycle-1');
      expect(cycles.first.groupId, 'group-1');
      expect(cycles.first.cycleNo, 1);
      expect(cycles.first.payoutUserId, 'user-1');
      expect(cycles.first.status.name, 'open');
    });

    test(
      'setPayoutOrder builds contiguous payload and forwards to api',
      () async {
        final api = _FakeCyclesApi();
        final repository = CyclesRepository(api);

        await repository.setPayoutOrder('group-1', const <PayoutOrderItem>[
          PayoutOrderItem(userId: 'user-2', payoutPosition: 1),
          PayoutOrderItem(userId: 'user-1', payoutPosition: 2),
        ]);

        expect(api.lastGroupId, 'group-1');
        expect(api.lastSetPayoutOrderPayload, <Map<String, dynamic>>[
          <String, dynamic>{'userId': 'user-2', 'payoutPosition': 1},
          <String, dynamic>{'userId': 'user-1', 'payoutPosition': 2},
        ]);
      },
    );
  });
}

class _FakeCyclesApi implements CyclesApi {
  _FakeCyclesApi({this.listCyclesPayload = const <Map<String, dynamic>>[]});

  final List<Map<String, dynamic>> listCyclesPayload;

  String? lastGroupId;
  List<Map<String, dynamic>>? lastSetPayoutOrderPayload;

  @override
  Future<Map<String, dynamic>> startRound(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> generateCycles(
    String groupId,
    Map<String, dynamic> payload,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getCycle(String groupId, String cycleId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getCurrentCycle(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> listCycles(String groupId) async {
    return listCyclesPayload;
  }

  @override
  Future<List<Map<String, dynamic>>> setPayoutOrder(
    String groupId,
    List<Map<String, dynamic>> payload,
  ) async {
    lastGroupId = groupId;
    lastSetPayoutOrderPayload = payload;

    return <Map<String, dynamic>>[
      <String, dynamic>{
        'user': <String, dynamic>{
          'id': 'user-2',
          'phone': '+251900000001',
          'fullName': 'User Two',
        },
        'role': 'MEMBER',
        'status': 'ACTIVE',
        'payoutPosition': 1,
      },
      <String, dynamic>{
        'user': <String, dynamic>{
          'id': 'user-1',
          'phone': '+251900000002',
          'fullName': 'User One',
        },
        'role': 'ADMIN',
        'status': 'ACTIVE',
        'payoutPosition': 2,
      },
    ];
  }
}
