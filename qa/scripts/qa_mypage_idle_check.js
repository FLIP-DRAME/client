const path = require('path');
const config = require('../config');
const { launchBrowser, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');

const delay = (ms) => new Promise((r) => setTimeout(r, ms));
const DUMMY_PDF = path.join(__dirname, '..', 'screenshots', 'dummy.pdf');

async function typeInField(page, x, y, text) {
  await page.mouse.click(x, y);
  await delay(200);
  await page.keyboard.down('Control');
  await page.keyboard.press('KeyA');
  await page.keyboard.up('Control');
  await page.keyboard.type(text, { delay: 30 });
}

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2900 });
  watchForErrors(page, 'save_retest');

  await loginAndReload(page, config, config.accounts.operator.email, config.accounts.operator.password, '/operator');

  await page.goto(config.baseUrl + '/operator/mypage', { waitUntil: 'load', timeout: 30000 });
  await delay(6000);

  await typeInField(page, 1089, 532, '24-000123');
  await typeInField(page, 1089, 579, '드라메 항공촬영 QA');
  await typeInField(page, 1089, 625, '12345678901');
  await typeInField(page, 1089, 672, '홍길동');
  await typeInField(page, 464, 1101, 'Mavic 3 Pro QA');
  await typeInField(page, 464, 1147, 'S1234567');
  await page.mouse.click(244, 1230);
  await delay(500);

  const [chooser1] = await Promise.all([page.waitForFileChooser({ timeout: 5000 }), page.mouse.click(1031, 763)]);
  await chooser1.accept([DUMMY_PDF]);
  await delay(1200);
  const [chooser2] = await Promise.all([page.waitForFileChooser({ timeout: 5000 }), page.mouse.click(1031, 852)]);
  await chooser2.accept([DUMMY_PDF]);
  await delay(1200);
  const [chooser3] = await Promise.all([page.waitForFileChooser({ timeout: 5000 }), page.mouse.click(1031, 1099)]);
  await chooser3.accept([DUMMY_PDF]);
  await delay(1200);

  console.log('=== waiting 16s for upload snackbars to clear, then clicking Save ===');
  await delay(16000);
  await page.mouse.click(1238, 1504);
  console.log('=== waiting 5s to catch the immediate result snackbar ===');
  await delay(800);
  console.log('URL now:', page.url());
  await page.screenshot({ path: screenshotPath(config, 'mypage_08_save_result_fixed'), fullPage: true });

  await browser.close();
})();
