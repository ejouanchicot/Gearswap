// GearSwap Atelier · the built page comes from the sources as they are: the hash written into atelier/index.html when
// it was built (meta atelier-build, atelier/vite.config.mts) against the hash of atelier/src/ and the build's files now
// (atelier/build/hash.mjs). A change in src/ without `npm run build` fails here: the page players open would be the
// old one.
//   node scripts/atelier/atelier_build_check.js
//
// @file    scripts/atelier/atelier_build_check.js
// @author  ejouanchicot
const path = require('path'), fs = require('fs'), {pathToFileURL} = require('url');
const ATELIER = path.resolve(__dirname, '../../atelier');

(async () => {
  const {sourcesHash} = await import(pathToFileURL(path.join(ATELIER, 'build/hash.mjs')).href);
  const page = fs.readFileSync(path.join(ATELIER, 'index.html'), 'utf8');
  const m = /<meta name="atelier-build" content="([0-9a-f]+)">/.exec(page), now = sourcesHash();
  if (!m) { console.log('FAILED atelier/index.html is not a built page (no atelier-build mark): run npm run build in atelier/'); process.exit(1); }
  if (m[1] !== now) { console.log(`FAILED atelier/index.html was built from other sources (${m[1]}, now ${now}): run npm run build in atelier/`); process.exit(1); }
  console.log(`ok   atelier/index.html built from the current sources (${now})`);
})();
