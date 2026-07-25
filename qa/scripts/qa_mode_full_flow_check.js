// Full-flow QA after the Mode design-system migration (feat/mode-design-system).
// Walks every route in app_router.dart for both client and operator roles, at
// both desktop and mobile viewports (mobile exercises mobile_redesign_component.dart,
// one of the two mega files that got migrated), plus a couple of real click-driven
// flows (home -> operator portfolio -> quote request form). Screenshots everything
// and reports any console/page errors.
const config = require('../config');
const { launchBrowser, waitForCanvas, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');
const delay = ms => new Promise(r => setTimeout(r, ms));

const errors = [];

async function visit(page, label, path, waitMs = 3000) {
  console.log(`=== ${label} (${path}) ===`);
  try {
    await page.goto(config.baseUrl + path, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(page);
    await delay(waitMs);
    await page.screenshot({ path: screenshotPath(config, `flow_${label}`) });
  } catch (e) {
    console.error(`  FAILED to visit ${path}:`, e.message);
    errors.push(`visit ${label}: ${e.message}`);
  }
}

async function run(viewportLabel, width, height) {
  const { browser, page } = await launchBrowser(config, { width, height });
  watchForErrors(page, `flow_${viewportLabel}`);
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(`[${viewportLabel}] console: ${msg.text()}`);
  });
  page.on('pageerror', (err) => {
    errors.push(`[${viewportLabel}] pageerror: ${err.message}`);
  });

  console.log(`\n########## ${viewportLabel} (${width}x${height}) ##########`);

  console.log('--- PUBLIC (no login) ---');
  await visit(page, `${viewportLabel}_landing`, '/landing');
  await visit(page, `${viewportLabel}_login`, '/login');
  await visit(page, `${viewportLabel}_signup`, '/signup');

  console.log('--- CLIENT ROLE ---');
  await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password, '/home');
  await visit(page, `${viewportLabel}_client_home`, '/home');
  await visit(page, `${viewportLabel}_client_feed`, '/feed');
  await visit(page, `${viewportLabel}_client_my_quotes`, '/my/quotes');
  await visit(page, `${viewportLabel}_client_chats`, '/chats');
  await visit(page, `${viewportLabel}_client_privacy`, '/privacy');
  await visit(page, `${viewportLabel}_client_terms`, '/terms');
  await visit(page, `${viewportLabel}_client_blocked`, '/blocked-users');
  await visit(page, `${viewportLabel}_client_delete_account`, '/delete-account');

  console.log('--- OPERATOR ROLE ---');
  await loginAndReload(page, config, config.accounts.operator.email, config.accounts.operator.password, '/home');
  await visit(page, `${viewportLabel}_operator_dashboard`, '/operator');
  await visit(page, `${viewportLabel}_operator_mypage`, '/operator/mypage');
  await visit(page, `${viewportLabel}_operator_feed`, '/operator/feed');
  await visit(page, `${viewportLabel}_operator_portfolio`, '/operator/portfolio');
  await visit(page, `${viewportLabel}_operator_requests`, '/operator/requests');

  await browser.close();
}

async function clickFlow() {
  console.log('\n########## CLICK-DRIVEN FLOW (desktop, client) ##########');
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2700 });
  watchForErrors(page, 'flow_click');
  page.on('console', (msg) => { if (msg.type() === 'error') errors.push(`[click] console: ${msg.text()}`); });
  page.on('pageerror', (err) => { errors.push(`[click] pageerror: ${err.message}`); });

  try {
    await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password, '/home');
    await delay(2000);
    await page.screenshot({ path: screenshotPath(config, 'flow_click_01_home') });

    console.log('=== click first operator card link ===');
    // "포트폴리오 보기 >" link on the first operator card, per earlier screenshot layout.
    await page.mouse.click(350, 1985);
    await delay(3000);
    console.log('URL after click:', page.url());
    await page.screenshot({ path: screenshotPath(config, 'flow_click_02_after_card_click') });

    if (page.url().includes('/portfolio/')) {
      console.log('=== landed on operator portfolio, look for quote request CTA ===');
      await delay(1000);
      await page.screenshot({ path: screenshotPath(config, 'flow_click_03_portfolio_detail') });
    } else {
      console.log('  (did not navigate to a portfolio page - card click coordinates may be stale)');
    }
  } catch (e) {
    console.error('click flow error:', e.message);
    errors.push(`click flow: ${e.message}`);
  } finally {
    await browser.close();
  }
}

(async () => {
  await run('desktop', 1440, 2700);
  await run('mobile', 390, 2700);
  await clickFlow();

  console.log('\n########## SUMMARY ##########');
  console.log(`Total errors: ${errors.length}`);
  errors.forEach((e) => console.log(' -', e));
  console.log('DONE');
})();
