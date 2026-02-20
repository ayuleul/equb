import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../app/bootstrap.dart';
import '../../data/cycles/cycles_repository.dart';
import '../../data/files/files_repository.dart';
import '../../data/payouts/payouts_repository.dart';
import '../../data/models/confirm_payout_request.dart';
import '../../data/models/create_payout_request.dart';
import '../../data/models/signed_upload_request.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../../shared/utils/upload_error_mapper.dart';
import '../cycles/current_cycle_provider.dart';
import '../cycles/cycle_detail_provider.dart';
import '../cycles/cycles_list_provider.dart';
import 'cycle_payout_provider.dart';

typedef PayoutActionArgs = ({String groupId, String cycleId});

final payoutProofImagePickerProvider = Provider<PayoutProofImagePicker>((ref) {
  return DevicePayoutProofImagePicker();
});

final payoutActionControllerProvider =
    StateNotifierProvider.family<
      PayoutActionController,
      PayoutActionState,
      PayoutActionArgs
    >((ref, args) {
      final payoutsRepository = ref.watch(payoutsRepositoryProvider);
      final filesRepository = ref.watch(filesRepositoryProvider);
      final cyclesRepository = ref.watch(cyclesRepositoryProvider);
      final imagePicker = ref.watch(payoutProofImagePickerProvider);

      return PayoutActionController(
        ref: ref,
        args: args,
        payoutsRepository: payoutsRepository,
        filesRepository: filesRepository,
        cyclesRepository: cyclesRepository,
        imagePicker: imagePicker,
      );
    });

enum PayoutActionType {
  none,
  pickingProof,
  creating,
  uploadingProof,
  confirming,
  closing,
}

class PickedPayoutProofImage {
  const PickedPayoutProofImage({
    required this.fileName,
    required this.contentType,
    required this.bytes,
  });

  final String fileName;
  final String contentType;
  final Uint8List bytes;
}

class PayoutActionState {
  const PayoutActionState({
    required this.isLoading,
    required this.actionType,
    this.errorMessage,
    this.uploadProgress,
    this.proofImage,
  });

  const PayoutActionState.initial()
    : this(isLoading: false, actionType: PayoutActionType.none);

  final bool isLoading;
  final PayoutActionType actionType;
  final String? errorMessage;
  final double? uploadProgress;
  final PickedPayoutProofImage? proofImage;

  bool get hasProof => proofImage != null;

  PayoutActionState copyWith({
    bool? isLoading,
    PayoutActionType? actionType,
    String? errorMessage,
    bool clearError = false,
    double? uploadProgress,
    bool clearProgress = false,
    PickedPayoutProofImage? proofImage,
    bool clearProof = false,
  }) {
    return PayoutActionState(
      isLoading: isLoading ?? this.isLoading,
      actionType: actionType ?? this.actionType,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      uploadProgress: clearProgress
          ? null
          : (uploadProgress ?? this.uploadProgress),
      proofImage: clearProof ? null : (proofImage ?? this.proofImage),
    );
  }
}

abstract class PayoutProofImagePicker {
  Future<PickedPayoutProofImage?> pickFromCamera();
  Future<PickedPayoutProofImage?> pickFromGallery();
}

class DevicePayoutProofImagePicker implements PayoutProofImagePicker {
  DevicePayoutProofImagePicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPayoutProofImage?> pickFromCamera() {
    return _pick(ImageSource.camera);
  }

  @override
  Future<PickedPayoutProofImage?> pickFromGallery() {
    return _pick(ImageSource.gallery);
  }

  Future<PickedPayoutProofImage?> _pick(ImageSource source) async {
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

    return PickedPayoutProofImage(
      fileName: file.name,
      contentType: inferredType,
      bytes: bytes,
    );
  }
}

class PayoutActionController extends StateNotifier<PayoutActionState> {
  PayoutActionController({
    required Ref ref,
    required this.args,
    required PayoutsRepository payoutsRepository,
    required FilesRepository filesRepository,
    required CyclesRepository cyclesRepository,
    required PayoutProofImagePicker imagePicker,
  }) : _ref = ref,
       _payoutsRepository = payoutsRepository,
       _filesRepository = filesRepository,
       _cyclesRepository = cyclesRepository,
       _imagePicker = imagePicker,
       super(const PayoutActionState.initial());

  final Ref _ref;
  final PayoutActionArgs args;
  final PayoutsRepository _payoutsRepository;
  final FilesRepository _filesRepository;
  final CyclesRepository _cyclesRepository;
  final PayoutProofImagePicker _imagePicker;

  Future<void> pickProofFromCamera() {
    return _pickProof(() => _imagePicker.pickFromCamera());
  }

  Future<void> pickProofFromGallery() {
    return _pickProof(() => _imagePicker.pickFromGallery());
  }

  void clearProof() {
    state = state.copyWith(
      clearProof: true,
      clearProgress: true,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> createPayout({
    int? amount,
    String? paymentRef,
    String? note,
  }) async {
    state = state.copyWith(
      isLoading: true,
      actionType: PayoutActionType.creating,
      clearError: true,
      clearProgress: true,
    );

    try {
      await _payoutsRepository.createPayout(
        args.cycleId,
        CreatePayoutRequest(
          amount: amount,
          paymentRef: _normalizeOptional(paymentRef),
          note: _normalizeOptional(note),
        ),
      );

      _invalidateAfterMutation();

      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<bool> confirmPayout({
    required String payoutId,
    String? paymentRef,
    String? note,
  }) async {
    state = state.copyWith(
      isLoading: true,
      actionType: PayoutActionType.confirming,
      clearError: true,
    );

    try {
      String? proofFileKey;
      final proof = state.proofImage;
      if (proof != null) {
        state = state.copyWith(
          actionType: PayoutActionType.uploadingProof,
          uploadProgress: 0,
        );

        final signedUpload = await _filesRepository.requestSignedUpload(
          purpose: UploadPurposeModel.payoutProof,
          groupId: args.groupId,
          cycleId: args.cycleId,
          fileName: proof.fileName,
          contentType: proof.contentType,
        );

        await _filesRepository.uploadToSignedUrl(
          signedUpload.uploadUrl,
          proof.bytes,
          proof.contentType,
          onProgress: (progress) {
            state = state.copyWith(
              actionType: PayoutActionType.uploadingProof,
              uploadProgress: progress.clamp(0, 1),
            );
          },
        );

        proofFileKey = signedUpload.key;
      }

      state = state.copyWith(
        actionType: PayoutActionType.confirming,
        uploadProgress: 1,
      );

      await _payoutsRepository.confirmPayout(
        payoutId,
        ConfirmPayoutRequest(
          proofFileKey: proofFileKey,
          paymentRef: _normalizeOptional(paymentRef),
          note: _normalizeOptional(note),
        ),
      );

      _invalidateAfterMutation();

      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        clearError: true,
        clearProgress: true,
      );
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        errorMessage: mapUploadErrorToMessage(error),
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<bool> closeCycle() async {
    state = state.copyWith(
      isLoading: true,
      actionType: PayoutActionType.closing,
      clearError: true,
      clearProgress: true,
    );

    try {
      final success = await _payoutsRepository.closeCycle(args.cycleId);
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          actionType: PayoutActionType.none,
          errorMessage: 'Could not close cycle. Please try again.',
        );
        return false;
      }

      _invalidateAfterMutation();

      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        errorMessage: mapApiErrorToMessage(error),
      );
      return false;
    }
  }

  Future<void> _pickProof(
    Future<PickedPayoutProofImage?> Function() picker,
  ) async {
    state = state.copyWith(
      isLoading: true,
      actionType: PayoutActionType.pickingProof,
      clearError: true,
      clearProgress: true,
    );

    try {
      final image = await picker();
      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        proofImage: image,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        actionType: PayoutActionType.none,
        errorMessage: mapUploadErrorToMessage(error),
      );
    }
  }

  String? _normalizeOptional(String? input) {
    final value = input?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  void _invalidateAfterMutation() {
    _payoutsRepository.invalidatePayout(args.cycleId);
    _cyclesRepository.invalidateCycleDetail(args.groupId, args.cycleId);
    _cyclesRepository.invalidateGroupCache(args.groupId);

    _ref.invalidate(cyclePayoutProvider(args.cycleId));
    _ref.invalidate(
      cycleDetailProvider((groupId: args.groupId, cycleId: args.cycleId)),
    );
    _ref.invalidate(currentCycleProvider(args.groupId));
    _ref.invalidate(cyclesListProvider(args.groupId));
  }
}
