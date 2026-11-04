// Atelier click test "opt" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(path.join(__dirname, '../lib/browser.js')).puppeteer;
(async () => {
  const browser = await puppeteer.launch({executablePath: require(path.join(__dirname, '../lib/browser.js')).CHROME, headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}, boxOpen: {optset: true, optobjs: true}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  // the optimizer's tab (OptPage.svelte data-opview): the figures in detail, the search's settings
  await page.evaluate(() => { window.VIEW = v => { S._opView = v; render(); }; });
  const step = async (label, fn, check, ms = 300) => { try { await page.evaluate(fn); await wait(ms); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.BIG = () => (document.querySelector(':is(.oppage, .optcolumn) .opval b') || {}).textContent; window.OBJ = () => { const x = document.querySelector(':is(.oppage, .optcolumn) .opobjsel'); return x ? x.options[x.selectedIndex].text : (document.querySelector(':is(.oppage, .optcolumn) .opobjone') || {}).textContent; };
    window.CHG = (sel, v) => { const s = document.querySelector(sel); s.value = v; s.dispatchEvent(new Event('change', {bubbles: true})); s.dispatchEvent(new Event('input', {bubbles: true})); }; });
  await step('open the optimizer on a WS set', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); const s = data().sets.find(x => family(x.path, x.pieces) === 'ws' && wsOfSet(x)); S.selPath[S.job] = s.path; render(); document.querySelector('.detail [data-optview]').click(); VIEW('detail'); },
    () => 'page ' + !!document.querySelector(':is(.oppage, .optcolumn)') + ', obj ' + OBJ() + ', big ' + BIG());
  await step('objective: average', () => CHG(':is(.oppage, .optcolumn) .opobjsel', 'damage_avg'), () => 'obj ' + OBJ() + ', S ' + S.optOpts.obj + ', range fields ' + document.querySelectorAll(':is(.oppage, .optcolumn) [data-optopt="tpFrom"],:is(.oppage, .optcolumn) [data-optopt="tpTo"]').length + ', band ' + (VIEW('detail'), !!document.querySelector(':is(.oppage, .optcolumn) .opcurve rect.band')) + (VIEW('detail'), ''));
  await step('range 2000', () => CHG(':is(.oppage, .optcolumn) [data-optopt="tpFrom"]', '2000'), () => 'tpFrom ' + S.optOpts.tpFrom + ', field ' + document.querySelector(':is(.oppage, .optcolumn) [data-optopt="tpFrom"]').value);
  await step('objective: at a TP', () => CHG(':is(.oppage, .optcolumn) .opobjsel', 'damage'), () => 'obj ' + OBJ() + ', tp field ' + !!document.querySelector(':is(.oppage, .optcolumn) .tpin'));
  await step('TP 2000', () => CHG(':is(.oppage, .optcolumn) .tpin', '2000'), () => 'wsTp ' + S.wsTp + ', big ' + BIG() + ', mark ' + (VIEW('detail'), !!document.querySelector(':is(.oppage, .optcolumn) .opcurve line.mark')) + (VIEW('detail'), ''));
  await step('limit DT+PDT -40', () => CHG(':is(.oppage, .optcolumn) [data-optopt="pdt"]', '-40'), () => 'pdt ' + S.optOpts.pdt + ', row ' + (VIEW('detail'), [...document.querySelectorAll(':is(.oppage, .optcolumn) .optable th')].map(x => x.textContent).find(x => /PDT/.test(x))) + (VIEW('detail'), ''));
  await step('help', () => document.querySelector(':is(.oppage, .optcolumn) [data-help="optpage"]').click(), () => 'help ' + !!document.querySelector(':is(.oppage, .optcolumn) .wshelp'));
  await step('search tab Calcul', () => document.querySelector(':is(.oppage, .optcolumn) [data-opview="calc"]').click(), () => 'tab ' + S._opTab + ', menu ' + !!document.querySelector(':is(.oppage, .optcolumn) .optab select[data-optopt="search"]'));
  await step('special tab, Hoxne', () => { document.querySelector(':is(.oppage, .optcolumn) [data-opview="special"]').click(); setTimeout(() => document.querySelector(':is(.oppage, .optcolumn) [data-optopt="hoxne"]').click(), 50); }, () => 'hoxne ' + S.optOpts.hoxne + ', count ' + ((document.querySelector(':is(.oppage, .optcolumn) [data-optab="special"] .opon') || {}).textContent || '-'));
  await step('start a search', () => document.querySelector(':is(.oppage, .optcolumn) .optgo').click(), () => 'busy ' + !!S._optBusy + ', run window ' + !!document.querySelector('.optrun') + ', stop btn ' + !!document.querySelector('[data-optstop]'), 2500);
  await step('stop it', () => { const b = document.querySelector('[data-optstop], .optrun [data-close]'); if (b) b.click(); }, () => 'busy ' + !!S._optBusy, 1500);
  await step('close leftovers', () => { if (!document.querySelector('#overlay').hidden) document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})); }, () => 'overlay hidden ' + document.querySelector('#overlay').hidden + ', page ' + !!document.querySelector(':is(.oppage, .optcolumn)'));
  await step('back to the set', () => document.querySelector(':is(.oppage, .optcolumn) [data-optback]').click(), () => 'page ' + !!document.querySelector(':is(.oppage, .optcolumn)') + ', card ' + !!document.querySelector('.detail .slots'));
  await step('engaged set, objectives', () => { const s = data().sets.find(x => family(x.path, x.pieces) === 'engaged'); S.selPath[S.job] = s.path; render(); document.querySelector('.detail [data-optview]').click(); VIEW('detail'); setTimeout(() => CHG(':is(.oppage, .optcolumn) .opobjsel', 'dps'), 80); },
    () => 'obj ' + OBJ() + ', factors ' + (VIEW('detail'), !!document.querySelector(':is(.oppage, .optcolumn) .opfac')) + (VIEW('detail'), '') + ', engAt field ' + !!document.querySelector(':is(.oppage, .optcolumn) [data-optopt="engAt"]'));
  await step('objective tp_real, TP 1500', () => { CHG(':is(.oppage, .optcolumn) .opobjsel', 'tp_real'); setTimeout(() => CHG(':is(.oppage, .optcolumn) [data-optopt="engAt"]', '1500'), 80); }, () => 'engAt ' + S.optOpts.engAt + ', rounds bar ' + (VIEW('detail'), document.querySelectorAll(':is(.oppage, .optcolumn) .cycbar.tall i').length) + (VIEW('detail'), ''));
  await step('nuke set, spells', () => { S.job = 'BLM'; render(); const s = data().sets.find(x => isNukeSet(x.path)); S.selPath[S.job] = s.path; S.optView = optViewKey(s); VIEW('detail'); const sel = document.querySelector(':is(.oppage, .optcolumn) [data-nukespells]'); [...sel.options].slice(0, 3).forEach(o => o.selected = true); sel.dispatchEvent(new Event('change', {bubbles: true})); },
    () => 'spells ' + JSON.stringify((S.optOpts.nukeSpells || {})).slice(0, 90) + ', big ' + BIG());
  await step('stats set', () => { S.job = 'PLD'; render(); const s = data().sets.find(x => family(x.path, x.pieces) === 'idle'); S.selPath[S.job] = s.path; S.optView = optViewKey(s); render(); }, () => 'page ' + !!document.querySelector(':is(.oppage, .optcolumn)') + ', stat objectives ' + document.querySelectorAll(':is(.oppage, .optcolumn) [data-statobj]').length);
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
