import { expect, test } from '@playwright/test';

test('requester can view their synthetic request history @smoke', async ({ page }) => {
  await page.route('**/api/requests/mine/history', async (route) =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([
        {
          id: 'request-1',
          requesterId: 'EMP-TEST-001',
          departmentId: 'DEPT-TEST-001',
          projectId: 'PRJ-TEST-ALPHA',
          startDate: '2026-09-01',
          endDate: '2026-09-05',
          reason: null,
          status: 'Approved',
          createdAt: '2026-08-01T08:00:00Z',
          updatedAt: '2026-08-01T08:00:00Z',
          version: 1,
          taken: true,
        },
      ]),
    }),
  );

  await page.goto('/');

  await expect(page.getByRole('heading', { name: 'My vacation requests' })).toBeVisible();
  await expect(page.getByRole('cell', { name: 'Approved' })).toBeVisible();
  await expect(page.getByRole('cell', { name: 'Taken' })).toBeVisible();
});
