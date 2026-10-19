// GearSwap Atelier · the pixel check of a change to the page (for the project, never shipped to players): the page as
// it was (a git commit, HEAD by default) and the page as it is now, opened side by side in Chrome, set to the same
// views, captured at several widths and compared pixel by pixel.
//   node scripts/atelier/page_parity.js <views.json> [--ref HEAD] [--widths 1600,1280,390] [--only text] [--out DIR] [--dom]
// --dom: for a view that differs, also the page's HTML of both (#view, without Svelte's comment marks), to diff
// views.json (scripts/atelier/parity/*.json): [[name, {char, job, section, cfg, tab, set: {S fields}, code: "js", after: "js"}], ...]
//
// Nothing in the working tree is swapped: a small server gives each page its files, the commit's version of every
// file changed since it to the old page, the disk's to the new one. Every other file (the exports, the characters'
// files) is read once and kept for the whole run, so both pages see the same data even while the game writes
// new exports. The two pages have their own address, so their saved state (localStorage) never mixes.
// A view is captured once the page asks for nothing more and has drawn twice; the views that differ are saved as
// <out>/<width>_<name>.old.png / .new.png. Same needs as atelier_test.js (Puppeteer, Chrome).
//
// @file    scripts/atelier/page_parity.js
// @author  ejouanchicot
const path = require('path'), fs = require('fs'), http = require('http'), os = require('os');
const {execFileSync} = require('child_process');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
const CHROME = process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const DATA = path.resolve(__dirname, '../..');
const arg = (k, d) => { const i = process.argv.indexOf(k); return i > 0 ? process.argv[i + 1] : d; };
const VIEWS_FILE = process.argv[2], REF = arg('--ref', 'HEAD'), ONLY = arg('--only', null), DOM = process.argv.includes('--dom');
const WIDTHS = arg('--widths', '1600,1280,390').split(',').map(Number);
const OUT = arg('--out', path.join(os.tmpdir(), 'atelier_parity', path.basename(VIEWS_FILE || 'views', '.json')));
const TYPES = {'.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json', '.png': 'image/png',
  '.jpg': 'image/jpeg', '.svg': 'image/svg+xml', '.webp': 'image/webp', '.woff2': 'font/woff2', '.wasm': 'application/wasm', '.lua': 'text/plain'};

const git = args => execFileSync('git', args, {cwd: DATA, maxBuffer: 1 << 28, stdio: ['ignore', 'pipe', 'ignore']});
// the files changed since the commit: the old page gets the commit's version of them (none for a file added since)
// --self: both pages are the page now (what differs then is the check's own noise)
const CHANGED = new Set(process.argv.includes('--self') ? [] : git(['diff', '--name-only', REF]).toString().split('\n').filter(Boolean));
const frozen = new Map(), atRef = new Map();
function fileFor(old, rel) {
  if (old && CHANGED.has(rel)) {
    if (!atRef.has(rel)) { try { atRef.set(rel, git(['show', `${REF}:${rel}`])); } catch (e) { atRef.set(rel, null); } }
    return atRef.get(rel);
  }
  if (!frozen.has(rel)) { try { frozen.set(rel, fs.readFileSync(path.join(DATA, rel))); } catch (e) { frozen.set(rel, null); } }
  return frozen.get(rel);
}

// one server a page: how many of its requests are still running, and when the last one ended
function serve(old) {
  const st = {busy: 0, last: Date.now()};
  st.server = http.createServer((req, res) => {
    st.busy++;
    const rel = decodeURIComponent(req.url.split('?')[0]).replace(/^\/+/, ''), body = fileFor(old, rel);
    if (body) res.writeHead(200, {'Content-Type': TYPES[path.extname(rel).toLowerCase()] || 'application/octet-stream', 'Cache-Control': 'no-store'});
    else res.writeHead(404);
    res.end(body || undefined, () => { st.busy--; st.last = Date.now(); });
  });
  return new Promise(done => st.server.listen(0, '127.0.0.1', () => { st.port = st.server.address().port; done(st); }));
}

const wait = ms => new Promise(r => setTimeout(r, ms));
// drawn: nothing asked for 150 ms, the animations ended, two frames drawn, every picture in
async function settle(page, st) {
  const end = Date.now() + 15000;
  while (Date.now() < end && (st.busy || Date.now() - st.last < 150)) await wait(25);
  // the animations the page starts itself (motion.js element.animate: no CSS rule stops them) are run to their end
  await page.evaluate(() => document.getAnimations().forEach(a => { try { a.finish(); } catch (e) { a.cancel(); } }));
  // the fonts too (a text drawn before its font came is drawn again, a pixel aside)
  await page.evaluate(() => document.fonts.ready);
  await page.evaluate(() => new Promise(done => requestAnimationFrame(() => requestAnimationFrame(() =>
    Promise.all([...document.images].filter(i => !i.complete).map(i => new Promise(r => { i.onload = i.onerror = r; }))).then(done)))));
}

// the page's state set from a view, as the old snapshots did (scripts/atelier/parity/*.json)
function applyView(v) {
  S.guide = Object.assign({}, S.guide, {done: true, off: true}); S.motion = false;
  S.char = v.char; S.job = v.job; S.section = v.section; S._cfg = !!v.cfg; S._pkg = false; if (v.tab) S.jobTab = v.tab;
  S.keysAll = !!v.keysAll; S.keyDirty = Object.assign({}, S.keyDirty, {[v.char]: !!v.dirty}); S.toast = v.toast || '';
  if (v.alt !== undefined) S.macroAlt = Object.assign({}, S.macroAlt, {[v.char + '|' + v.job]: v.alt});
  if (v.path) S.selPath = Object.assign({}, S.selPath, {[v.job]: v.path});
  S.modView = 'simple'; S.modFam = null; S.modFile = null; S.modQ = ''; S._modEdits = {}; S.modGrp = {};
  // the profiles' picker closed, its search empty, unless the view says otherwise
  S._profOpen = false; S._profQ = ''; S._profTier = ''; S._profEdit = null;
  Object.assign(S, v.set || {});
  if (v.code) (new Function(v.code))();
  render();
  // what a click or a key does after the drawing, on a page that does it then (the old profiles' filter)
  if (v.after) (new Function(v.after))();
}

async function open(browser, st, errs) {
  const page = await browser.newPage();
  page.on('pageerror', e => errs.push(e.message));
  // the guided visit off from the start (guide.js): its Mog comes after a delay, before one capture and after the other
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {});
    try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(`http://127.0.0.1:${st.port}/atelier/index.html`, {waitUntil: 'load'});
  // a page from before Svelte (2026-10-17) has no __atelier: its scripts are its own tags, run by the load
  await page.waitForFunction(() => window.__atelier ? window.__atelier.loaded : typeof render === 'function', {timeout: 60000});
  await page.addStyleTag({content: '*{animation:none!important;transition:none!important;caret-color:transparent!important} .mog,.moogle,[class*=mog]{display:none!important}'});
  await settle(page, st);
  return page;
}

// the whole page out of the layout and back: every block laid out and painted anew
function repaint() {
  const el = document.documentElement;
  el.style.display = 'none';
  void el.offsetHeight;
  el.style.display = '';
  void el.offsetHeight;
}

// the view's HTML, one tag a line, without the comments Svelte leaves as marks
function domOf() {
  // then the blocks scrolled (a page the same but scrolled differently differs too)
  const scrolled = [...document.querySelectorAll('*')].filter(e => e.scrollTop || e.scrollLeft)
    .map(e => `scrolled ${e.tagName.toLowerCase()}.${[...e.classList].join('.')} ${e.scrollTop},${e.scrollLeft}`);
  return document.getElementById('view').innerHTML.replace(/<!--[\s\S]*?-->/g, '').replace(/>\s+</g, '><').replace(/></g, '>\n<') +
    '\n' + [`window scrolled ${scrollX},${scrollY}`].concat(scrolled).join('\n') +
    // where each block of the window stands, to the hundredth of a pixel (the same HTML can stand half a pixel apart)
    '\n' + [...document.querySelectorAll('#view *')].map(e => [e, e.getBoundingClientRect()]).filter(([, r]) => r.height && r.top < innerHeight && r.bottom > 0)
      .map(([e, r]) => `at ${e.tagName.toLowerCase()}.${[...e.classList].join('.')} ${r.left.toFixed(2)},${r.top.toFixed(2)} ${r.width.toFixed(2)}x${r.height.toFixed(2)}`).join('\n');
}

// in a blank page: how many pixels differ between two captures, and the box around them
function compare(a, b) {
  const load = src => new Promise(done => { const im = new Image(); im.onload = () => done(im); im.src = 'data:image/png;base64,' + src; });
  return Promise.all([load(a), load(b)]).then(([x, y]) => {
    if (x.width !== y.width || x.height !== y.height) return `size ${x.width}x${x.height} vs ${y.width}x${y.height}`;
    const c = document.createElement('canvas'); c.width = x.width; c.height = x.height; const g = c.getContext('2d');
    g.drawImage(x, 0, 0); const d1 = g.getImageData(0, 0, c.width, c.height).data; g.clearRect(0, 0, c.width, c.height);
    g.drawImage(y, 0, 0); const d2 = g.getImageData(0, 0, c.width, c.height).data;
    let n = 0, x0 = 1e9, y0 = 1e9, x1 = -1, y1 = -1;
    for (let i = 0; i < d1.length; i += 4) if (Math.abs(d1[i] - d2[i]) + Math.abs(d1[i + 1] - d2[i + 1]) + Math.abs(d1[i + 2] - d2[i + 2]) > 30) {
      n++; const p = i / 4, px = p % c.width, py = Math.floor(p / c.width);
      x0 = Math.min(x0, px); y0 = Math.min(y0, py); x1 = Math.max(x1, px); y1 = Math.max(y1, py);
    }
    return n ? `${n} px differ in ${x0},${y0} - ${x1},${y1}` : '';
  });
}

(async () => {
  if (!VIEWS_FILE) { console.log('usage: node scripts/atelier/page_parity.js <views.json> [--ref HEAD] [--widths 1600,1280,390] [--only text] [--out DIR]'); process.exit(2); }
  const views = JSON.parse(fs.readFileSync(VIEWS_FILE, 'utf8')).filter(([name]) => !ONLY || name.includes(ONLY));
  const started = Date.now(), errs = {old: [], now: []};
  const [so, sn] = await Promise.all([serve(true), serve(false)]);
  // a Chrome each: a page behind another one in the same Chrome is not drawn (no frame comes)
  const launch = () => puppeteer.launch({executablePath: CHROME, headless: 'new'});
  const [bo, bn, bc] = await Promise.all([launch(), launch(), launch()]);
  const [po, pn] = await Promise.all([open(bo, so, errs.old), open(bn, sn, errs.now)]);
  const blank = await bc.newPage();
  const bad = []; let n = 0;
  fs.mkdirSync(OUT, {recursive: true});
  for (const w of WIDTHS) {
    await Promise.all([po.setViewport({width: w, height: 1000}), pn.setViewport({width: w, height: 1000})]);
    for (const [name, v] of views) {
      await Promise.all([po.evaluate(applyView, v), pn.evaluate(applyView, v)]);
      await Promise.all([settle(po, so), settle(pn, sn)]);
      let [a, b] = await Promise.all([po.screenshot({encoding: 'base64'}), pn.screenshot({encoding: 'base64'})]);
      let r = await blank.evaluate(compare, a, b); n++;
      if (r) {
        // Chrome can paint a block it kept from the drawing before half a pixel off one drawn anew (the old page
        // rebuilds its HTML at each drawing, Svelte keeps it): both pages laid out and painted from scratch, then again
        await Promise.all([po, pn].map(p => p.evaluate(repaint)));
        await Promise.all([settle(po, so), settle(pn, sn)]);
        [a, b] = await Promise.all([po.screenshot({encoding: 'base64'}), pn.screenshot({encoding: 'base64'})]);
        r = await blank.evaluate(compare, a, b);
      }
      if (r) {
        bad.push(`${w}_${name}`.padEnd(32) + ' ' + r);
        fs.writeFileSync(path.join(OUT, `${w}_${name}.old.png`), Buffer.from(a, 'base64'));
        fs.writeFileSync(path.join(OUT, `${w}_${name}.new.png`), Buffer.from(b, 'base64'));
        if (DOM) for (const [p, k] of [[po, 'old'], [pn, 'new']]) fs.writeFileSync(path.join(OUT, `${w}_${name}.${k}.html`), await p.evaluate(domOf));
      }
    }
  }
  await Promise.all([bo.close(), bn.close(), bc.close()]); so.server.close(); sn.server.close();
  for (const line of bad) console.log(line);
  console.log(`${n - bad.length}/${n} identical (${REF} vs now, ${CHANGED.size} file(s) changed, ${((Date.now() - started) / 1000).toFixed(0)} s)` +
    (bad.length ? `; captures in ${OUT}` : ''));
  for (const [k, l] of Object.entries(errs)) if (l.length) console.log(`page errors (${k}):`, [...new Set(l)].slice(0, 5).join(' | '));
  process.exit(bad.length || errs.now.length ? 1 : 0);
})().catch(e => { console.error(e); process.exit(1); });
