// Atelier click test "as" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const info = () => page.evaluate(() => { const ov = document.querySelector('#overlay'); const d = ov.querySelector('.dialog'); if (!d || ov.hidden) return 'closed';
    return `label ${d.getAttribute('aria-label')} step ${(d.querySelector('.steps .on') || {}).textContent} opts ${d.querySelectorAll('.opt').length} shown ${[...d.querySelectorAll('.opt')].filter(o => !o.hidden && !(o.closest('details') || {}).hidden).length} groups ${d.querySelectorAll('details').length}/${[...d.querySelectorAll('details')].filter(g => g.open).length} focus ${document.activeElement.id} back ${(d.querySelector('[data-back]') || {}).disabled} body ${(d.querySelector('.body').textContent || '').slice(0, 60).replace(/\s+/g, ' ')}`; });
  await page.evaluate(() => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; S._addOpen = {}; S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }); await wait(300);
  await page.evaluate(() => document.querySelector('[data-action="add"]').click()); await wait(300);
  out.push('open: ' + await info());
  await page.evaluate(() => document.querySelector('#overlay [data-addfam="ws"]').click()); await wait(300);
  out.push('ws: ' + await info());
  await page.type('#addq', 'sav'); await wait(300);
  out.push('typed: ' + await info());
  await page.evaluate(() => { const q = document.querySelector('#addq'); q.value = ''; q.dispatchEvent(new Event('input', {bubbles: true})); }); await wait(300);
  const g = await page.evaluate(() => { const d = [...document.querySelectorAll('#overlay details')].find(x => !x.open); if (!d) return 'none'; d.querySelector('summary').click(); return d.dataset.addgroup; }); await wait(300);
  out.push(`opened group ${g}: ` + await info() + ' kept ' + await page.evaluate(() => JSON.stringify(S._addOpen)));
  await page.evaluate(() => document.querySelector('#overlay [data-back]').click()); await wait(300);
  out.push('back: ' + await info());
  await page.evaluate(() => document.querySelector('#overlay [data-addfam="ws"]').click()); await wait(300);
  out.push('ws again: ' + await info());
  const p = await page.evaluate(() => { const b = document.querySelector('#overlay [data-addpick]:not([disabled])'); if (!b) return 'none'; b.click(); return b.dataset.addpick; }); await wait(300);
  out.push(`picked ${p}: ` + await info() + ' from ' + await page.evaluate(() => [...document.querySelectorAll('#overlay [data-addfrom]')].map(b => b.dataset.addfrom).join(',')));
  await page.evaluate(() => document.querySelector('#overlay [data-back]').click()); await wait(300);
  out.push('back: ' + await info());
  const o = await page.evaluate(() => { const b = document.querySelector('#overlay [data-addopen]'); if (!b) return 'none'; b.click(); return b.dataset.addopen; }); await wait(300);
  out.push(`open ${o}: ` + await info() + ' sel ' + await page.evaluate(() => S.sel[S.job]));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
