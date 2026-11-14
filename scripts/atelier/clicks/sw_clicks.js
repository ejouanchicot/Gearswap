// Atelier click test "sw" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const info = () => page.evaluate(() => `sub ${data().sub} warn ${(document.querySelector('.subwarn') || {}).textContent}`);
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); /* the game on another subjob than the page's (the export's sub moves with the game: SAM since 2026-11) */ const other = data().sub === 'SAM' ? 'DRG' : 'SAM'; S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, job: 'WAR', sub: other})}); render(); }); await wait(300);
  out.push('warn: ' + await info());
  await page.evaluate(() => document.querySelector('[data-subfix]').click()); await wait(400);
  out.push('fixed: ' + await info());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
