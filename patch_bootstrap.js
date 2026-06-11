const fs = require('fs');
const file = 'build/web/flutter_bootstrap.js';
let c = fs.readFileSync(file, 'utf8');
if (c.includes('"useLocalCanvasKit":true')) {
  console.log('Already patched');
} else {
  c = c.replace(/"engineRevision":"([^"]+)"/, '"engineRevision":"$1","useLocalCanvasKit":true');
  fs.writeFileSync(file, c);
  console.log('Patched. Has useLocalCanvasKit:', c.includes('"useLocalCanvasKit":true'));
}
