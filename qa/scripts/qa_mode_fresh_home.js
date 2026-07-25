const config = require('../config');
const { launchBrowser, waitForCanvas, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');
const delay = ms => new Promise(r => setTimeout(r, ms));
(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2700 });
  watchForErrors(page, 'fresh');
  await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password, '/home');
  await delay(2000);
  await page.screenshot({ path: screenshotPath(config, 'fresh_home_now') });
  console.log('DONE');
  await browser.close();
})();
