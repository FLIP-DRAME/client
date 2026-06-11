// Simple SPA server that correctly serves dotfiles (like .env)
const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, 'build', 'web');
const PORT = 9001;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js':   'application/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.css':  'text/css',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.svg':  'image/svg+xml',
  '.ico':  'image/x-icon',
  '.ttf':  'font/ttf',
  '.otf':  'font/otf',
  '.woff': 'font/woff',
  '.woff2':'font/woff2',
  '.txt':  'text/plain',
  '':      'application/octet-stream',
};

http.createServer((req, res) => {
  let urlPath = decodeURIComponent(req.url.split('?')[0]);
  let filePath = path.join(ROOT, urlPath);

  const tryServe = (fp) => {
    if (!fs.existsSync(fp) || fs.statSync(fp).isDirectory()) return false;
    const ext = path.extname(fp);
    const mime = MIME[ext] || MIME[''];
    res.writeHead(200, { 'Content-Type': mime });
    fs.createReadStream(fp).pipe(res);
    return true;
  };

  // Files with a known extension that are missing → 404 (prevents flutter_service_worker.js
  // and manifest.json from returning index.html which breaks the service worker install).
  // Dotfiles (.env) have ext '' — they're served by tryServe above or fall through to index.html.
  if (!tryServe(filePath)) {
    const ext = path.extname(urlPath);
    if (ext && ext !== '.html') {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not found');
    } else {
      const indexPath = path.join(ROOT, 'index.html');
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      fs.createReadStream(indexPath).pipe(res);
    }
  }
}).listen(PORT, () => {
  console.log(`Serving build/web on http://localhost:${PORT}`);
});
