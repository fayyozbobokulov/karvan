import * as docActivities from './document.activities';
import * as govActivities from './government.activities';
import * as unitActivities from './unit.activities';

export const activities = {
  ...docActivities,
  ...govActivities,
  ...unitActivities,
};
