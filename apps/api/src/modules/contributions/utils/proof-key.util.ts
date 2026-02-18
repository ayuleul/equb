const GROUPS_ROOT = 'groups';

export interface ParsedContributionProofKey {
  groupId: string;
  cycleId: string;
  userId: string;
}

export interface ParsedGroupScopedStorageKey {
  groupId: string;
  cycleId: string;
  scope: 'contribution' | 'payout';
  userId?: string;
}

export function sanitizeFileName(fileName: string): string {
  const trimmed = fileName.trim();
  const safe = trimmed.replace(/[^a-zA-Z0-9._-]/g, '_');
  return safe.length > 0 ? safe : 'file';
}

export function buildContributionProofPrefix(
  groupId: string,
  cycleId: string,
  userId: string,
): string {
  return `${GROUPS_ROOT}/${groupId}/cycles/${cycleId}/users/${userId}/`;
}

export function buildPayoutProofPrefix(
  groupId: string,
  cycleId: string,
): string {
  return `${GROUPS_ROOT}/${groupId}/cycles/${cycleId}/payouts/`;
}

export function parseContributionProofKey(
  key: string,
): ParsedContributionProofKey | null {
  const parts = key.split('/');

  if (parts.length < 7) {
    return null;
  }

  if (
    parts[0] !== GROUPS_ROOT ||
    parts[2] !== 'cycles' ||
    parts[4] !== 'users'
  ) {
    return null;
  }

  const groupId = parts[1];
  const cycleId = parts[3];
  const userId = parts[5];

  if (!groupId || !cycleId || !userId) {
    return null;
  }

  return {
    groupId,
    cycleId,
    userId,
  };
}

export function parseGroupScopedStorageKey(
  key: string,
): ParsedGroupScopedStorageKey | null {
  const parts = key.split('/');

  if (parts.length < 6) {
    return null;
  }

  if (parts[0] !== GROUPS_ROOT || parts[2] !== 'cycles') {
    return null;
  }

  const groupId = parts[1];
  const cycleId = parts[3];
  const scopePart = parts[4];

  if (!groupId || !cycleId || !scopePart) {
    return null;
  }

  if (scopePart === 'users') {
    const userId = parts[5];
    if (!userId || parts.length < 7) {
      return null;
    }

    return {
      groupId,
      cycleId,
      userId,
      scope: 'contribution',
    };
  }

  if (scopePart === 'payouts' && parts.length >= 6) {
    return {
      groupId,
      cycleId,
      scope: 'payout',
    };
  }

  return null;
}

export function isContributionProofKeyScopedTo(
  key: string,
  groupId: string,
  cycleId: string,
  userId: string,
): boolean {
  return key.startsWith(buildContributionProofPrefix(groupId, cycleId, userId));
}

export function isPayoutProofKeyScopedTo(
  key: string,
  groupId: string,
  cycleId: string,
): boolean {
  return key.startsWith(buildPayoutProofPrefix(groupId, cycleId));
}
