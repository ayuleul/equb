import { MemberStatus } from '@prisma/client';

import {
  isParticipatingMemberStatus,
  isSuspendedMemberStatus,
  isVerifiedMemberStatus,
  normalizeMemberStatus,
} from './member-status.util';

describe('member-status util', () => {
  it('treats joined/verified and legacy active as participating', () => {
    expect(isParticipatingMemberStatus(MemberStatus.JOINED)).toBe(true);
    expect(isParticipatingMemberStatus(MemberStatus.VERIFIED)).toBe(true);
    expect(isParticipatingMemberStatus(MemberStatus.ACTIVE)).toBe(true);
    expect(isParticipatingMemberStatus(MemberStatus.INVITED)).toBe(false);
  });

  it('treats verified and legacy active as verified', () => {
    expect(isVerifiedMemberStatus(MemberStatus.VERIFIED)).toBe(true);
    expect(isVerifiedMemberStatus(MemberStatus.ACTIVE)).toBe(true);
    expect(isVerifiedMemberStatus(MemberStatus.JOINED)).toBe(false);
  });

  it('treats suspended and legacy removed as suspended', () => {
    expect(isSuspendedMemberStatus(MemberStatus.SUSPENDED)).toBe(true);
    expect(isSuspendedMemberStatus(MemberStatus.REMOVED)).toBe(true);
    expect(isSuspendedMemberStatus(MemberStatus.LEFT)).toBe(false);
  });

  it('normalizes legacy statuses to canonical ones', () => {
    expect(normalizeMemberStatus(MemberStatus.ACTIVE)).toBe(
      MemberStatus.VERIFIED,
    );
    expect(normalizeMemberStatus(MemberStatus.LEFT)).toBe(
      MemberStatus.SUSPENDED,
    );
    expect(normalizeMemberStatus(MemberStatus.REMOVED)).toBe(
      MemberStatus.SUSPENDED,
    );
  });
});
