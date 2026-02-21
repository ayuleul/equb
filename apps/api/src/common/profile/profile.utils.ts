export interface UserProfileNameFields {
  firstName: string | null;
  middleName: string | null;
  lastName: string | null;
}

export function normalizeNameWhitespace(value: string): string {
  return value.trim().replace(/\s+/g, ' ');
}

export function isProfileComplete(profile: UserProfileNameFields): boolean {
  return (
    normalizeNameWhitespace(profile.firstName ?? '').length > 0 &&
    normalizeNameWhitespace(profile.middleName ?? '').length > 0 &&
    normalizeNameWhitespace(profile.lastName ?? '').length > 0
  );
}
