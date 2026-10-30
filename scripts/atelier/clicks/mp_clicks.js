// Atelier click test "mp" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
    return `${d.querySelector('h3').textContent} | q "${(document.querySelector('#miq') || {}).value}" focus ${document.activeElement.id} caret ${(document.querySelector('#miq') || {}).selectionStart} h4 ${[...d.querySelectorAll('h4')].map(h => h.textContent).join(' / ')} | tiles ${d.querySelectorAll('.mitile').length} off ${d.querySelectorAll('.mitile[disabled]').length} other ${d.querySelectorAll('.mitile.other').length} p ${[...d.querySelectorAll('.mibody > p')].map(p => p.textContent.slice(0, 30)).join(' / ')}`; });
  const staged = () => page.evaluate(() => JSON.stringify(S.modEdits || S._modEdits || null).slice(0, 200));
  // a family of options (its first file since the one-view Settings, 2026-10-29), or a file by its name
  const go = async (fam, sel, i, q, file) => {
    await page.evaluate((f, file) => { closeOverlay(); S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'jobcfg'; S.jobTab = 'modules'; S.modFam = f;
      S.modFile = file ? (modFiles(data()).find(x => x.file.endsWith('/' + file)) || {}).file || null : null; S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }, fam, file || null); await wait(300);
    await page.evaluate((s, i) => document.querySelectorAll(s)[i].click(), sel, i); await wait(300);
    out.push(`${fam} ${sel} open: ` + await info());
    if (q) { await page.type('#miq', q); await wait(300); out.push(`  typed: ` + await info()); }
    const n = await page.evaluate(() => { const b = document.querySelector('#overlay .mitile:not([disabled])'); if (!b) return 'none'; b.click(); return b.dataset.mipick; }); await wait(300);
    out.push(`  picked ${n}: ` + await info() + ' staged ' + await staged());
  };
  await go('cleanse', '[data-modpick]:not([data-wspick]):not([data-actpick])', 0, 'pot');
  await go('refill', '[data-modpick]:not([data-wspick]):not([data-actpick])', 1);
  await go('buff', '[data-actpick]', 0, 'pro');
  await go('job', '[data-actpick]', 0);
  await go('job', '[data-wspick]', 0, 'bla', 'WAR_WS_CONFIG.lua');
  await go('job', '[data-wspick]', 3, '', 'WAR_WS_CONFIG.lua');
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
