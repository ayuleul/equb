import 'package:dio/dio.dart';

import '../../data/api/api_error.dart';

const groupLockedOpenCycleReasonCode = 'GROUP_LOCKED_OPEN_CYCLE';
const groupLockedOpenCycleFriendlyMessage =
    'A cycle is currently open. You can join after it closes.';
const groupRulesetRequiredReasonCode = 'GROUP_RULESET_REQUIRED';
const groupRulesetRequiredFriendlyMessage =
    'Complete group rules setup before continuing.';
const groupJoinRequestsBlockedReasonCode =
    'GROUP_JOIN_REQUESTS_BLOCKED_ACTIVE_CYCLE';
const groupJoinRequestsBlockedFriendlyMessage =
    'This group is currently in progress. New members can join after the round ends.';
const groupJoinRequestCooldownReasonCode = 'GROUP_JOIN_REQUEST_COOLDOWN';
const groupJoinRequestCooldownFriendlyMessage =
    'Your last join request was rejected. Please wait before trying again.';

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

bool isGroupLockedOpenCycleError(Object error) {
  final apiError = _normalizeApiError(error);
  if (apiError == null) {
    return false;
  }

  return _isGroupLockedError(apiError);
}

bool isGroupLockedActiveRoundError(Object error) {
  return isGroupLockedOpenCycleError(error);
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
    return groupLockedOpenCycleFriendlyMessage;
  }

  if (_isGroupRulesetRequiredError(error)) {
    return groupRulesetRequiredFriendlyMessage;
  }

  if (_isJoinRequestsBlockedError(error)) {
    return groupJoinRequestsBlockedFriendlyMessage;
  }

  if (_isJoinRequestCooldownError(error)) {
    return groupJoinRequestCooldownFriendlyMessage;
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

  if (normalized.contains(
    'only paid-submitted contributions can be verified',
  )) {
    return 'Only submitted payments can be verified.';
  }

  if (normalized.contains(
    'only paid-submitted contributions can be rejected',
  )) {
    return 'Only submitted payments can be rejected.';
  }

  if (normalized.contains('contribution marked late') ||
      normalized.contains('your contribution is late')) {
    return 'This contribution is marked late. Submit payment and request verification.';
  }

  if (normalized.contains('an open dispute already exists')) {
    return 'There is already an active dispute for this contribution.';
  }

  if (normalized.contains('strict payout check failed')) {
    return 'Cannot confirm payout yet. Some contributions are still unconfirmed. Review contributions first.';
  }

  if (normalized.contains('winner has already been selected for this cycle')) {
    return 'This turn already has a selected winner.';
  }

  if (normalized.contains('cycle must be ready_for_winner_selection')) {
    return 'Collection must finish before you can draw the winner.';
  }

  if (normalized.contains(
    'cycle must be ready_for_payout before payout send',
  )) {
    return 'Select the winner before marking payout as sent.';
  }

  if (normalized.contains(
    'only the selected winner can confirm payout receipt',
  )) {
    return 'Only the selected winner can confirm receipt.';
  }

  if (normalized.contains(
    'cycle must be payout_sent before receipt confirmation',
  )) {
    return 'The payout must be marked as sent before receipt can be confirmed.';
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
    'cycle can only be closed after payout receipt is confirmed',
  )) {
    return 'The winner must confirm receipt before the turn is completed.';
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
      error.reasonCode == groupLockedOpenCycleReasonCode) {
    return true;
  }

  final normalizedMessage = error.message.toLowerCase();
  return normalizedMessage.contains('group is locked while a cycle is open');
}

bool _isGroupRulesetRequiredError(ApiError error) {
  if (error.statusCode == 409 &&
      error.reasonCode == groupRulesetRequiredReasonCode) {
    return true;
  }

  final normalizedMessage = error.message.toLowerCase();
  return normalizedMessage.contains(
    'group rules must be configured before this action is allowed',
  );
}

bool _isJoinRequestsBlockedError(ApiError error) {
  if (error.statusCode == 409 &&
      error.reasonCode == groupJoinRequestsBlockedReasonCode) {
    return true;
  }

  return error.message.toLowerCase().contains(
    'this group is currently in progress. new members can join after the round ends.',
  );
}

bool _isJoinRequestCooldownError(ApiError error) {
  if (error.statusCode == 409 &&
      error.reasonCode == groupJoinRequestCooldownReasonCode) {
    return true;
  }

  return error.message.toLowerCase().contains(
    'wait before sending another join request',
  );
}
