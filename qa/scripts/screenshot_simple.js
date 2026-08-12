/**
 * Simple screenshot script that takes screenshots without login
 */
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'http://127.0.0.1:9003';
const OUT_DIR = path.join(__dirname, '../../artifacts');

const delay = ms => new Promise(r => setTimeout(r, ms));

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
  console.log('🚀 Starting Simple Screenshots\n');

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

    // Go to home page (public)
    console.log('=== Taking home page screenshot ===');
    await page.goto(BASE_URL + '/', { waitUntil: 'networkidle2', timeout: 60000 });
    await waitForCanvas(page);
    await delay(5000);
    await shot(page, '09_home_page');

    // Go to feed page (public)
    console.log('=== Taking feed page screenshot ===');
    await page.goto(BASE_URL + '/feed', { waitUntil: 'networkidle2', timeout: 60000 });
    await waitForCanvas(page);
    await delay(5000);
    await shot(page, '10_public_feed_page');

    console.log('\n✅ All screenshots completed!');
    console.log('📁 Output directory:', OUT_DIR);
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await browser.close();
  }
}

main();
