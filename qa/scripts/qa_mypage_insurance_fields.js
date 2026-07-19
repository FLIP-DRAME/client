const path = require('path');
const config = require('../config');
const { launchBrowser, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');

const delay = (ms) => new Promise((r) => setTimeout(r, ms));
const DUMMY_PDF = path.join(__dirname, '..', 'screenshots', 'dummy.pdf');

async function typeInField(page, x, y, text) {
  await page.mouse.click(x, y);
  await delay(200);
  // select-all then type, in case there's existing/hint interaction
  await page.keyboard.down('Control');
  await page.keyboard.press('KeyA');
  await page.keyboard.up('Control');
  await page.keyboard.type(text, { delay: 30 });
}

async function uploadFile(page, x, y, filePath) {
  const [chooser] = await Promise.all([
    page.waitForFileChooser({ timeout: 5000 }),
    page.mouse.click(x, y),
  ]);
  await chooser.accept([filePath]);
}

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2900 });
  watchForErrors(page, 'mypage_insurance');

  await loginAndReload(page, config, config.accounts.operator.email, config.accounts.operator.password, '/operator');

  await page.goto(config.baseUrl + '/operator/mypage', { waitUntil: 'load', timeout: 30000 });
  await delay(6000);

  console.log('=== Fill required text fields ===');
  await typeInField(page, 1089, 532, '24-000123');   // 자격증 번호
  await typeInField(page, 1089, 579, '드라메 항공촬영 QA'); // 상호명
  await typeInField(page, 1089, 625, '12345678901');  // 사업자등록번호 (formatter inserts dashes)
  await typeInField(page, 1089, 672, '홍길동');        // 대표자명
  await typeInField(page, 464, 1101, 'Mavic 3 Pro QA'); // 모델명
  await typeInField(page, 464, 1147, 'S1234567');       // 신고번호
  await page.mouse.click(244, 1230); // 촬영용 category chip
  await delay(300);
  await page.screenshot({ path: screenshotPath(config, 'mypage_03_text_filled'), fullPage: true });

  console.log('=== Upload PDFs ===');
  await uploadFile(page, 1031, 763, DUMMY_PDF); // 자격증 파일
  await delay(1500);
  await uploadFile(page, 1031, 852, DUMMY_PDF); // 사업자등록증 파일
  await delay(1500);
  await uploadFile(page, 1031, 1099, DUMMY_PDF); // 보험 증권 파일
  await delay(1500);
  await page.screenshot({ path: screenshotPath(config, 'mypage_04_files_uploaded'), fullPage: true });

  console.log('=== Click Save ===');
  await page.mouse.click(1238, 1504);
  await delay(2500);
  console.log('URL after save:', page.url());
  await page.screenshot({ path: screenshotPath(config, 'mypage_05_after_save'), fullPage: true });

  await browser.close();
})();
