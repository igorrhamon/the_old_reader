import { test, expect } from '@playwright/test';

/**
 * Este teste requer as variáveis de ambiente
 * `the_old_reader_email` e `the_old_reader_password`.
 */
const email = process.env.the_old_reader_email;
const password = process.env.the_old_reader_password;

test.skip(
  !email || !password,
  'Defina as variáveis de ambiente the_old_reader_email e the_old_reader_password para executar este teste',
);

test.use({ browserName: 'chromium' });

test('Login com credenciais válidas', async ({ page }) => {
  await page.goto('http://127.0.0.1:8000/');
  test.setTimeout(80000);

  // Aguarda o campo aparecer
  await expect(page.getByPlaceholder('Email')).toBeVisible();

  // Preenche login
  await page.getByPlaceholder('Email').fill(email!);
  await page.getByPlaceholder('Password').fill(password!);
  await page.getByRole('button', { name: /log in/i }).click();

  // Aguarda tela principal
  await expect(page.getByText(/assinaturas|feeds|subscriptions/i)).toBeVisible();
  await expect(page).toHaveURL(/reader/i);
});
