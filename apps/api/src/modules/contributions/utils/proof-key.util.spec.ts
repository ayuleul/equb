import {
  buildContributionProofPrefix,
  isContributionProofKeyScopedTo,
  parseContributionProofKey,
  sanitizeFileName,
} from './proof-key.util';

describe('proof-key util', () => {
  it('validates scoped proof key prefix', () => {
    const key = 'groups/group_1/cycles/cycle_1/users/user_1/uuid_receipt.pdf';

    expect(
      isContributionProofKeyScopedTo(key, 'group_1', 'cycle_1', 'user_1'),
    ).toBe(true);

    expect(
      isContributionProofKeyScopedTo(key, 'group_2', 'cycle_1', 'user_1'),
    ).toBe(false);
  });

  it('parses key scope and sanitizes filenames', () => {
    const key = 'groups/group_1/cycles/cycle_1/users/user_1/uuid_receipt.pdf';

    expect(parseContributionProofKey(key)).toEqual({
      groupId: 'group_1',
      cycleId: 'cycle_1',
      userId: 'user_1',
    });

    expect(buildContributionProofPrefix('g', 'c', 'u')).toBe(
      'groups/g/cycles/c/users/u/',
    );

    expect(sanitizeFileName(' receipt #1 .pdf ')).toBe('receipt__1_.pdf');
  });
});
