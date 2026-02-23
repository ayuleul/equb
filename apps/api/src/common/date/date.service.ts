import { Injectable } from '@nestjs/common';
import { GroupFrequency } from '@prisma/client';

const DEFAULT_TIMEZONE = 'Africa/Addis_Ababa';
const ONE_DAY_MS = 24 * 60 * 60 * 1_000;

@Injectable()
export class DateService {
  normalizeGroupDate(date: Date, timezone: string): Date {
    const resolvedTimezone = this.resolveTimezone(timezone);
    const parts = this.extractDateParts(date, resolvedTimezone);

    return new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
  }

  advanceDueDate(
    date: Date,
    frequency: GroupFrequency,
    timezone: string,
  ): Date {
    const resolvedTimezone = this.resolveTimezone(timezone);
    const parts = this.extractDateParts(date, resolvedTimezone);

    if (frequency === GroupFrequency.WEEKLY) {
      const baseUtcDate = Date.UTC(parts.year, parts.month - 1, parts.day);
      return new Date(baseUtcDate + 7 * ONE_DAY_MS);
    }

    const currentMonthIndex = parts.month - 1;
    const nextMonthIndex = currentMonthIndex + 1;
    const nextYear = parts.year + Math.floor(nextMonthIndex / 12);
    const normalizedNextMonthIndex = nextMonthIndex % 12;
    const maxDayInTargetMonth = this.daysInMonth(
      nextYear,
      normalizedNextMonthIndex,
    );
    const targetDay = Math.min(parts.day, maxDayInTargetMonth);

    return new Date(Date.UTC(nextYear, normalizedNextMonthIndex, targetDay));
  }

  advanceDueDateByDays(date: Date, days: number, timezone: string): Date {
    const resolvedTimezone = this.resolveTimezone(timezone);
    const parts = this.extractDateParts(date, resolvedTimezone);
    const baseUtcDate = Date.UTC(parts.year, parts.month - 1, parts.day);

    return new Date(baseUtcDate + days * ONE_DAY_MS);
  }

  isDueWithinNext24HoursOrToday(
    dueDate: Date,
    timezone: string,
    reference: Date = new Date(),
  ): boolean {
    const resolvedTimezone = this.resolveTimezone(timezone);
    const dueParts = this.extractDateParts(dueDate, resolvedTimezone);
    const referenceParts = this.extractDateParts(reference, resolvedTimezone);

    const dueDayUtc = Date.UTC(dueParts.year, dueParts.month - 1, dueParts.day);
    const referenceDayUtc = Date.UTC(
      referenceParts.year,
      referenceParts.month - 1,
      referenceParts.day,
    );
    const nextDayUtc = referenceDayUtc + ONE_DAY_MS;

    return dueDayUtc >= referenceDayUtc && dueDayUtc <= nextDayUtc;
  }

  dateKey(date: Date, timezone: string): string {
    const resolvedTimezone = this.resolveTimezone(timezone);
    const parts = this.extractDateParts(date, resolvedTimezone);

    return `${parts.year}-${this.pad(parts.month)}-${this.pad(parts.day)}`;
  }

  private resolveTimezone(timezone: string | null | undefined): string {
    if (!timezone) {
      return DEFAULT_TIMEZONE;
    }

    try {
      new Intl.DateTimeFormat('en-US', { timeZone: timezone });
      return timezone;
    } catch {
      return DEFAULT_TIMEZONE;
    }
  }

  private extractDateParts(
    date: Date,
    timezone: string,
  ): { year: number; month: number; day: number } {
    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone: timezone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(date);

    const year = Number(parts.find((part) => part.type === 'year')?.value);
    const month = Number(parts.find((part) => part.type === 'month')?.value);
    const day = Number(parts.find((part) => part.type === 'day')?.value);

    return { year, month, day };
  }

  private daysInMonth(year: number, monthIndex: number): number {
    return new Date(Date.UTC(year, monthIndex + 1, 0)).getUTCDate();
  }

  private pad(value: number): string {
    return value.toString().padStart(2, '0');
  }
}
