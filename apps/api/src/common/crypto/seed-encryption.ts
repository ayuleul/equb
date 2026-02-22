import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

const IV_LENGTH = 12;
const TAG_LENGTH = 16;

export function parseDrawSeedEncryptionKey(rawValue: string): Buffer {
  const trimmed = rawValue.trim();

  if (!trimmed) {
    throw new Error('DRAW_SEED_ENC_KEY is empty');
  }

  if (/^[0-9a-fA-F]{64}$/.test(trimmed)) {
    return Buffer.from(trimmed, 'hex');
  }

  const decoded = Buffer.from(trimmed, 'base64');
  if (decoded.length !== 32) {
    throw new Error(
      'DRAW_SEED_ENC_KEY must be a 64-char hex string or base64 that decodes to 32 bytes',
    );
  }

  return decoded;
}

export function encryptSeed(seed: Buffer, key: Buffer): string {
  const iv = randomBytes(IV_LENGTH);
  const cipher = createCipheriv('aes-256-gcm', key, iv);
  const ciphertext = Buffer.concat([cipher.update(seed), cipher.final()]);
  const tag = cipher.getAuthTag();

  return [
    iv.toString('base64'),
    ciphertext.toString('base64'),
    tag.toString('base64'),
  ].join(':');
}

export function decryptSeed(payload: string, key: Buffer): Buffer {
  const [ivBase64, ciphertextBase64, tagBase64, ...rest] = payload.split(':');
  if (!ivBase64 || !ciphertextBase64 || !tagBase64 || rest.length > 0) {
    throw new Error('Invalid encrypted seed payload format');
  }

  const iv = Buffer.from(ivBase64, 'base64');
  const ciphertext = Buffer.from(ciphertextBase64, 'base64');
  const tag = Buffer.from(tagBase64, 'base64');

  if (iv.length !== IV_LENGTH) {
    throw new Error('Invalid encrypted seed IV');
  }

  if (tag.length !== TAG_LENGTH) {
    throw new Error('Invalid encrypted seed auth tag');
  }

  const decipher = createDecipheriv('aes-256-gcm', key, iv);
  decipher.setAuthTag(tag);

  return Buffer.concat([decipher.update(ciphertext), decipher.final()]);
}
