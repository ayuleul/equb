import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/data/contributions/contributions_api.dart';
import 'package:mobile/data/contributions/contributions_repository.dart';
import 'package:mobile/data/files/files_api.dart';
import 'package:mobile/data/files/files_repository.dart';
import 'package:mobile/data/models/contribution_model.dart';
import 'package:mobile/data/models/group_rules_model.dart';
import 'package:mobile/data/models/signed_upload_request.dart';
import 'package:mobile/data/models/signed_upload_response.dart';
import 'package:mobile/data/models/submit_contribution_request.dart';
import 'package:mobile/features/contributions/submit_contribution_controller.dart';

void main() {
  test(
    'SubmitContributionController happy path uploads and submits proof',
    () async {
      final fakeContributionsRepository = _FakeContributionsRepository();
      final fakeFilesRepository = _FakeFilesRepository();
      final fakePicker = _FakeContributionImagePicker(
        image: PickedContributionImage(
          fileName: 'proof.jpg',
          contentType: 'image/jpeg',
          bytes: Uint8List.fromList(<int>[10, 20, 30]),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          contributionsRepositoryProvider.overrideWithValue(
            fakeContributionsRepository,
          ),
          filesRepositoryProvider.overrideWithValue(fakeFilesRepository),
          contributionImagePickerProvider.overrideWithValue(fakePicker),
        ],
      );
      addTearDown(container.dispose);

      final args = (groupId: 'group-1', cycleId: 'cycle-1');
      final notifier = container.read(
        submitContributionControllerProvider(args).notifier,
      );

      await notifier.pickFromGallery();
      final success = await notifier.submit(
        method: GroupPaymentMethodModel.bank,
        amount: 500,
        paymentRef: 'TX-1',
        note: 'Paid today',
      );

      final state = container.read(submitContributionControllerProvider(args));

      expect(success, isTrue);
      expect(fakeFilesRepository.uploadCalled, isTrue);
      expect(
        fakeFilesRepository.requestedPurpose,
        UploadPurposeModel.contributionProof,
      );
      expect(
        fakeContributionsRepository.submittedRequest?.proofFileKey,
        'key-1',
      );
      expect(fakeContributionsRepository.submittedRequest?.amount, 500);
      expect(state.step, SubmitContributionStep.success);
    },
  );
}

class _FakeContributionsRepository extends ContributionsRepository {
  _FakeContributionsRepository() : super(_FakeContributionsApi());

  SubmitContributionRequest? submittedRequest;

  @override
  Future<ContributionModel> submitContribution(
    String cycleId,
    SubmitContributionRequest request,
  ) async {
    submittedRequest = request;

    return ContributionModel(
      id: 'contribution-1',
      groupId: 'group-1',
      cycleId: cycleId,
      userId: 'user-1',
      amount: request.amount ?? 0,
      status: ContributionStatusModel.submitted,
      proofFileKey: request.proofFileKey,
      paymentRef: request.paymentRef,
      note: request.note,
      user: const ContributionUserModel(id: 'user-1', fullName: 'Tester'),
    );
  }
}

class _FakeContributionsApi implements ContributionsApi {
  @override
  Future<Map<String, dynamic>> confirmContribution(
    String contributionId, {
    String? note,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> verifyContribution(
    String contributionId, {
    String? note,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> listCycleContributions(
    String groupId,
    String cycleId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rejectContribution(
    String contributionId,
    request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> submitContribution(
    String cycleId,
    SubmitContributionRequest request,
  ) {
    throw UnimplementedError();
  }
}

class _FakeFilesRepository extends FilesRepository {
  _FakeFilesRepository() : super(_FakeFilesApi());

  bool uploadCalled = false;
  UploadPurposeModel? requestedPurpose;

  @override
  Future<SignedUploadResponse> requestSignedUpload({
    required UploadPurposeModel purpose,
    required String groupId,
    required String cycleId,
    required String fileName,
    required String contentType,
  }) async {
    requestedPurpose = purpose;
    return const SignedUploadResponse(
      key: 'key-1',
      uploadUrl: 'https://upload.test/key-1',
      expiresInSeconds: 900,
    );
  }

  @override
  Future<void> uploadToSignedUrl(
    String uploadUrl,
    Uint8List bytes,
    String contentType, {
    void Function(double progress)? onProgress,
  }) async {
    uploadCalled = true;
    onProgress?.call(1);
  }
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

class _FakeContributionImagePicker implements ContributionImagePicker {
  _FakeContributionImagePicker({required this.image});

  final PickedContributionImage image;

  @override
  Future<PickedContributionImage?> pickFromCamera() async {
    return image;
  }

  @override
  Future<PickedContributionImage?> pickFromGallery() async {
    return image;
  }
}
