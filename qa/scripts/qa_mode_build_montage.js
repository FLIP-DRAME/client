const fs = require('fs');
const path = require('path');
const config = require('../config');
const { launchBrowser } = require('../lib/harness');

const SHOTS_DIR = config.screenshotsDir;
const files = fs.readdirSync(SHOTS_DIR)
  .filter((f) => /^flow_(desktop|mobile|click4_01)/.test(f))
  .sort();

function labelFor(file) {
  return file.replace(/^flow_/, '').replace(/\.png$/, '');
}

const cards = files.map((f) => {
  const p = path.join(SHOTS_DIR, f).replace(/\\/g, '/');
  return `
    <div class="card">
      <div class="label">${labelFor(f)}</div>
      <img src="file:///${p}" />
    </div>`;
}).join('\n');

const html = `<!doctype html>
<html><head><meta charset="utf-8"><style>
  body { margin: 0; padding: 24px; background: #111; font-family: sans-serif; }
  h1 { color: #fff; font-size: 20px; margin: 0 0 16px; }
  .grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 12px; }
  .card { background: #1c1c1c; border-radius: 6px; padding: 6px; }
  .label { color: #9ab; font-size: 11px; margin-bottom: 4px; word-break: break-all; }
  img { width: 100%; display: block; border-radius: 3px; background: #fff; }
</style></head>
<body>
  <h1>Mode design-system migration — full flow QA (${files.length} screenshots)</h1>
  <div class="grid">${cards}</div>
</body></html>`;

const htmlPath = path.join(SHOTS_DIR, '_montage.html');
fs.writeFileSync(htmlPath, html, 'utf-8');

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 2000, height: 1200 });
  await page.goto('file:///' + htmlPath.replace(/\\/g, '/'), { waitUntil: 'load' });
  // wait for all images to actually load
  await page.evaluate(() => Promise.all(
    Array.from(document.images).map((img) => img.complete ? Promise.resolve() : new Promise((res) => { img.onload = img.onerror = res; }))
  ));
  const outPath = path.join(SHOTS_DIR, '_montage.png');
  await page.screenshot({ path: outPath, fullPage: true });
  console.log('MONTAGE SAVED:', outPath);
  await browser.close();
})();
