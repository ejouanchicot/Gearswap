// Atelier click test "simple" (scripts/atelier/clicks/README.md): the Sets page's Simple view (sets_simple.js, SPEC
// page-sets-simple-2026-11-05). Switched on from the Settings, then on a set: its tiles and weapons (as icons) beside
// the equipment, not in the head; the code folded and opened, the missing
// pieces' line opened, the minimums at 0 folded then shown, a stats search whose result shows only once it tried
// pieces (before -> after), and back to the detailed view from the set's menu. Prints what a player would read there,
// then "errors [...]", the page's errors. PAGE_URL: the page to open; else data/atelier/index.html.
//
// @file    scripts/atelier/clicks/simple_clicks.js
// @author  ejouanchicot
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}, boxOpen: {optset: true}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const click = sel => page.evaluate(sel => { const b = document.querySelector(sel); if (b) b.click(); return !!b; }, sel);
  const card = () => page.evaluate(() => { const a = document.querySelector('article.detail'), c = document.querySelector('.optcolumn');
    const shown = el => !!el && el.checkVisibility();
    return `simple ${!!a && a.classList.contains('simple')} · beside the equipment: tiles ${a ? a.querySelectorAll('.simpleside .tile').length : 0}, weapon icons ${a ? a.querySelectorAll('.simpleside .wtag.wico').length : 0}, in the head ${a ? a.querySelectorAll('header .hboxes, header .setctl').length : 0} · code shown ${shown(a && a.querySelector('.setlua'))}`
      + ` · missing "${((a && a.querySelector('.holdfold summary')) || {}).textContent || ''}" open ${!!(a && a.querySelector('.holdfold[open]'))}`
      + ` · minimums [${c ? [...c.querySelectorAll('.oplim .oplimn')].map(x => x.textContent).join(', ') : ''}] link "${((c && c.querySelector('[data-limopen]')) || {}).textContent || ''}"`
      + ` · result ${c ? [...c.querySelectorAll('.optable thead th')].map(x => x.textContent).join('|') || 'none' : 'no column'}`; });

  // the Settings: the Simple view on
  await page.evaluate(() => { S.motion = false; S.char = 'Tetsouo'; S.job = 'WHM'; S.section = 'sets'; S._cfg = true; render(); }); await wait(300);
  out.push('settings: ' + await page.evaluate(() => [...document.querySelectorAll('[data-setsview-set]')].map(b => b.textContent + (b.getAttribute('aria-pressed') === 'true' ? '*' : '')).join(' / ')));
  await click('[data-setsview-set="simple"]'); await wait(300);
  out.push('kept: ' + await page.evaluate(() => S.setsView + ' ' + JSON.parse(localStorage.getItem('atelier') || '{}').setsView));
  // a Cure set with pieces you do not have, its optimizer open
  await page.evaluate(() => { S._cfg = false; const s = data().sets.find(x => x.path === 'sets.midcast.Cure'); S.selPath = Object.assign({}, S.selPath, {WHM: s.path}); S.optView = optViewKey(s); render(); }); await wait(600);
  out.push('cure: ' + await card());
  await click('article.detail .luafold > summary'); await wait(200); out.push('code: ' + await card());
  await click('article.detail .holdfold > summary'); await wait(200); out.push('missing: ' + await card());
  await click('.optcolumn [data-limopen]'); await wait(300); out.push('minimums: ' + await card());
  await click('.optcolumn [data-limopen]'); await wait(300); out.push('folded: ' + await card());
  // a search: its result only once it tried pieces
  await click('.optcolumn [data-optstat="better"], .optcolumn [data-optstat]:not([data-optstat="best"])'); await wait(500);
  await page.waitForFunction(() => !S._optBusy, {timeout: 180000}).catch(() => out.push('search: timed out'));
  await wait(800); out.push('searched: ' + await card());
  // the set's menu: back to the detailed view
  await page.evaluate(() => { const d = document.querySelector('article.detail .setmore'); if (d) d.open = true; }); await wait(100);
  await click('article.detail .setmenu [data-setsview-set]'); await wait(400);
  out.push('detailed: ' + await card() + ' · menu now "' + await page.evaluate(() => { const d = document.querySelector('article.detail .setmore'); if (d) d.open = true; return ((document.querySelector('article.detail .setmenu [data-setsview-set]')) || {}).textContent; }) + '"');
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
