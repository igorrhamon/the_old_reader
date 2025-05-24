import { test, expect } from '@playwright/test';

test.use({ browserName: 'chromium' });

test('Login com credenciais válidas', async ({ page }) => {
  await page.goto('http://127.0.0.1:8000/');
  test.setTimeout(80000);

  // Aguarda o campo aparecer
  await expect(page.getByPlaceholder('Email')).toBeVisible();

  // Preenche login
  await page.getByPlaceholder('Email').fill(process.env.the_old_reader_email || 'SEU_EMAIL');
  await page.getByPlaceholder('Password').fill(process.env.the_old_reader_password || 'SUA_SENHA');
  await page.getByRole('button', { name: /log in/i }).click();

  // Aguarda tela principal
  await expect(page.getByText(/assinaturas|feeds|subscriptions/i)).toBeVisible();
});