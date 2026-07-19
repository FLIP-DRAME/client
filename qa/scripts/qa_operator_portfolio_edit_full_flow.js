const config = require('../config');
const { launchBrowser, loginAndReload, screenshotPath, watchForErrors } = require('../lib/harness');

const delay = (ms) => new Promise((r) => setTimeout(r, ms));

async function typeInField(page, x, y, text) {
  await page.mouse.click(x, y);
  await delay(200);
  await page.keyboard.down('Control');
  await page.keyboard.press('KeyA');
  await page.keyboard.up('Control');
  await page.keyboard.type(text, { delay: 20 });
}

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 1600 });
  watchForErrors(page, 'op_full');
  page.on('response', (res) => {
    const url = res.url();
    if (url.includes('operator_profiles') && res.request().method() === 'PATCH') {
      console.log('[PATCH]', res.status(), url.slice(0, 200));
    }
  });

  await loginAndReload(page, config, config.accounts.operator.email, config.accounts.operator.password, '/operator');

  await page.goto(config.baseUrl + '/operator/portfolio', { waitUntil: 'load', timeout: 30000 });
  await delay(12000);

  console.log('=== click 편집하기 ===');
  await page.mouse.click(1278, 127);
  await delay(2000);

  console.log('=== 한줄 소개 ===');
  await typeInField(page, 712, 305, 'QA 검증용 드론 촬영 전문 운용자입니다.');

  console.log('=== 서비스 상세설명 (before layout shifts) ===');
  await typeInField(
    page,
    712,
    644,
    'DJI Mavic 3 Pro 및 인스파이어 시리즈 보유. 항공촬영, 행사촬영, 시설점검 경력 5년 이상. 4K 영상 및 열화상 촬영 가능하며 당일 편집본 제공합니다.'
  );
  await page.screenshot({ path: screenshotPath(config, 'op_full_01_text_filled') });

  console.log('=== 전문 분야: 항공촬영 ===');
  await page.mouse.click(647, 410);
  await delay(300);

  console.log('=== 서비스 지역: 서울, 경기 ===');
  await page.mouse.click(667, 496);
  await delay(300);
  await page.mouse.click(591, 496);
  await delay(300);
  await page.screenshot({ path: screenshotPath(config, 'op_full_02_region_selected') });

  console.log('=== 저장하기 ===');
  await page.mouse.click(1288, 138);
  await delay(4000);
  console.log('URL after save:', page.url());
  await page.screenshot({ path: screenshotPath(config, 'op_full_03_after_save') });

  await browser.close();
})();
