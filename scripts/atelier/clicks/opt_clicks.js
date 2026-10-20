// Atelier click test "opt" (scripts/atelier/clicks/README.md): clicks through one part of the page and prints
// what a player would read there, then "errors [...]", the page's errors. PAGE_URL: the page to open (a
// page_parity.js --serve address, to compare two versions); else data/atelier/index.html.
const path = require('path');
const puppeteer = require(process.env.PUPPETEER || path.join(process.env.APPDATA || '', 'npm/node_modules/@modelcontextprotocol/server-puppeteer/node_modules/puppeteer'));
(async () => {
  const browser = await puppeteer.launch({executablePath: process.env.CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: 'new', args: ['--allow-file-access-from-files']});
  const page = await browser.newPage(); const errs = []; await page.setViewport({width: 1600, height: 1000});
  page.on('pageerror', e => errs.push(e.message)); page.on('dialog', d => d.accept());
  await page.evaluateOnNewDocument(() => { window.fetch = () => new Promise(() => {}); try { localStorage.clear(); localStorage.setItem('atelier', JSON.stringify({guide: {mode: 'off', seen: {tour: true}}})); } catch (e) {} });
  await page.goto(process.env.PAGE_URL || 'file:///' + path.resolve(__dirname, '../../../atelier/index.html').split(path.sep).join('/'), {waitUntil: 'load'});
  await page.waitForFunction(() => window.__atelier && window.__atelier.loaded); await new Promise(r => setTimeout(r, 4000));
  const out = [], wait = ms => new Promise(r => setTimeout(r, ms));
  const step = async (label, fn, check, ms = 300) => { try { await page.evaluate(fn); await wait(ms); out.push(label + ': ' + await page.evaluate(check)); } catch (e) { out.push(label + ': FAILED ' + String(e.message).slice(0, 120)); } };
  await page.evaluate(() => { window.BIG = () => (document.querySelector('.oppage .opval b') || {}).textContent; window.OBJ = () => (document.querySelector('.oppage .opobj.on b') || {}).textContent;
    window.CHG = (sel, v) => { const s = document.querySelector(sel); s.value = v; s.dispatchEvent(new Event('change', {bubbles: true})); s.dispatchEvent(new Event('input', {bubbles: true})); }; });
  await step('open the optimizer on a WS set', () => { S.char = 'Tetsouo'; S.job = 'WAR'; S.section = 'sets'; render(); const s = data().sets.find(x => family(x.path, x.pieces) === 'ws' && wsOfSet(x)); S.selPath[S.job] = s.path; render(); document.querySelector('.detail [data-optview]').click(); },
    () => 'page ' + !!document.querySelector('.oppage') + ', obj ' + OBJ() + ', big ' + BIG());
  await step('objective: average', () => document.querySelector('.oppage [data-optobj="obj"][data-v="damage_avg"]').click(), () => 'obj ' + OBJ() + ', S ' + S.optOpts.obj + ', range fields ' + document.querySelectorAll('.oppage [data-optopt="tpFrom"],.oppage [data-optopt="tpTo"]').length + ', band ' + !!document.querySelector('.oppage .opcurve rect.band'));
  await step('range 2000', () => CHG('.oppage [data-optopt="tpFrom"]', '2000'), () => 'tpFrom ' + S.optOpts.tpFrom + ', field ' + document.querySelector('.oppage [data-optopt="tpFrom"]').value);
  await step('objective: at a TP', () => document.querySelector('.oppage [data-optobj="obj"][data-v="damage"]').click(), () => 'obj ' + OBJ() + ', tp field ' + !!document.querySelector('.oppage .tpin'));
  await step('TP 2000', () => CHG('.oppage .tpin', '2000'), () => 'wsTp ' + S.wsTp + ', big ' + BIG() + ', mark ' + !!document.querySelector('.oppage .opcurve line.mark'));
  await step('limit DT+PDT -40', () => CHG('.oppage [data-optopt="pdt"]', '-40'), () => 'pdt ' + S.optOpts.pdt + ', row ' + [...document.querySelectorAll('.oppage .optable th')].map(x => x.textContent).find(x => /PDT/.test(x)));
  await step('help', () => document.querySelector('.oppage [data-help="optpage"]').click(), () => 'help ' + !!document.querySelector('.oppage .wshelp'));
  await step('search tab Calcul', () => document.querySelector('.oppage [data-optab="calc"]').click(), () => 'tab ' + S._opTab + ', menu ' + !!document.querySelector('.oppage .optab select[data-optopt="search"]'));
  await step('special tab, Hoxne', () => { document.querySelector('.oppage [data-optab="special"]').click(); setTimeout(() => document.querySelector('.oppage [data-optopt="hoxne"]').click(), 50); }, () => 'hoxne ' + S.optOpts.hoxne + ', count ' + ((document.querySelector('.oppage [data-optab="special"] .opon') || {}).textContent || '-'));
  await step('start a search', () => document.querySelector('.oppage .optgo').click(), () => 'busy ' + !!S._optBusy + ', run window ' + !!document.querySelector('.optrun') + ', stop btn ' + !!document.querySelector('[data-optstop]'), 2500);
  await step('stop it', () => { const b = document.querySelector('[data-optstop], .optrun [data-close]'); if (b) b.click(); }, () => 'busy ' + !!S._optBusy, 1500);
  await step('close leftovers', () => { if (!document.querySelector('#overlay').hidden) document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape', bubbles: true})); }, () => 'overlay hidden ' + document.querySelector('#overlay').hidden + ', page ' + !!document.querySelector('.oppage'));
  await step('back to the set', () => document.querySelector('.oppage [data-optback]').click(), () => 'page ' + !!document.querySelector('.oppage') + ', card ' + !!document.querySelector('.detail .slots'));
  await step('engaged set, objectives', () => { const s = data().sets.find(x => family(x.path, x.pieces) === 'engaged'); S.selPath[S.job] = s.path; render(); document.querySelector('.detail [data-optview]').click(); setTimeout(() => document.querySelector('.oppage [data-optobj="engObj"][data-v="dps"]').click(), 80); },
    () => 'obj ' + OBJ() + ', factors ' + !!document.querySelector('.oppage .opfac') + ', engAt field ' + !!document.querySelector('.oppage [data-optopt="engAt"]'));
  await step('objective tp_real, TP 1500', () => { document.querySelector('.oppage [data-optobj="engObj"][data-v="tp_real"]').click(); setTimeout(() => CHG('.oppage [data-optopt="engAt"]', '1500'), 80); }, () => 'engAt ' + S.optOpts.engAt + ', rounds bar ' + document.querySelectorAll('.oppage .cycbar.tall i').length);
  await step('nuke set, spells', () => { S.job = 'BLM'; render(); const s = data().sets.find(x => isNukeSet(x.path)); S.selPath[S.job] = s.path; S.optView = optViewKey(s); render(); const sel = document.querySelector('.oppage [data-nukespells]'); [...sel.options].slice(0, 3).forEach(o => o.selected = true); sel.dispatchEvent(new Event('change', {bubbles: true})); },
    () => 'spells ' + JSON.stringify((S.optOpts.nukeSpells || {})).slice(0, 90) + ', big ' + BIG());
  await step('stats set', () => { S.job = 'PLD'; render(); const s = data().sets.find(x => family(x.path, x.pieces) === 'idle'); S.selPath[S.job] = s.path; S.optView = optViewKey(s); render(); }, () => 'page ' + !!document.querySelector('.oppage') + ', stat objectives ' + document.querySelectorAll('.oppage [data-statobj]').length);
  console.log(out.join('\n')); console.log('errors', JSON.stringify(errs));
  await browser.close();
})();
