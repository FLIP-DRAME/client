/**
 * Smoke test: /operator/portfolio should render the signed-in operator's own
 * profile (photo, intro, categories, region, description) rather than
 * hanging on the "프로필 정보를 불러오는 중입니다" loading text.
 */
const config = require('../config');
const { launchBrowser, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');

const delay = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 1600 });
  watchForErrors(page, 'op_portfolio_load');

  await loginAndReload(page, config, config.accounts.operator.email, config.accounts.operator.password, '/operator');

  await page.goto(config.baseUrl + '/operator/portfolio', { waitUntil: 'load', timeout: 30000 });
  await delay(15000);
  await page.screenshot({ path: screenshotPath(config, 'operator_portfolio_load_check') });
  console.log('URL:', page.url());

  await browser.close();
})();
