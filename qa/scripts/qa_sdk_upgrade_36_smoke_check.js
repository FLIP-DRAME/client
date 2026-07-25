// One-off smoke check after upgrading Flutter 3.29.2 -> 3.44.7 (targetSdk 36
// compliance). Not a permanent regression suite -- just walks the main
// client + operator routes and watches for console/page errors, since a
// 1-year+ SDK jump is the kind of change unit tests won't catch.
const config = require('../config');
const { launchBrowser, waitForCanvas, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');
const delay = ms => new Promise(r => setTimeout(r, ms));

async function visit(page, label, path) {
  console.log(`=== ${label} (${path}) ===`);
  await page.goto(config.baseUrl + path, { waitUntil: 'domcontentloaded', timeout: 30000 });
  await waitForCanvas(page);
  await delay(3500);
  await page.screenshot({ path: screenshotPath(config, `sdk36_${label}`) });
}

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2700 });
  watchForErrors(page, 'sdk36');

  console.log('--- CLIENT ROLE ---');
  await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password, '/home');
  await visit(page, 'client_home', '/home');
  await visit(page, 'client_feed', '/feed');
  await visit(page, 'client_chats', '/chats');

  console.log('--- OPERATOR ROLE ---');
  await loginAndReload(page, config, config.accounts.operator.email, config.accounts.operator.password, '/home');
  await visit(page, 'operator_mypage', '/operator/mypage');
  await visit(page, 'operator_portfolio', '/operator/portfolio');
  await visit(page, 'operator_feed', '/feed');

  await browser.close();
  console.log('DONE');
})();
