/**
 * Screenshot feed compose UI and test feed creation
 */
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'http://localhost:9003';
const OUT_DIR = path.join(__dirname, '../../artifacts');

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
  if (!fs.existsSync(OUT_DIR)) {
    fs.mkdirSync(OUT_DIR, { recursive: true });
  }
  const file = path.join(OUT_DIR, `${name}.png`);
  await page.screenshot({ path: file, fullPage: false });
  console.log('[SHOT]', file);
  return file;
}

async function main() {
  console.log('🚀 Starting Feed Compose UI Screenshots\n');

  const browser = await puppeteer.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-web-security',
      '--disable-features=IsolateOrigins,site-per-process',
      '--allow-running-insecure-content',
    ],
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1440, height: 900 });

    // Login
    console.log('=== Logging in ===');
    await page.goto(BASE_URL + '/home', { waitUntil: 'networkidle0', timeout: 60000 });
    await waitForCanvas(page);
    await delay(3000);
    await injectLogin(page, 'review-operator@modedrone.kr', 'Review2026!');

    // Navigate to operator feed page
    console.log('=== Navigating to /operator/feed ===');
    await page.goto(BASE_URL + '/operator/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(page);
    await delay(6000);

    // Take screenshot of initial feed page
    await shot(page, '04_operator_feed_initial');

    // Click "새 게시물" button - find it by clicking in the top-right area
    console.log('=== Clicking 새 게시물 button ===');
    // The button is roughly at the right side of "내 피드" section header
    await page.mouse.click(1230, 160);
    await delay(2000);

    // Take screenshot of compose form opened
    await shot(page, '05_feed_compose_form_opened');

    // Take full page screenshot to see the entire form
    await page.setViewport({ width: 1440, height: 1200 });
    await delay(500);
    await shot(page, '06_feed_compose_form_full');

    // Screenshot the updated feed gallery
    console.log('=== Taking feed gallery screenshot ===');
    await page.goto(BASE_URL + '/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(page);
    await delay(5000);
    await page.setViewport({ width: 1440, height: 900 });
    await shot(page, '07_feed_gallery_with_caption');

    // Mobile view
    console.log('=== Taking mobile screenshot ===');
    await page.setViewport({ width: 390, height: 844 });
    await delay(1000);
    await shot(page, '08_feed_mobile_with_caption');

    console.log('\n✅ All screenshots completed!');
    console.log('📁 Output directory:', OUT_DIR);

  } catch (err) {
    console.error('Error:', err);
  } finally {
    await browser.close();
  }
}

main();
