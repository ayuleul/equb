import {
  buildContributionProofPrefix,
  buildPayoutProofPrefix,
  isContributionProofKeyScopedTo,
  isPayoutProofKeyScopedTo,
  parseContributionProofKey,
  parseGroupScopedStorageKey,
  sanitizeFileName,
} from './proof-key.util';

describe('proof-key util', () => {
  it('validates scoped contribution proof key prefix', () => {
    const key = 'groups/group_1/cycles/cycle_1/users/user_1/uuid_receipt.pdf';

    expect(
      isContributionProofKeyScopedTo(key, 'group_1', 'cycle_1', 'user_1'),
    ).toBe(true);

    expect(
      isContributionProofKeyScopedTo(key, 'group_2', 'cycle_1', 'user_1'),
    ).toBe(false);
  });

  it('validates scoped payout proof key prefix', () => {
    const key = 'groups/group_1/cycles/cycle_1/payouts/uuid_receipt.pdf';

    expect(isPayoutProofKeyScopedTo(key, 'group_1', 'cycle_1')).toBe(true);
    expect(isPayoutProofKeyScopedTo(key, 'group_2', 'cycle_1')).toBe(false);
  });

  it('parses key scope and sanitizes filenames', () => {
    const contributionKey =
      'groups/group_1/cycles/cycle_1/users/user_1/uuid_receipt.pdf';
    const payoutKey = 'groups/group_1/cycles/cycle_1/payouts/uuid_receipt.pdf';

    expect(parseContributionProofKey(contributionKey)).toEqual({
      groupId: 'group_1',
      cycleId: 'cycle_1',
      userId: 'user_1',
    });

    expect(parseGroupScopedStorageKey(contributionKey)).toEqual({
      groupId: 'group_1',
      cycleId: 'cycle_1',
      userId: 'user_1',
      scope: 'contribution',
    });

    expect(parseGroupScopedStorageKey(payoutKey)).toEqual({
      groupId: 'group_1',
      cycleId: 'cycle_1',
      scope: 'payout',
    });

    expect(buildContributionProofPrefix('g', 'c', 'u')).toBe(
      'groups/g/cycles/c/users/u/',
    );

    expect(buildPayoutProofPrefix('g', 'c')).toBe('groups/g/cycles/c/payouts/');

    expect(sanitizeFileName(' receipt #1 .pdf ')).toBe('receipt__1_.pdf');
  });
});
