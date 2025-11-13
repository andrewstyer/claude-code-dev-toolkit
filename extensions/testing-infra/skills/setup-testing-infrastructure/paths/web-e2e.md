# Path 4: Web E2E Testing Infrastructure Setup

This path sets up E2E testing infrastructure for web applications using Playwright, Cypress, or Puppeteer.

---

## Phase 1: Environment Detection

### Examine Project

Look for:
- `package.json` WITHOUT "react-native"
- HTML entry point (index.html, public/index.html)
- Web bundler (webpack.config.js, vite.config.js, next.config.js)
- Existing test setup (jest, vitest, etc.)
- Existing E2E tests (playwright, cypress, puppeteer)

### Show Summary

```
🔍 Current setup detected:
- Framework: React / Vue / Angular / Vanilla
- Bundler: Webpack / Vite / Next.js
- Unit tests: Jest / Vitest found
- E2E tests: [Present/Not found]
- Dev server: npm run dev/start
```

---

## Phase 2: Minimal Questions

### Question 1: E2E Framework

```
Question: "Which E2E testing framework should we use?"
Options:
  - "Playwright"
    Description: "Modern, fast, multi-browser support. Best for new projects. Recommended by Microsoft. Can test Chrome, Firefox, Safari."

  - "Cypress"
    Description: "Developer-friendly, great DX, visual test runner. Best for React/Vue apps. Chrome/Firefox/Edge only."

  - "Puppeteer"
    Description: "Chrome-only, lightweight, good for simple cases. Direct control of Chrome DevTools Protocol."
```

### Question 2: Browser Targets

```
Question: "Which browsers should tests run against?"
Options:
  - "Chromium only"
    Description: "Fastest, covers ~65% of users. Sufficient for most cases."

  - "Chromium + Firefox"
    Description: "Covers ~80% of users. Good cross-browser validation."

  - "All major browsers (Chromium, Firefox, Safari)"
    Description: "Most comprehensive. Required if Safari support is critical. Slower test runs."
```

### Question 3: Quality Gates

```
Question: "Should E2E tests block deployment if they fail?"
Options:
  - "Yes, block deployment"
  - "No, tests are optional"
```

### Question 4: Sample Test

Same as other paths

---

## Phase 3: Implementation

### Step 1: Install E2E Framework

**For Playwright:**

```bash
npm init playwright@latest
# Follow prompts to configure

# Verify
npx playwright --version
```

**For Cypress:**

```bash
npm install --save-dev cypress
npx cypress open  # Opens setup wizard

# Verify
npx cypress --version
```

**For Puppeteer:**

```bash
npm install --save-dev puppeteer
npm install --save-dev jest-puppeteer

# Verify
npx puppeteer --version
```

Git commit:
```bash
git add package.json package-lock.json playwright.config.js  # or cypress.json
git commit -m "chore: install Playwright for E2E testing"
```

### Step 2: Configure E2E Tests

**For Playwright:**

`playwright.config.js`:

```javascript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',

  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Add more browsers as needed
  ],

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

**For Cypress:**

`cypress.config.js`:

```javascript
const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
```

### Step 3: Add npm Scripts with Quality Gates

`package.json`:

```json
{
  "scripts": {
    "test": "jest",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:all": "npm test && npm run test:e2e",
    "predeploy": "npm run test:all",
    "deploy": "npm run build && <your deploy command>"
  }
}
```

The `predeploy` script acts as a quality gate - it runs automatically before `deploy` and blocks if tests fail.

Git commit:
```bash
git add package.json playwright.config.js
git commit -m "feat: add E2E quality gates to npm scripts"
```

### Step 4: Create Sample E2E Test

**For Playwright:**

`e2e/app-loads.spec.js`:

```javascript
import { test, expect } from '@playwright/test';

test('app loads and displays content', async ({ page }) => {
  await page.goto('/');

  // Check that page title is visible
  await expect(page).toHaveTitle(/Your App Name/);

  // Check that main content loads
  await expect(page.locator('body')).toBeVisible();

  // Take screenshot
  await page.screenshot({ path: 'screenshots/app-loaded.png' });
});
```

**For Cypress:**

`cypress/e2e/app-loads.cy.js`:

```javascript
describe('App Loads', () => {
  it('displays the home page', () => {
    cy.visit('/');

    cy.title().should('include', 'Your App Name');
    cy.get('body').should('be.visible');

    cy.screenshot('app-loaded');
  });
});
```

Git commit:
```bash
git add e2e/ .testing-setup-state.json  # or cypress/
git commit -m "test: add sample E2E test for app loading"
```

### Step 5: Configure Browser State Cleanup

**For Playwright:**

Already handled - Playwright uses fresh browser context for each test.

**For Cypress:**

`cypress/support/e2e.js`:

```javascript
beforeEach(() => {
  // Clear cookies, localStorage, sessionStorage before each test
  cy.clearCookies();
  cy.clearLocalStorage();
  window.sessionStorage.clear();
});
```

### Step 6: Generate Documentation

Create `TESTING-WORKFLOW.md`:

```markdown
# Testing Workflow - Web Application

**Framework:** Playwright (or Cypress)
**Browsers:** Chromium, Firefox, WebKit

## Quick Start

### Development Testing
npm test  # Unit tests

### E2E Testing
npm run test:e2e  # Headless
npm run test:e2e:ui  # UI mode

### Full Test Suite
npm run test:all  # Unit + E2E

### Deploy with Quality Gates
npm run deploy  # Runs test:all automatically

## Available Commands

### npm test
- Runs Jest/Vitest unit tests
- Fast feedback
- Use during development

### npm run test:e2e
- Runs Playwright E2E tests
- Headless mode
- Tests all configured browsers
- Time: 30-60 seconds

### npm run test:all
- Runs unit + E2E tests
- Required before deployment
- Quality gate for CI/CD
- Time: 1-2 minutes

### npm run deploy
- Runs test:all (blocks if tests fail)
- Builds production bundle
- Deploys to hosting
- Time: 3-5 minutes

## Workflows

### Development Iteration
1. Make changes
2. Run `npm test`
3. See changes in browser
4. Commit

### Feature Completion
1. Run `npm run test:all`
2. All tests must pass
3. Merge to main

### Deployment
1. Run `npm run deploy`
2. Quality gates auto-enforce
3. Build and deploy on success

## Browser State Management

Playwright automatically provides:
- Fresh browser context per test
- Isolated cookies/localStorage
- Clean state for each test

No manual cleanup needed!

## Troubleshooting

### Tests fail in CI but pass locally
- Check browser versions match
- Increase timeouts for slower CI
- Check environment variables

### Flaky tests
- Add explicit waits for async operations
- Use Playwright's auto-waiting features
- Avoid hardcoded delays

## CI/CD Integration

GitHub Actions example:

\`\`\`yaml
- name: Run tests
  run: npm run test:all

- name: Deploy
  if: success()
  run: npm run deploy
\`\`\`
```

Create `BROWSER-TESTING-CHECKLIST.md`, `CI-INTEGRATION-GUIDE.md`, and `scripts/verify-bundle.sh`.

Git commit:
```bash
git add TESTING-WORKFLOW.md BROWSER-TESTING-CHECKLIST.md scripts/ .testing-setup-state.json
git commit -m "docs: add comprehensive testing documentation"
```

---

## Phase 4: Verification

### Test Unit Tests

```bash
npm test
```

### Test E2E

```bash
# Start dev server (if not auto-started)
npm run dev &

# Run E2E tests
npm run test:e2e
```

### Test Quality Gate

```bash
# Break a test temporarily
echo "test('fails', () => { expect(true).toBe(false); });" >> src/App.test.js

# Try to deploy
npm run deploy  # Should fail at predeploy step

# Fix test
rm src/App.test.js  # or fix it

# Try again
npm run deploy  # Should succeed
```

---

## Phase 5: Handoff

### Show Summary

```
✅ Testing Infrastructure Setup Complete!

📦 What was set up:
- Playwright E2E testing framework
- Quality gates in npm scripts (predeploy)
- Automatic browser state cleanup
- Sample E2E test (app-loads.spec.js)
- Comprehensive documentation (4 files)

🚀 Quick Start Commands:

Development:
$ npm test

E2E Testing:
$ npm run test:e2e
$ npm run test:e2e:ui  # Visual mode

Full Suite:
$ npm run test:all

Deploy with Quality Gates:
$ npm run deploy

📚 Documentation:
- TESTING-WORKFLOW.md
- BROWSER-TESTING-CHECKLIST.md
- CI-INTEGRATION-GUIDE.md
- scripts/verify-bundle.sh

✅ Verification:
- Unit tests: passing
- E2E tests: passing
- Quality gate blocks on failure: confirmed
- Quality gate allows on success: confirmed

🎯 Next Steps:
1. Review TESTING-WORKFLOW.md
2. Run: npm run test:all
3. Add more E2E tests to e2e/ directory
4. Configure deployment credentials
```

---

## Complete!

Web E2E testing infrastructure is fully configured and verified.
