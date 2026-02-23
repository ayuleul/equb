import 'group_model.dart';

bool isParticipatingMemberStatus(MemberStatusModel status) {
  return status == MemberStatusModel.joined ||
      status == MemberStatusModel.verified ||
      status == MemberStatusModel.active;
}

bool isVerifiedMemberStatus(MemberStatusModel status) {
  return status == MemberStatusModel.verified ||
      status == MemberStatusModel.active;
}

String memberStatusLabel(MemberStatusModel status) {
  return switch (status) {
    MemberStatusModel.invited => 'INVITED',
    MemberStatusModel.joined => 'JOINED',
    MemberStatusModel.verified => 'VERIFIED',
    MemberStatusModel.suspended => 'SUSPENDED',
    MemberStatusModel.active => 'ACTIVE',
    MemberStatusModel.left => 'LEFT',
    MemberStatusModel.removed => 'REMOVED',
    MemberStatusModel.unknown => 'UNKNOWN',
  };
}
