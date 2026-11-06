// Atelier click test "hpref" (scripts/atelier/clicks/README.md): the job's HP reference in the stats optimizer
// (stat_enh.js hpRefRule / hpRefView, SPEC repere-hp-par-job-2026-11-06). On Tetsouo's BRD: no rule at first, then
// Ceiling (the sets between the Fast Cast - 100 and it), Floor (never under it), another set as the reference, the
// choice kept in the browser; PLD keeps its Ceiling. Prints each set's HP bounds, then "errors [...]", the page's errors.
// PAGE_URL: the page to open; else data/atelier/index.html.
//
// @file    scripts/atelier/clicks/hpref_clicks.js
// @author  ejouanchicot
const path = require('path');
const lib = require(path.join(__dirname, '../lib/browser.js'));
(async () => {
  const browser = await lib.puppeteer.launch({executablePath: lib.CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 900});
  page.on('pageerror', e => errs.push(e.message));
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}, boxOpen: {optset: true}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => typeof render === 'function'); await new Promise(r => setTimeout(r, 4000));
  const wait = ms => new Promise(r => setTimeout(r, ms)), out = [];
  const click = sel => page.evaluate(sel => { const b = document.querySelector(sel); if (b) b.click(); return !!b; }, sel);
  const pick = v => page.evaluate(v => { const s = document.querySelector('[data-hpref-set]'); if (!s) return false; s.value = v; s.dispatchEvent(new Event('change', {bubbles: true})); return true; }, v);
  const bounds = () => page.evaluate(() => ['sets.idle', 'sets.precast.FC', 'sets.midcast.Minuet'].map(p => { const s = data().sets.find(x => x.path === p); if (!s) return p + ' -';
    const f = statOpts(s).floor; return `${p.replace('sets.', '')} ${f.hp || 0}-${f.hpMax || 0}`; }).join(' · ')
    + ' | row "' + (((document.querySelector('.ophpref [aria-pressed="true"]')) || {}).textContent || 'none') + '" set menu ' + !!document.querySelector('[data-hpref-set]'));
  await page.evaluate(async () => { S.motion = false; S.char = 'Tetsouo'; S.job = 'BRD'; S.section = 'sets'; render(); await new Promise(r => setTimeout(r, 2000));
    const s = data().sets.find(x => x.path === 'sets.midcast.Minuet'); S.selPath = Object.assign({}, S.selPath, {BRD: s.path}); S.optView = optViewKey(s); render(); });
  await wait(500); out.push('BRD at first: ' + await bounds());
  await click('[data-hpref-rule="ceil"]'); await wait(400); out.push('ceiling: ' + await bounds());
  await click('[data-hpref-rule="floor"]'); await wait(400); out.push('floor: ' + await bounds());
  await pick('sets.idle'); await wait(400); out.push('floor on sets.idle: ' + await bounds());
  await click('[data-hpref-rule="ceil"]'); await pick(''); await wait(400); out.push('ceiling, Fast Cast: ' + await bounds());
  out.push('kept: ' + await page.evaluate(() => JSON.stringify((JSON.parse(localStorage.getItem('atelier') || '{}').hpRefBy || {})['Tetsouo/BRD'])));
  await page.evaluate(() => { S.job = 'PLD'; render(); }); await wait(1500);
  out.push('PLD: ' + await page.evaluate(() => JSON.stringify(hpRefRule())));
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
