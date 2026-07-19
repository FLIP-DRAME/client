const config = require('../config');
const { launchBrowser, waitForCanvas, screenshotPath, watchForErrors } = require('../lib/harness');

const delay = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2200 });
  watchForErrors(page, 'sort_notice');

  await page.goto(config.baseUrl + '/home', { waitUntil: 'load', timeout: 30000 });
  await waitForCanvas(page);
  await delay(8000);
  await page.screenshot({ path: screenshotPath(config, 'sort_notice_home'), fullPage: true });
  console.log('done');

  await browser.close();
})();
