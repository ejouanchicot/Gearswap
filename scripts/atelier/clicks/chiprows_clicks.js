// Atelier click test "chiprows" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const edits = () => page.evaluate(() => { const e = (S._modEdits || {})[S.char] || {}; return Object.entries(e).map(([f, x]) => f.split('/').pop() + ':' + Object.entries(x).map(([k, v]) => k + '=' + JSON.stringify(v.v).slice(0, 80)).join(',')).filter(s => !s.endsWith(':')).join(' | '); });
  const counts = () => page.evaluate(() => `chips ${document.querySelectorAll('#view .modchip').length} drag ${document.querySelectorAll('#view .modchip[draggable="true"]').length} add ${[...document.querySelectorAll('#view .modaddbtn, #view .modin.add')].map(b => b.textContent || b.placeholder).join(',')} rows ${document.querySelectorAll('#view .mrtbl tbody tr').length} cells ${document.querySelectorAll('#view .mrtbl [data-rowcell]').length} off ${document.querySelectorAll('#view .mract button[disabled]').length} lists ${document.querySelectorAll('#mrgear').length}`);
  for (const fam of ['refill', 'cleanse', 'buff', 'job', 'automed', 'dualbox', 'wardrobe']) {
    await page.evaluate(fam => { closeOverlay(); S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'jobcfg'; S.jobTab = 'modules'; S.modView = 'simple'; S.modFam = fam; S.modFile = null; S._modEdits = {};
      S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }, fam); await wait(300);
    out.push(fam + ': ' + await counts());
    await page.evaluate(() => { const b = document.querySelector('#view [data-moddel]:not([disabled])'); if (b) b.click(); }); await wait(250);
    await page.evaluate(() => { const b = document.querySelector('#view [data-modaddv]:not([disabled])'); if (b) b.click(); }); await wait(250);
    const inp = await page.evaluate(() => { const i = document.querySelector('#view .modin.add:not([disabled])'); if (i) i.focus(); return !!i; });
    if (inp) { await page.keyboard.type('Test', {delay: 20}); await page.keyboard.press('Enter'); await wait(300); }
    await page.evaluate(() => { const b = document.querySelector('#view [data-rowdown]:not([disabled])'); if (b) b.click(); }); await wait(250);
    await page.evaluate(() => { const b = document.querySelector('#view [data-rowadd]:not([disabled])'); if (b) b.click(); }); await wait(250);
    const cell = await page.evaluate(() => { const i = document.querySelector('#view .mrtbl input.modin.num[data-rowcell]:not([disabled])'); if (i) i.focus(); return !!i; });
    if (cell) { await page.keyboard.type('3', {delay: 20}); await page.keyboard.press('Tab'); await wait(300); }
    await page.evaluate(() => { const s = document.querySelector('#view .mrtbl select[data-rowcell]'); if (s) { s.value = s.options[s.options.length - 1].value; s.dispatchEvent(new Event('change', {bubbles: true})); } }); await wait(250);
    out.push('  edits: ' + await edits() + ' | ' + await counts() + ' overlay ' + await page.evaluate(() => !document.querySelector('#overlay').hidden));
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
