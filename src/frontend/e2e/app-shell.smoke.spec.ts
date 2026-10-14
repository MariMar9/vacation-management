import { expect, test } from '@playwright/test';

test('test workspace shell is available @smoke', async ({ page }) => {
  await page.goto('/');

  await expect(page.getByRole('heading', { level: 1, name: 'Vacation Management' })).toBeVisible();
  await expect(page.getByTestId('workspace-scope')).toHaveText('TEST WORKSPACE');
});
