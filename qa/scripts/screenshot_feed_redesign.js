/**
 * Screenshot script for feed gallery redesign
 */
const puppeteer = require('puppeteer');
const path = require('path');

const BASE_URL = 'http://localhost:9002';
const OUT_DIR = path.join(__dirname, '../../screenshots');

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

async function main() {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    // Desktop screenshot (4 columns)
    console.log('=== Taking Desktop screenshot (4 columns) ===');
    const desktopPage = await browser.newPage();
    await desktopPage.setViewport({ width: 1440, height: 900 });
    await desktopPage.goto(BASE_URL + '/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(desktopPage);
    await delay(5000);
    await desktopPage.screenshot({ path: path.join(OUT_DIR, 'feed_desktop_4col.png'), fullPage: false });
    console.log('Desktop screenshot saved');

    // Mobile screenshot (1 column)
    console.log('=== Taking Mobile screenshot (1 column) ===');
    const mobilePage = await browser.newPage();
    await mobilePage.setViewport({ width: 390, height: 844 });
    await mobilePage.goto(BASE_URL + '/feed', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await waitForCanvas(mobilePage);
    await delay(5000);
    await mobilePage.screenshot({ path: path.join(OUT_DIR, 'feed_mobile_1col.png'), fullPage: false });
    console.log('Mobile screenshot saved');

    console.log('=== Screenshots completed ===');
    console.log('Output directory:', OUT_DIR);
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await browser.close();
  }
}

main();
