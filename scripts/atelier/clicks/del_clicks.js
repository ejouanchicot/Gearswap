// Atelier click test "del" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); const i = S._cards.findIndex(c => c.variants.some(v => deletable(v.set.path) && v.set.path.includes('JA'))); S.sel[S.job] = i; render(); }); await wait(300);
  out.push('btn: ' + await page.evaluate(() => { const b = document.querySelector('[data-setdel]'); return b ? b.disabled + ' ' + b.title + ' ' + b.textContent : 'none'; }));
  await page.evaluate(() => document.querySelector('[data-setdel]').click()); await wait(400);
  out.push('window: ' + await page.evaluate(() => !document.querySelector('#overlay').hidden && (document.querySelector('#overlay .dialog h3') || {}).textContent));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
