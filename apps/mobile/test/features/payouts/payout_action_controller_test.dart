import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/data/api/api_error.dart';
import 'package:mobile/data/cycles/cycles_api.dart';
import 'package:mobile/data/cycles/cycles_repository.dart';
import 'package:mobile/data/files/files_api.dart';
import 'package:mobile/data/files/files_repository.dart';
import 'package:mobile/data/models/confirm_payout_request.dart';
import 'package:mobile/data/models/create_payout_request.dart';
import 'package:mobile/data/models/cycle_model.dart';
import 'package:mobile/data/models/payout_model.dart';
import 'package:mobile/data/payouts/payouts_api.dart';
import 'package:mobile/data/payouts/payouts_repository.dart';
import 'package:mobile/features/cycles/current_cycle_provider.dart';
import 'package:mobile/features/cycles/cycle_detail_provider.dart';
import 'package:mobile/features/cycles/cycles_list_provider.dart';
import 'package:mobile/features/payouts/cycle_payout_provider.dart';
import 'package:mobile/features/payouts/payout_action_controller.dart';

void main() {
  group('PayoutActionController', () {
    test(
      'confirmPayout invalidates payout/cycle providers on success',
      () async {
        final fakePayoutsRepository = _FakePayoutsRepository();
        final fakeCyclesRepository = _FakeCyclesRepository();
        final fakeFilesRepository = _FakeFilesRepository();

        final container = ProviderContainer(
          overrides: [
            payoutsRepositoryProvider.overrideWithValue(fakePayoutsRepository),
            cyclesRepositoryProvider.overrideWithValue(fakeCyclesRepository),
            filesRepositoryProvider.overrideWithValue(fakeFilesRepository),
          ],
        );
        addTearDown(container.dispose);

        final args = (groupId: 'group-1', cycleId: 'cycle-1');

        await container.read(cyclePayoutProvider(args.cycleId).future);
        await container.read(
          cycleDetailProvider((
            groupId: args.groupId,
            cycleId: args.cycleId,
          )).future,
        );
        await container.read(currentCycleProvider(args.groupId).future);
        await container.read(cyclesListProvider(args.groupId).future);

        expect(fakePayoutsRepository.getPayoutCalls, 1);
        expect(fakeCyclesRepository.getCycleCalls, 1);
        expect(fakeCyclesRepository.getCurrentCycleCalls, 1);
        expect(fakeCyclesRepository.listCyclesCalls, 1);

        final success = await container
            .read(payoutActionControllerProvider(args).notifier)
            .confirmPayout(payoutId: 'payout-1');

        expect(success, isTrue);

        await container.read(cyclePayoutProvider(args.cycleId).future);
        await container.read(
          cycleDetailProvider((
            groupId: args.groupId,
            cycleId: args.cycleId,
          )).future,
        );
        await container.read(currentCycleProvider(args.groupId).future);
        await container.read(cyclesListProvider(args.groupId).future);

        expect(fakePayoutsRepository.getPayoutCalls, 2);
        expect(fakeCyclesRepository.getCycleCalls, 2);
        expect(fakeCyclesRepository.getCurrentCycleCalls, 2);
        expect(fakeCyclesRepository.listCyclesCalls, 2);
      },
    );

    test('maps strict payout failure to guidance message', () async {
      final fakePayoutsRepository = _FakePayoutsRepository(
        strictModeFailure: true,
      );
      final container = ProviderContainer(
        overrides: [
          payoutsRepositoryProvider.overrideWithValue(fakePayoutsRepository),
          cyclesRepositoryProvider.overrideWithValue(_FakeCyclesRepository()),
          filesRepositoryProvider.overrideWithValue(_FakeFilesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final args = (groupId: 'group-1', cycleId: 'cycle-1');

      final success = await container
          .read(payoutActionControllerProvider(args).notifier)
          .confirmPayout(payoutId: 'payout-1');

      final state = container.read(payoutActionControllerProvider(args));

      expect(success, isFalse);
      expect(state.errorMessage, contains('Review contributions'));
    });
  });
}

class _FakePayoutsRepository extends PayoutsRepository {
  _FakePayoutsRepository({this.strictModeFailure = false})
    : super(_FakePayoutsApi());

  final bool strictModeFailure;

  int getPayoutCalls = 0;

  @override
  Future<PayoutModel?> getPayout(
    String cycleId, {
    bool forceRefresh = false,
  }) async {
    getPayoutCalls += 1;

    return const PayoutModel(
      id: 'payout-1',
      groupId: 'group-1',
      cycleId: 'cycle-1',
      toUserId: 'user-2',
      amount: 1000,
      status: PayoutStatusModel.pending,
      toUser: PayoutUserModel(id: 'user-2', fullName: 'Receiver'),
    );
  }

  @override
  Future<PayoutModel> confirmPayout(
    String payoutId,
    ConfirmPayoutRequest request,
  ) async {
    if (strictModeFailure) {
      throw const ApiError(
        type: ApiErrorType.badRequest,
        message:
            'Strict payout check failed. Missing confirmed contributions for 2 active member(s).',
      );
    }

    return const PayoutModel(
      id: 'payout-1',
      groupId: 'group-1',
      cycleId: 'cycle-1',
      toUserId: 'user-2',
      amount: 1000,
      status: PayoutStatusModel.confirmed,
      toUser: PayoutUserModel(id: 'user-2', fullName: 'Receiver'),
    );
  }
}

class _FakePayoutsApi implements PayoutsApi {
  @override
  Future<Map<String, dynamic>> closeCycle(String cycleId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> confirmPayout(
    String payoutId,
    ConfirmPayoutRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createPayout(
    String cycleId,
    CreatePayoutRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getPayout(String cycleId) {
    throw UnimplementedError();
  }
}

class _FakeCyclesRepository extends CyclesRepository {
  _FakeCyclesRepository() : super(_FakeCyclesApi());

  int getCurrentCycleCalls = 0;
  int listCyclesCalls = 0;
  int getCycleCalls = 0;

  @override
  Future<CycleModel?> getCurrentCycle(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    getCurrentCycleCalls += 1;
    return CycleModel(
      id: 'cycle-1',
      groupId: 'group-1',
      cycleNo: 1,
      dueDate: DateTime(2026, 3, 1),
      payoutUserId: 'user-2',
      status: CycleStatusModel.open,
    );
  }

  @override
  Future<List<CycleModel>> listCycles(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    listCyclesCalls += 1;
    return <CycleModel>[
      CycleModel(
        id: 'cycle-1',
        groupId: 'group-1',
        cycleNo: 1,
        dueDate: DateTime(2026, 3, 1),
        payoutUserId: 'user-2',
        status: CycleStatusModel.open,
      ),
    ];
  }

  @override
  Future<CycleModel> getCycle(
    String groupId,
    String cycleId, {
    bool forceRefresh = false,
  }) async {
    getCycleCalls += 1;
    return CycleModel(
      id: 'cycle-1',
      groupId: 'group-1',
      cycleNo: 1,
      dueDate: DateTime(2026, 3, 1),
      payoutUserId: 'user-2',
      status: CycleStatusModel.open,
    );
  }
}

class _FakeCyclesApi implements CyclesApi {
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
  Future<List<Map<String, dynamic>>> listCycles(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> setPayoutOrder(
    String groupId,
    List<Map<String, dynamic>> payload,
  ) {
    throw UnimplementedError();
  }
}

class _FakeFilesRepository extends FilesRepository {
  _FakeFilesRepository() : super(_FakeFilesApi());
}

class _FakeFilesApi implements FilesApi {
  @override
  Future<Map<String, dynamic>> createSignedDownload(String key) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createSignedUpload(request) {
    throw UnimplementedError();
  }
}
