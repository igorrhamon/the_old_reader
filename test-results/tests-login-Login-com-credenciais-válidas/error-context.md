# Test info

- Name: Login com credenciais válidas
- Location: C:\Users\igor-\the_old_reader\tests\login.spec.ts:5:5

# Error details

```
Error: Timed out 5000ms waiting for expect(locator).toBeVisible()

Locator: getByPlaceholder('Email')
Expected: visible
Received: <element(s) not found>
Call log:
  - expect.toBeVisible with timeout 5000ms
  - waiting for getByPlaceholder('Email')

    at C:\Users\igor-\the_old_reader\tests\login.spec.ts:10:48
```

# Page snapshot

```yaml
- button "Enable accessibility"
```

# Test source

```ts
   1 | import { test, expect } from '@playwright/test';
   2 |
   3 | test.use({ browserName: 'chromium' });
   4 |
   5 | test('Login com credenciais válidas', async ({ page }) => {
   6 |   await page.goto('http://127.0.0.1:8000/');
   7 |   test.setTimeout(80000);
   8 |
   9 |   // Aguarda o campo aparecer
> 10 |   await expect(page.getByPlaceholder('Email')).toBeVisible();
     |                                                ^ Error: Timed out 5000ms waiting for expect(locator).toBeVisible()
  11 |
  12 |   // Preenche login
  13 |   await page.getByPlaceholder('Email').fill(process.env.the_old_reader_email || 'SEU_EMAIL');
  14 |   await page.getByPlaceholder('Password').fill(process.env.the_old_reader_password || 'SUA_SENHA');
  15 |   await page.getByRole('button', { name: /log in/i }).click();
  16 |
  17 |   // Aguarda tela principal
  18 |   await expect(page.getByText(/assinaturas|feeds|subscriptions/i)).toBeVisible();
  19 | });
```