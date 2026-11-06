// Atelier click test "tankx" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}, boxOpen: {figtab: 'summary'}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  await page.evaluate(() => { S.motion = false; S.boxOpen = Object.assign({}, S.boxOpen, {tank: true}); S.char = 'Tetsouo'; S.job = 'PLD'; S.section = 'sets'; render(); }); await page.evaluate(() => new Promise(r => loadRanked(r))); await wait(500);
  // the tanking figures: the Summary's first section (Défense), its box's lines then what the set is after there
  const box = () => page.evaluate(() => { const b = document.querySelector('.globalcol .figsum .figsec'); if (!b) return 'none';
    const f = b.querySelector('[data-fold]'); return (b.querySelector('.figlead') || {}).textContent + ': ' + [...b.querySelectorAll('li')].map(l => l.textContent + '{' + (l.title || '').slice(0, 25) + '}').join(' | ') + ' open ' + (f ? f.getAttribute('aria-expanded') : 'tab'); });
  for (const j of ['PLD', 'RUN']) {
    const n = await page.evaluate(j => { S.job = j; render(); return S._cards.length; }, j); await wait(300);
    for (let i = 0; i < n; i += Math.max(1, Math.floor(n / 10))) { await page.evaluate(i => { S.sel[S.job] = i; render(); }, i); await wait(250); out.push(`${j} ${i}: ` + await box()); }
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
