// Atelier click test "search" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}, boxOpen: {optset: true, optobjs: true}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = {push: x => console.log(x), join: () => ''}, wait = ms => new Promise(r => setTimeout(r, ms));
  await page.evaluate(() => { S.motion = false; S.char = 'Tetsouo'; S.job = 'PLD'; S.section = 'sets'; render(); }); await page.evaluate(() => new Promise(r => loadRanked(r))); await wait(400);
  // the tabs: the right column's (data-rtab, sets/rtabs.ts, since 2026-11-11), the search block's own hidden there
  const read = () => page.evaluate(() => { const box = document.querySelector(':is(.oppage, .optcolumn)'); if (!box) return 'none';
    const tabs = [...document.querySelectorAll('[data-rtab]')];
    return tabs.map(b => b.querySelector('b').textContent + (b.getAttribute('aria-selected') === 'true' ? '*' : '')).join(',') + ' | menu ' + ((box.querySelector('.opsels select') || {}).value) +
      ' | sw ' + [...box.querySelectorAll('.opsw')].map(l => l.textContent + (l.querySelector('input').checked ? '+' : '') + (l.querySelector('input').disabled ? '-' : '') + '{' + (l.title || '').slice(0, 15) + '}').join(',') +
      ' | locks ' + [...box.querySelectorAll('.oplocks')].map(p => p.textContent).join(' / ') + ' | opts ' + JSON.stringify(S.optOpts); });
  const open = (j, fam) => page.evaluate((j, fam) => { S.job = j; S.section = 'sets'; render(); const s = (data().sets || []).find(x => family(x.path, x.pieces) === fam && (fam === 'ws' ? !!wsOfSet(x) : statSet(x))); S.selPath = Object.assign({}, S.selPath, {[S.job]: s.path}); S.optView = optViewKey(s); render(); return s.path; }, j, fam);
  for (const [j, fam] of [['PLD', 'ws'], ['PLD', 'idle']]) {
    out.push(j + ' ' + await open(j, fam)); await wait(400); out.push('  page: ' + await page.evaluate(() => !!document.querySelector(':is(.oppage, .optcolumn)') + ' tabs ' + document.querySelectorAll('[data-rtab]').length + ' view ' + S.optView));
    await page.evaluate(() => { const s = ui2CurrentSet(data()); toggleLock(s, 'head'); toggleLock(s, 'neck'); S.excluded = {}; render(); }); await wait(300);
    out.push('  start: ' + await read());
    for (const tab of ['pieces', 'calc', 'special']) {
      await page.evaluate(tab => document.querySelector(`[data-rtab="${tab}"]`).click(), tab); await wait(300);
      await page.evaluate(() => { const s = document.querySelector(':is(.oppage, .optcolumn) .opsels select'); if (s) { s.value = s.options[s.options.length - 1].value; s.dispatchEvent(new Event('change', {bubbles: true})); } }); await wait(300);
      const n = await page.evaluate(() => document.querySelectorAll(':is(.oppage, .optcolumn) .opsw input:not([disabled])').length);
      for (let i = 0; i < n; i++) { await page.evaluate(i => document.querySelectorAll(':is(.oppage, .optcolumn) .opsw input:not([disabled])')[i].click(), i); await wait(250); }
      out.push(`  tab ${tab}: ` + await read());
    }
    await page.evaluate(() => document.querySelector('[data-rtab="pieces"]').click()); await wait(300);
    await page.evaluate(() => { const b = document.querySelector(':is(.oppage, .optcolumn) [data-locksclear]'); if (b) b.click(); }); await wait(300);
    out.push('  unlocked: ' + await read());
  }
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
