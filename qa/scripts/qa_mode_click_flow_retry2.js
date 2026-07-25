const config = require('../config');
const { launchBrowser, waitForCanvas, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');
const delay = ms => new Promise(r => setTimeout(r, ms));

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2700 });
  watchForErrors(page, 'flow_click3');

  await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password, '/home');
  await delay(2000);

  console.log('=== click QXM card title text (center-ish of card, bigger target) ===');
  await page.mouse.click(150, 1346);
  await delay(2500);
  console.log('URL after click:', page.url());
  await page.screenshot({ path: screenshotPath(config, 'flow_click3_01') });
  await browser.close();
})();
