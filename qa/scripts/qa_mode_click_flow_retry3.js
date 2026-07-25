const config = require('../config');
const { launchBrowser, waitForCanvas, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');
const delay = ms => new Promise(r => setTimeout(r, ms));

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2700 });
  watchForErrors(page, 'flow_click4');

  await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password, '/home');
  await delay(2000);

  console.log('=== click "채팅" nav link ===');
  await page.mouse.click(539, 31);
  await delay(2500);
  console.log('URL after nav click:', page.url());
  await page.screenshot({ path: screenshotPath(config, 'flow_click4_01_nav_chats') });

  console.log('=== click "내 견적" nav link ===');
  await page.goto(config.baseUrl + '/home', { waitUntil: 'domcontentloaded' });
  await waitForCanvas(page);
  await delay(2000);
  await page.mouse.click(249, 31);
  await delay(2500);
  console.log('URL after nav click:', page.url());
  await page.screenshot({ path: screenshotPath(config, 'flow_click4_02_nav_myquotes') });

  await browser.close();
})();
