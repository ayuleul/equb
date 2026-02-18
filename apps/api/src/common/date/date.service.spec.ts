import { GroupFrequency } from '@prisma/client';

import { DateService } from './date.service';

describe('DateService', () => {
  const service = new DateService();

  it('advances weekly due dates by 7 days', () => {
    const dueDate = new Date('2026-03-01T00:00:00.000Z');

    const nextDueDate = service.advanceDueDate(
      dueDate,
      GroupFrequency.WEEKLY,
      'Africa/Addis_Ababa',
    );

    expect(nextDueDate.toISOString()).toBe('2026-03-08T00:00:00.000Z');
  });

  it('advances monthly due dates with end-of-month clamp', () => {
    const dueDate = new Date('2026-01-31T00:00:00.000Z');

    const nextDueDate = service.advanceDueDate(
      dueDate,
      GroupFrequency.MONTHLY,
      'Africa/Addis_Ababa',
    );

    expect(nextDueDate.toISOString()).toBe('2026-02-28T00:00:00.000Z');
  });
});
