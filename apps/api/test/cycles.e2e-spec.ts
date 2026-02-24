import { GroupsController } from '../src/modules/groups/groups.controller';

describe('Cycles Flow (e2e)', () => {
  it('keeps start-cycle controller route available', () => {
    expect(typeof GroupsController.prototype.startCycle).toBe('function');
  });
});
