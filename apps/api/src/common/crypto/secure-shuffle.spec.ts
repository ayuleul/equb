import { seededShuffle } from './secure-shuffle';

describe('seededShuffle', () => {
  it('returns the same order for the same seed and input', () => {
    const members = ['u1', 'u2', 'u3', 'u4', 'u5', 'u6'];
    const seed = Buffer.from(
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      'hex',
    );

    const first = seededShuffle(members, seed);
    const second = seededShuffle(members, seed);

    expect(first).toEqual(second);
  });

  it('returns different order for different seeds', () => {
    const members = ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8'];
    const firstSeed = Buffer.from(
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      'hex',
    );
    const secondSeed = Buffer.from(
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      'hex',
    );

    const first = seededShuffle(members, firstSeed);
    const second = seededShuffle(members, secondSeed);

    expect(first).not.toEqual(second);
  });
});
