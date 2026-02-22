import 'package:dio/dio.dart';

import '../../data/api/api_error.dart';

const groupLockedActiveRoundReasonCode = 'GROUP_LOCKED_ACTIVE_ROUND';
const groupLockedActiveRoundFriendlyMessage =
    'A round is currently in progress. You can join after it ends.';

String mapApiErrorToMessage(Object error) {
  if (error is ApiError) {
    return _mapApiError(error);
  }

  if (error is DioException) {
    final mapped = ApiError.fromDioException(error);
    return _mapApiError(mapped);
  }

  return 'Something went wrong. Please try again.';
}

bool isGroupLockedActiveRoundError(Object error) {
  final apiError = _normalizeApiError(error);
  if (apiError == null) {
    return false;
  }

  return _isGroupLockedError(apiError);
}

ApiError? _normalizeApiError(Object error) {
  if (error is ApiError) {
    return error;
  }

  if (error is DioException) {
    return ApiError.fromDioException(error);
  }

  return null;
}

String _mapApiError(ApiError error) {
  if (_isGroupLockedError(error)) {
    return groupLockedActiveRoundFriendlyMessage;
  }

  final message = error.message.trim();
  final normalized = message.toLowerCase();

  if (normalized.contains('invalid otp')) {
    return 'Invalid OTP code. Please try again.';
  }

  if (normalized.contains('otp expired') ||
      normalized.contains('expired otp')) {
    return 'OTP expired. Request a new code.';
  }

  if (normalized.contains('otp attempts exceeded')) {
    return 'Too many invalid OTP attempts. Request a new code.';
  }

  if (normalized.contains('otp not found')) {
    return 'No active OTP found. Request a new code.';
  }

  if (normalized.contains('too many')) {
    return 'Too many requests. Please wait and try again.';
  }

  if (normalized.contains('payout order is incomplete')) {
    return 'A round must be started before drawing a winner.';
  }

  if (normalized.contains('open cycle already exists')) {
    return 'A cycle is already open for this group.';
  }

  if (normalized.contains(
    'contributions can only be submitted for open cycles',
  )) {
    return 'This cycle is closed. Contributions are no longer accepted.';
  }

  if (normalized.contains(
    'only active group members can submit contributions',
  )) {
    return 'Only active group members can submit contributions.';
  }

  if (normalized.contains('prooffilekey does not match')) {
    return 'Uploaded proof is invalid for this cycle. Please retry upload.';
  }

  if (normalized.contains('confirmed contribution cannot be modified')) {
    return 'This contribution is already confirmed and cannot be changed.';
  }

  if (normalized.contains('only submitted contributions can be confirmed')) {
    return 'Only submitted contributions can be confirmed.';
  }

  if (normalized.contains('only submitted contributions can be rejected')) {
    return 'Only submitted contributions can be rejected.';
  }

  if (normalized.contains('strict payout check failed')) {
    return 'Cannot confirm payout yet. Some contributions are still unconfirmed. Review contributions first.';
  }

  if (normalized.contains('payout can only be created for open cycle')) {
    return 'Payout can only be created for an open cycle.';
  }

  if (normalized.contains('only pending payout can be confirmed')) {
    return 'Only pending payout can be confirmed.';
  }

  if (normalized.contains('cycle must be open to confirm payout')) {
    return 'Cycle must be open to confirm payout.';
  }

  if (normalized.contains(
    'cycle can only be closed after payout is confirmed',
  )) {
    return 'Confirm payout before closing this cycle.';
  }

  if (normalized.contains('cycle is already closed')) {
    return 'This cycle is already closed.';
  }

  switch (error.type) {
    case ApiErrorType.timeout:
      return 'Request timed out. Please retry.';
    case ApiErrorType.network:
      return 'Network error. Check your connection and try again.';
    case ApiErrorType.badRequest:
      return message.isNotEmpty ? message : 'Invalid request.';
    case ApiErrorType.unauthorized:
      return message.isNotEmpty ? message : 'Unauthorized request.';
    case ApiErrorType.forbidden:
      return 'You do not have access to this action.';
    case ApiErrorType.notFound:
      return 'Requested resource was not found.';
    case ApiErrorType.server:
      return 'Server error. Please try again shortly.';
    case ApiErrorType.sessionExpired:
      return 'Session expired. Please log in again.';
    case ApiErrorType.unknown:
      return message.isNotEmpty
          ? message
          : 'Unexpected error. Please try again.';
  }
}

bool _isGroupLockedError(ApiError error) {
  if (error.statusCode == 409 &&
      error.reasonCode == groupLockedActiveRoundReasonCode) {
    return true;
  }

  final normalizedMessage = error.message.toLowerCase();
  return normalizedMessage.contains(
    'group is locked while a round is in progress',
  );
}
