import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../app/bootstrap.dart';
import '../../data/contributions/contributions_repository.dart';
import '../../data/files/files_repository.dart';
import '../../data/models/group_rules_model.dart';
import '../../data/models/signed_upload_request.dart';
import '../../data/models/submit_contribution_request.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../../shared/utils/upload_error_mapper.dart';
import '../cycles/cycle_detail_provider.dart';
import 'cycle_contributions_provider.dart';

final contributionImagePickerProvider = Provider<ContributionImagePicker>((
  ref,
) {
  return DeviceContributionImagePicker();
});

final submitContributionControllerProvider =
    StateNotifierProvider.family<
      SubmitContributionController,
      SubmitContributionState,
      CycleContributionsArgs
    >((ref, args) {
      final contributionsRepository = ref.watch(
        contributionsRepositoryProvider,
      );
      final filesRepository = ref.watch(filesRepositoryProvider);
      final imagePicker = ref.watch(contributionImagePickerProvider);

      return SubmitContributionController(
        ref: ref,
        args: args,
        contributionsRepository: contributionsRepository,
        filesRepository: filesRepository,
        imagePicker: imagePicker,
      );
    });

enum SubmitContributionStep {
  idle,
  pickingImage,
  requestingUpload,
  uploading,
  submitting,
  success,
  error,
}

class PickedContributionImage {
  const PickedContributionImage({
    required this.fileName,
    required this.contentType,
    required this.bytes,
  });

  final String fileName;
  final String contentType;
  final Uint8List bytes;
}

class SubmitContributionState {
  const SubmitContributionState({
    required this.step,
    this.image,
    this.uploadProgress,
    this.errorMessage,
  });

  const SubmitContributionState.initial()
    : this(step: SubmitContributionStep.idle);

  final SubmitContributionStep step;
  final PickedContributionImage? image;
  final double? uploadProgress;
  final String? errorMessage;

  bool get isBusy {
    return step == SubmitContributionStep.pickingImage ||
        step == SubmitContributionStep.requestingUpload ||
        step == SubmitContributionStep.uploading ||
        step == SubmitContributionStep.submitting;
  }

  SubmitContributionState copyWith({
    SubmitContributionStep? step,
    PickedContributionImage? image,
    bool clearImage = false,
    double? uploadProgress,
    bool clearProgress = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubmitContributionState(
      step: step ?? this.step,
      image: clearImage ? null : (image ?? this.image),
      uploadProgress: clearProgress
          ? null
          : (uploadProgress ?? this.uploadProgress),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

abstract class ContributionImagePicker {
  Future<PickedContributionImage?> pickFromCamera();
  Future<PickedContributionImage?> pickFromGallery();
}

class DeviceContributionImagePicker implements ContributionImagePicker {
  DeviceContributionImagePicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedContributionImage?> pickFromCamera() {
    return _pick(ImageSource.camera);
  }

  @override
  Future<PickedContributionImage?> pickFromGallery() {
    return _pick(ImageSource.gallery);
  }

  Future<PickedContributionImage?> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final inferredType =
        lookupMimeType(
          file.name,
          headerBytes: bytes.take(12).toList(growable: false),
        ) ??
        lookupMimeType(file.path) ??
        'image/jpeg';

    return PickedContributionImage(
      fileName: file.name,
      contentType: inferredType,
      bytes: bytes,
    );
  }
}

class SubmitContributionController
    extends StateNotifier<SubmitContributionState> {
  SubmitContributionController({
    required Ref ref,
    required this.args,
    required ContributionsRepository contributionsRepository,
    required FilesRepository filesRepository,
    required ContributionImagePicker imagePicker,
  }) : _ref = ref,
       _contributionsRepository = contributionsRepository,
       _filesRepository = filesRepository,
       _imagePicker = imagePicker,
       super(const SubmitContributionState.initial());

  final Ref _ref;
  final CycleContributionsArgs args;
  final ContributionsRepository _contributionsRepository;
  final FilesRepository _filesRepository;
  final ContributionImagePicker _imagePicker;

  Future<void> pickFromCamera() => _pick(() => _imagePicker.pickFromCamera());

  Future<void> pickFromGallery() => _pick(() => _imagePicker.pickFromGallery());

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> submit({
    required GroupPaymentMethodModel method,
    required int amount,
    String? paymentRef,
    String? note,
  }) async {
    final image = state.image;
    if (image == null) {
      state = state.copyWith(
        step: SubmitContributionStep.error,
        errorMessage: 'Please attach a receipt image before submitting.',
      );
      return false;
    }

    final normalizedPaymentRef = paymentRef?.trim();
    final normalizedNote = note?.trim();

    state = state.copyWith(
      step: SubmitContributionStep.requestingUpload,
      clearError: true,
      clearProgress: true,
    );

    try {
      final signedUpload = await _filesRepository.requestSignedUpload(
        purpose: UploadPurposeModel.contributionProof,
        groupId: args.groupId,
        cycleId: args.cycleId,
        fileName: image.fileName,
        contentType: image.contentType,
      );

      state = state.copyWith(
        step: SubmitContributionStep.uploading,
        uploadProgress: 0,
      );

      await _filesRepository.uploadToSignedUrl(
        signedUpload.uploadUrl,
        image.bytes,
        image.contentType,
        onProgress: (progress) {
          state = state.copyWith(
            step: SubmitContributionStep.uploading,
            uploadProgress: progress.clamp(0, 1),
          );
        },
      );

      state = state.copyWith(
        step: SubmitContributionStep.submitting,
        uploadProgress: 1,
      );

      await _contributionsRepository.submitContribution(
        args.cycleId,
        SubmitContributionRequest(
          method: method,
          amount: amount,
          receiptFileKey: signedUpload.key,
          reference:
              (normalizedPaymentRef == null || normalizedPaymentRef.isEmpty)
              ? null
              : normalizedPaymentRef,
          proofFileKey: signedUpload.key,
          paymentRef:
              (normalizedPaymentRef == null || normalizedPaymentRef.isEmpty)
              ? null
              : normalizedPaymentRef,
          note: (normalizedNote == null || normalizedNote.isEmpty)
              ? null
              : normalizedNote,
        ),
      );

      _ref.invalidate(cycleContributionsProvider(args));
      _ref.invalidate(
        cycleDetailProvider((groupId: args.groupId, cycleId: args.cycleId)),
      );

      state = state.copyWith(
        step: SubmitContributionStep.success,
        uploadProgress: 1,
        clearError: true,
      );
      return true;
    } catch (error) {
      final message = switch (error) {
        DioException _ => mapUploadErrorToMessage(error),
        _ => mapApiErrorToMessage(error),
      };

      state = state.copyWith(
        step: SubmitContributionStep.error,
        errorMessage: message,
      );
      return false;
    }
  }

  Future<void> _pick(Future<PickedContributionImage?> Function() picker) async {
    state = state.copyWith(
      step: SubmitContributionStep.pickingImage,
      clearError: true,
      clearProgress: true,
    );

    try {
      final image = await picker();
      state = state.copyWith(
        step: SubmitContributionStep.idle,
        image: image,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        step: SubmitContributionStep.error,
        errorMessage: mapUploadErrorToMessage(error),
      );
    }
  }
}
