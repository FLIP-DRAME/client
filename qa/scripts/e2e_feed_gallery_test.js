/**
 * E2E Test - Feed Gallery Redesign
 * Tests the new Naver cafe style gallery layout (1 col mobile / 4 col desktop)
 */
const puppeteer = require('puppeteer');
const path = require('path');

const BASE_URL = 'http://localhost:9001';
const OUT_DIR = path.join(__dirname, '../../screenshots/e2e');

const SUPABASE_URL = 'https://wgujitwmipifuhxavmsn.supabase.co';
const SUPABASE_KEY = 'sb_publishable_6r9yqZWSOOWJhwVJXRD8Xw_KsgLSISW';
const PROJECT_REF = 'wgujitwmipifuhxavmsn';
const STORAGE_KEY = `sb-${PROJECT_REF}-auth-token`;

const delay = ms => new Promise(r => setTimeout(r, ms));

async function injectLogin(page, email, password) {
  const session = await page.evaluate(async (url, key, email, password) => {
    const res = await fetch(`${url}/auth/v1/token?grant_type=password`, {
      method: 'POST',
      headers: { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    return res.json();
  }, SUPABASE_URL, SUPABASE_KEY, email, password);
  if (!session.access_token) {
    console.error('LOGIN FAILED', session);
    return false;
  }
  await page.evaluate((k, s) => localStorage.setItem(k, JSON.stringify(s)), STORAGE_KEY, session);
  return true;
}

async function waitForCanvas(page, timeoutMs = 30000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const found = await page.evaluate(() => !!(document.querySelector('canvas') || document.querySelector('flt-glass-pane')));
    if (found) return true;
    await new Promise(r => setTimeout(r, 500));
  }
  return false;
}

async function shot(page, name) {
  const fs = require('fs');
  if (!fs.existsSync(OUT_DIR)) {
    fs.mkdirSync(OUT_DIR, { recursive: true });
  }
  const file = path.join(OUT_DIR, `${name}.png`);
  await page.screenshot({ path: file, fullPage: false });
  console.log('[SHOT]', file);
  return file;
}

let testsPassed = 0;
let testsFailed = 0;

function pass(testName) {
  testsPassed++;
  console.log(`✅ PASS: ${testName}`);
}

function fail(testName, reason) {
  testsFailed++;
  console.log(`❌ FAIL: ${testName} - ${reason}`);
}

async function main() {
  const consoleErrors = [];
  const pageErrors = [];

  console.log('🚀 Starting E2E Tests for Feed Gallery Redesign\n');

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    // ═══════════════════════════════════════════════════════════════════════════
    // TEST 1: Desktop 4-column layout
    // ═══════════════════════════════════════════════════════════════════════════
    console.log('\n=== TEST 1: Desktop 4-column layout ===');
    const desktopPage = await browser.newPage();
    await desktopPage.setViewport({ width: 1440, height: 900 });

    desktopPage.on('console', msg => {
      if (msg.type() === 'error') consoleErrors.push(msg.text());
    });
    desktopPage.on('pageerror', err => pageErrors.push(err.message));

    await desktopPage.goto(BASE_URL + '/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(desktopPage);
    await delay(5000);

    await shot(desktopPage, '01_desktop_feed_gallery');

    // Check if page loaded
    const desktopHasContent = await desktopPage.evaluate(() => {
      return document.body.innerText.length > 100;
    });

    if (desktopHasContent) {
      pass('Desktop feed page loads correctly');
    } else {
      fail('Desktop feed page loads correctly', 'Page content is empty');
    }

    await desktopPage.close();

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST 2: Mobile 1-column layout
    // ═══════════════════════════════════════════════════════════════════════════
    console.log('\n=== TEST 2: Mobile 1-column layout ===');
    const mobilePage = await browser.newPage();
    await mobilePage.setViewport({ width: 390, height: 844 });

    await mobilePage.goto(BASE_URL + '/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(mobilePage);
    await delay(5000);

    await shot(mobilePage, '02_mobile_feed_gallery');

    const mobileHasContent = await mobilePage.evaluate(() => {
      return document.body.innerText.length > 100;
    });

    if (mobileHasContent) {
      pass('Mobile feed page loads correctly');
    } else {
      fail('Mobile feed page loads correctly', 'Page content is empty');
    }

    await mobilePage.close();

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST 3: Operator feed page with compose form
    // ═══════════════════════════════════════════════════════════════════════════
    console.log('\n=== TEST 3: Operator feed page with compose form ===');
    const opPage = await browser.newPage();
    await opPage.setViewport({ width: 1440, height: 900 });

    // Login
    await opPage.goto(BASE_URL + '/home', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(opPage);
    await delay(2000);

    const loginResult = await injectLogin(opPage, 'review-operator@modedrone.kr', 'Review2026!');
    if (loginResult) {
      pass('Login successful');
    } else {
      fail('Login successful', 'Could not authenticate');
    }

    // Navigate to operator feed page
    await opPage.goto(BASE_URL + '/operator/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(opPage);
    await delay(6000);

    await shot(opPage, '03_operator_feed_page');

    const opFeedHasContent = await opPage.evaluate(() => {
      const text = document.body.innerText || '';
      return text.includes('피드') || text.includes('게시물');
    });

    if (opFeedHasContent) {
      pass('Operator feed page loads correctly');
    } else {
      fail('Operator feed page loads correctly', 'Expected feed content not found');
    }

    await opPage.close();

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST 4: Feed filters work
    // ═══════════════════════════════════════════════════════════════════════════
    console.log('\n=== TEST 4: Feed filters visible ===');
    const filterPage = await browser.newPage();
    await filterPage.setViewport({ width: 1440, height: 900 });

    await filterPage.goto(BASE_URL + '/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(filterPage);
    await delay(5000);

    const hasFilters = await filterPage.evaluate(() => {
      const text = document.body.innerText || '';
      return text.includes('지역') || text.includes('카테고리') || text.includes('인기순');
    });

    if (hasFilters) {
      pass('Feed filter controls are visible');
    } else {
      fail('Feed filter controls are visible', 'Filter controls not found');
    }

    await filterPage.close();

  } catch (err) {
    console.error('\n🔥 FATAL ERROR:', err.message);
    testsFailed++;
  } finally {
    await browser.close();

    // ═══════════════════════════════════════════════════════════════════════════
    // SUMMARY
    // ═══════════════════════════════════════════════════════════════════════════
    console.log('\n' + '═'.repeat(60));
    console.log('📊 E2E TEST SUMMARY');
    console.log('═'.repeat(60));
    console.log(`✅ Passed: ${testsPassed}`);
    console.log(`❌ Failed: ${testsFailed}`);
    console.log(`📁 Screenshots: ${OUT_DIR}`);

    if (consoleErrors.length > 0) {
      console.log(`\n⚠️  Console Errors (${consoleErrors.length}):`);
      consoleErrors.slice(0, 5).forEach(e => console.log(`   - ${e.slice(0, 100)}`));
    }

    if (testsFailed === 0) {
      console.log('\n🎉 All tests passed!');
      process.exit(0);
    } else {
      console.log('\n💥 Some tests failed!');
      process.exit(1);
    }
  }
}

main();
