const config = require('../config');
const { launchBrowser, waitForCanvas, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');
const delay = ms => new Promise(r => setTimeout(r, ms));

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2700 });
  watchForErrors(page, 'flow_click2');

  await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password, '/home');
  await delay(1500);

  console.log('=== click QXM card "포트폴리오 보기" link ===');
  await page.mouse.click(423, 1409);
  await delay(3000);
  console.log('URL after click:', page.url());
  await page.screenshot({ path: screenshotPath(config, 'flow_click2_01_portfolio_detail') });

  if (page.url().includes('/portfolio/')) {
    console.log('=== scroll down looking for quote request CTA ===');
    await page.mouse.wheel({ deltaY: 800 });
    await delay(1500);
    await page.screenshot({ path: screenshotPath(config, 'flow_click2_02_portfolio_scrolled') });
  }

  console.log('=== try quote request page directly for a known pilot from earlier screenshot context ===');
  // Fall back: use go_router path directly isn't known without a real pilotId,
  // so just report the current state.
  console.log('DONE, final URL:', page.url());
  await browser.close();
})();
