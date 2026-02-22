import { createHash, createHmac, randomBytes, randomInt } from 'crypto';

const UINT32_SPACE = 0x1_0000_0000;
const MAX_UINT64 = (1n << 64n) - 1n;

export type CounterRef = {
  value: bigint;
};

export function createSecureSeed(length = 32): Buffer {
  if (!Number.isInteger(length) || length <= 0) {
    throw new RangeError('Seed length must be a positive integer');
  }

  return randomBytes(length);
}

export function sha256Hex(input: Buffer | Uint8Array): string {
  return createHash('sha256').update(input).digest('hex');
}

export function secureShuffle<T>(arr: T[]): T[] {
  const shuffled = [...arr];

  for (let index = shuffled.length - 1; index > 0; index -= 1) {
    const swapIndex = randomInt(index + 1);
    [shuffled[index], shuffled[swapIndex]] = [
      shuffled[swapIndex],
      shuffled[index],
    ];
  }

  return shuffled;
}

export function randBelow(
  seed: Buffer,
  counterRef: CounterRef,
  maxExclusive: number,
): number {
  if (!Number.isInteger(maxExclusive) || maxExclusive <= 0) {
    throw new RangeError('maxExclusive must be a positive integer');
  }

  if (maxExclusive > UINT32_SPACE) {
    throw new RangeError('maxExclusive must be <= 2^32');
  }

  const unbiasedBound = Math.floor(UINT32_SPACE / maxExclusive) * maxExclusive;

  while (true) {
    if (counterRef.value > MAX_UINT64) {
      throw new RangeError(
        'Counter overflow while deriving deterministic random',
      );
    }

    const counterBuffer = Buffer.allocUnsafe(8);
    counterBuffer.writeBigUInt64BE(counterRef.value);
    counterRef.value += 1n;

    const digest = createHmac('sha256', seed).update(counterBuffer).digest();

    for (let offset = 0; offset <= digest.length - 4; offset += 4) {
      const candidate = digest.readUInt32BE(offset);
      if (candidate < unbiasedBound) {
        return candidate % maxExclusive;
      }
    }
  }
}

export function seededShuffle<T>(arr: T[], seed: Buffer): T[] {
  const shuffled = [...arr];
  const counterRef: CounterRef = { value: 0n };

  for (let index = shuffled.length - 1; index > 0; index -= 1) {
    const swapIndex = randBelow(seed, counterRef, index + 1);
    [shuffled[index], shuffled[swapIndex]] = [
      shuffled[swapIndex],
      shuffled[index],
    ];
  }

  return shuffled;
}
