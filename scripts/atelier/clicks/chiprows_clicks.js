// Atelier click test "chiprows" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
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
  const edits = () => page.evaluate(() => { const e = (S._modEdits || {})[S.char] || {}; return Object.entries(e).map(([f, x]) => f.split('/').pop() + ':' + Object.entries(x).map(([k, v]) => k + '=' + JSON.stringify(v.v).slice(0, 80)).join(',')).filter(s => !s.endsWith(':')).join(' | '); });
  const counts = () => page.evaluate(() => `chips ${document.querySelectorAll('#view .modchip').length} drag ${document.querySelectorAll('#view .modchip[draggable="true"]').length} add ${[...document.querySelectorAll('#view .modaddbtn, #view .modin.add')].map(b => b.textContent || b.placeholder).join(',')} rows ${document.querySelectorAll('#view .mrtbl tbody tr').length} cells ${document.querySelectorAll('#view .mrtbl [data-rowcell]').length} off ${document.querySelectorAll('#view .mract button[disabled]').length} lists ${document.querySelectorAll('#mrgear').length}`);
  // what each family shows (the page of 2026-11-14): every family has chips to remove; the
  // bag buttons (data-modaddv) only on the bag lists of refill / wardrobe (one page: REFILL_CONFIG and its neighbours);
  // tables (data-rowdown) there and in "job" (the TP Bonus pieces, the weaponskill slots); a table's "+ add a line"
  // (data-rowadd) only in "job": the refill tables add their line through the item picker (data-rowpick, since
  // 2026-10-11). A button the family has must be there; one it has not is not clicked.
  const HAS = {refill: ['moddel', 'modaddv', 'rowdown'], wardrobe: ['moddel', 'modaddv', 'rowdown'], job: ['moddel', 'rowdown', 'rowadd']};
  const click = (fam, what) => page.evaluate((sel, must) => { const b = document.querySelector(sel); if (b) b.click(); else if (must) setTimeout(() => { throw new Error('missing button ' + sel); }); },
    `#view [data-${what}]:not([disabled])`, (HAS[fam] || ['moddel']).includes(what));
  for (const fam of ['refill', 'cleanse', 'buff', 'job', 'automed', 'dualbox', 'wardrobe']) {
    await page.evaluate(fam => { closeOverlay(); S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'jobcfg'; S.jobTab = 'modules'; S.modView = 'simple'; S.modFam = fam; S.modFile = null; S._modEdits = {};
      S._live = Object.assign({}, S._live, {Tetsouo: Object.assign({}, S._live.Tetsouo, {ok: true, write: true})}); render(); }, fam); await wait(300);
    out.push(fam + ': ' + await counts());
    await click(fam, 'moddel'); await wait(250);
    await click(fam, 'modaddv'); await wait(250);
    const inp = await page.evaluate(() => { const i = document.querySelector('#view .modin.add:not([disabled])'); if (i) i.focus(); return !!i; });
    if (inp) { await page.keyboard.type('Test', {delay: 20}); await page.keyboard.press('Enter'); await wait(300); }
    await click(fam, 'rowdown'); await wait(250);
    await click(fam, 'rowadd'); await wait(250);
    const cell = await page.evaluate(() => { const i = document.querySelector('#view .mrtbl input.modin.num[data-rowcell]:not([disabled])'); if (i) i.focus(); return !!i; });
    if (cell) { await page.keyboard.type('3', {delay: 20}); await page.keyboard.press('Tab'); await wait(300); }
    await page.evaluate(() => { const s = document.querySelector('#view .mrtbl select[data-rowcell]'); if (s) { s.value = s.options[s.options.length - 1].value; s.dispatchEvent(new Event('change', {bubbles: true})); } }); await wait(250);
    out.push('  edits: ' + await edits() + ' | ' + await counts() + ' overlay ' + await page.evaluate(() => !document.querySelector('#overlay').hidden));
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
