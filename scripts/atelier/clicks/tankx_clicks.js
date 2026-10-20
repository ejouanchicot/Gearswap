// Atelier click test "tankx" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  await page.evaluate(() => { S.motion = false; S.boxOpen = Object.assign({}, S.boxOpen, {tank: true}); S.char = 'Tetsouo'; S.job = 'PLD'; S.section = 'sets'; render(); }); await page.evaluate(() => new Promise(r => loadRanked(r))); await wait(500);
  const box = () => page.evaluate(() => { const b = document.querySelector('.ui2own .box.g-tank'); if (!b) return 'none'; return [...b.querySelectorAll('li')].map(l => l.textContent + '{' + (l.title || '').slice(0, 25) + '}').join(' | ') + ' open ' + b.querySelector('[data-fold]').getAttribute('aria-expanded'); });
  for (const j of ['PLD', 'RUN']) {
    const n = await page.evaluate(j => { S.job = j; render(); return S._cards.length; }, j); await wait(300);
    for (let i = 0; i < n; i += Math.max(1, Math.floor(n / 10))) { await page.evaluate(i => { S.sel[S.job] = i; render(); }, i); await wait(250); out.push(`${j} ${i}: ` + await box()); }
  }
  await page.evaluate(() => { const b = document.querySelector('.ui2own .box.g-tank [data-fold]'); if (b) b.click(); }); await wait(300); out.push('opened: ' + await box());
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
