import { MemberStatus } from '@prisma/client';

export const PARTICIPATING_MEMBER_STATUSES: MemberStatus[] = [
  MemberStatus.JOINED,
  MemberStatus.VERIFIED,
  MemberStatus.ACTIVE, // legacy compatibility
];

export const VERIFIED_MEMBER_STATUSES: MemberStatus[] = [
  MemberStatus.VERIFIED,
  MemberStatus.ACTIVE, // legacy compatibility
];

export const SUSPENDED_MEMBER_STATUSES: MemberStatus[] = [
  MemberStatus.SUSPENDED,
  MemberStatus.REMOVED, // legacy compatibility
];

export function isParticipatingMemberStatus(
  status: MemberStatus | null | undefined,
): boolean {
  if (!status) {
    return false;
  }

  return PARTICIPATING_MEMBER_STATUSES.includes(status);
}

export function isVerifiedMemberStatus(
  status: MemberStatus | null | undefined,
): boolean {
  if (!status) {
    return false;
  }

  return VERIFIED_MEMBER_STATUSES.includes(status);
}

export function isSuspendedMemberStatus(
  status: MemberStatus | null | undefined,
): boolean {
  if (!status) {
    return false;
  }

  return SUSPENDED_MEMBER_STATUSES.includes(status);
}

export function normalizeMemberStatus(status: MemberStatus): MemberStatus {
  if (status === MemberStatus.ACTIVE) {
    return MemberStatus.VERIFIED;
  }

  if (status === MemberStatus.LEFT || status === MemberStatus.REMOVED) {
    return MemberStatus.SUSPENDED;
  }

  return status;
}
