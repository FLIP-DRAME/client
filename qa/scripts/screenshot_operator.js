/**
 * Screenshot operator feed compose form with login via Supabase REST API
 */
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'http://127.0.0.1:9003';
const OUT_DIR = path.join(__dirname, '../../artifacts');

const SUPABASE_URL = 'https://wgujitwmipifuhxavmsn.supabase.co';
const SUPABASE_KEY = 'sb_publishable_6r9yqZWSOOWJhwVJXRD8Xw_KsgLSISW';
const PROJECT_REF = 'wgujitwmipifuhxavmsn';
const STORAGE_KEY = `sb-${PROJECT_REF}-auth-token`;

const delay = ms => new Promise(r => setTimeout(r, ms));

async function waitForCanvas(page, timeoutMs = 60000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const found = await page.evaluate(() => !!(document.querySelector('canvas') || document.querySelector('flt-glass-pane')));
    if (found) return true;
    await delay(500);
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
  console.log('🚀 Starting Operator Feed Screenshots\n');

  const browser = await puppeteer.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
    ],
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1440, height: 900 });

    // First, get auth token via REST API
    console.log('=== Getting auth token ===');
    const authResponse = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'review-operator@modedrone.kr',
        password: 'Review2026!',
      }),
    });
    const session = await authResponse.json();

    if (!session.access_token) {
      console.error('LOGIN FAILED', session);
      return;
    }
    console.log('Login successful!');

    // Go to home page first to set localStorage
    console.log('=== Going to home page first ===');
    await page.goto(BASE_URL + '/', { waitUntil: 'networkidle2', timeout: 60000 });
    await waitForCanvas(page);
    await delay(3000);

    // Inject session into localStorage
    console.log('=== Injecting session ===');
    await page.evaluate((key, sessionData) => {
      localStorage.setItem(key, JSON.stringify(sessionData));
    }, STORAGE_KEY, session);

    // Reload to apply session
    console.log('=== Reloading to apply session ===');
    await page.reload({ waitUntil: 'networkidle2' });
    await waitForCanvas(page);
    await delay(5000);

    // Click on 피드 tab in the navigation
    console.log('=== Clicking 피드 tab ===');
    await page.mouse.click(370, 30); // Position of 피드 tab
    await delay(5000);

    // Take screenshot of feed page
    await shot(page, '11_operator_feed_initial');

    // Click on "새 게시물" button to open compose form
    console.log('=== Clicking 새 게시물 button ===');
    await page.mouse.click(1245, 152); // Position of the 새 게시물 button (adjusted)
    await delay(3000);

    // Take screenshot of compose form opened
    await shot(page, '12_feed_compose_opened');

    // Scroll to top to show full form
    await page.evaluate(() => window.scrollTo(0, 0));
    await delay(1000);
    await shot(page, '13_feed_compose_full');

    console.log('\n✅ All screenshots completed!');
    console.log('📁 Output directory:', OUT_DIR);
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await browser.close();
  }
}

main();
