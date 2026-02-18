import { calculateStrictPayoutEligibility } from './strict-payout.util';

describe('strict payout eligibility', () => {
  it('returns eligible=true when all active members are confirmed', () => {
    const result = calculateStrictPayoutEligibility(
      ['u1', 'u2'],
      ['u1', 'u2', 'u3'],
    );

    expect(result.eligible).toBe(true);
    expect(result.missingMemberIds).toEqual([]);
  });

  it('returns missing users when confirmations are incomplete', () => {
    const result = calculateStrictPayoutEligibility(['u1', 'u2', 'u3'], ['u1']);

    expect(result.eligible).toBe(false);
    expect(result.missingMemberIds).toEqual(['u2', 'u3']);
  });
});
