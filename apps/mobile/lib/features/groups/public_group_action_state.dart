import '../../data/models/join_request_model.dart';
import '../../data/models/public_group_model.dart';

class PublicGroupActionState {
  const PublicGroupActionState({
    required this.label,
    required this.buttonLabel,
    required this.canSubmit,
    this.message,
  });

  final String label;
  final String buttonLabel;
  final bool canSubmit;
  final String? message;
}

PublicGroupActionState resolvePublicGroupActionState(
  PublicGroupModel group,
  JoinRequestModel? joinRequest,
) {
  if (group.isCurrentUserMember ?? false) {
    return const PublicGroupActionState(
      label: 'Approved',
      buttonLabel: 'Approved',
      canSubmit: false,
      message: 'You are already a member of this group.',
    );
  }

  final now = DateTime.now();
  final retryAvailableAt = joinRequest?.retryAvailableAt;
  final isCooldownActive =
      retryAvailableAt != null && now.isBefore(retryAvailableAt);

  return switch (joinRequest?.status ?? JoinRequestStatusModel.unknown) {
    JoinRequestStatusModel.requested => const PublicGroupActionState(
      label: 'Request sent',
      buttonLabel: 'Request sent',
      canSubmit: false,
      message: 'Admins are reviewing your request.',
    ),
    JoinRequestStatusModel.approved => const PublicGroupActionState(
      label: 'Approved',
      buttonLabel: 'Approved',
      canSubmit: false,
    ),
    JoinRequestStatusModel.rejected => PublicGroupActionState(
      label: 'Rejected',
      buttonLabel: isCooldownActive
          ? 'Try again later'
          : 'Request to join again',
      canSubmit: !isCooldownActive,
      message: isCooldownActive
          ? 'This request was rejected by the group admins. You can try again after ${formatJoinRequestRetryDate(retryAvailableAt)}.'
          : 'This request was rejected by the group admins. You can submit a new request now.',
    ),
    JoinRequestStatusModel.withdrawn => const PublicGroupActionState(
      label: 'Withdrawn',
      buttonLabel: 'Request to join',
      canSubmit: true,
    ),
    JoinRequestStatusModel.unknown => const PublicGroupActionState(
      label: 'Open',
      buttonLabel: 'Request to join',
      canSubmit: true,
      message: 'Joining still requires admin approval.',
    ),
  };
}

String formatJoinRequestRetryDate(DateTime value) {
  final month = switch (value.month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    12 => 'Dec',
    _ => '',
  };

  return '$month ${value.day}, ${value.year}';
}
